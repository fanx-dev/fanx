package fan.std;

import java.security.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.util.zip.*;

import fan.sys.ArgErr;
import fan.sys.ByteArray;
import fan.sys.Err;
import fan.sys.UnsupportedErr;

public class BufCryptoPeer {
	//////////////////////////////////////////////////////////////////////////
	// CRC
	//////////////////////////////////////////////////////////////////////////

	public static long crc(Buf self, String algorithm) {
		if (algorithm.equals("CRC-16"))
			return crc16(self);
		if (algorithm.equals("CRC-32"))
			return crc(self, new CRC32());
		if (algorithm.equals("CRC-32-Adler"))
			return crc(self, new Adler32());
		throw ArgErr.make("Unknown CRC algorthm: " + algorithm);
	}

	private static long crc(Buf self, Checksum checksum) {
		checksum.update(self.unsafeArray().array(), 0, (int) self.size());
		return checksum.getValue() & 0xffffffff;
	}

	private static long crc16(Buf self) {
		byte[] array = self.unsafeArray().array();
		int size = (int) self.size();
		int seed = 0xffff;
		for (int i = 0; i < size; ++i)
			seed = crc16(array[i], seed);
		return seed;
	}

	private static int crc16(int dataToCrc, int seed) {
		int dat = ((dataToCrc ^ (seed & 0xFF)) & 0xFF);
		seed = (seed & 0xFFFF) >>> 8;
		int index1 = (dat & 0x0F);
		int index2 = (dat >>> 4);
		if ((CRC16_ODD_PARITY[index1] ^ CRC16_ODD_PARITY[index2]) == 1)
			seed ^= 0xC001;
		dat <<= 6;
		seed ^= dat;
		dat <<= 1;
		seed ^= dat;
		return seed;
	}

	static private final int[] CRC16_ODD_PARITY = { 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0 };
	//////////////////////////////////////////////////////////////////////////
	// Digest
	//////////////////////////////////////////////////////////////////////////

	public static Buf toDigest(Buf self, String algorithm) {
		ByteArray ba = self.unsafeArray();
		if (ba != null) {
			return memToDigest(ba, (int)self.size(), algorithm);
		}
		return fileToDigest(self, algorithm);
	}

	public static Buf memToDigest(ByteArray ba, int size, String algorithm) {
		try {
			MessageDigest md = MessageDigest.getInstance(algorithm);
			md.update(ba.array(), 0, size);
			return MemBuf.makeBuf(new ByteArray(md.digest()));
		} catch (NoSuchAlgorithmException e) {
			throw ArgErr.make("Unknown digest algorthm: " + algorithm);
		}
	}

	public static Buf fileToDigest(Buf self, String algorithm) {
		try {
			long oldPos = self.pos();
			long size = self.size();
			ByteArray temp = ByteArray.make(1024);
			MessageDigest md = MessageDigest.getInstance(algorithm);

			InStream in = self.in();

			self.pos(0);
			long total = 0;
			while (total < size) {
				long n = in.readBytes(temp, 0, (int) java.lang.Math.min(temp.size(), (int) size - total));
				md.update(temp.array(), 0, (int) n);
				total += n;
			}

			self.pos(oldPos);
			return MemBuf.makeBuf(new ByteArray(md.digest()));
		} catch (NoSuchAlgorithmException e) {
			throw ArgErr.make("Unknown digest algorthm: " + algorithm);
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// HMAC
	//////////////////////////////////////////////////////////////////////////

	public static Buf hmac(Buf self, String algorithm, Buf keyBuf) {
		// get digest algorthim
		MessageDigest md = null;
		int blockSize = 64;
		try {
			md = MessageDigest.getInstance(algorithm);
		} catch (NoSuchAlgorithmException e) {
			throw ArgErr.make("Unknown digest algorthm: " + algorithm);
		}

		// get secret key bytes
		byte[] keyBytes = null;
		int keySize = 0;
		try {
			// get key bytes
			keyBytes = keyBuf.safeArray().array();
			keySize = keyBytes.length;

			// key is greater than block size we hash it first
			if (keySize > blockSize) {
				md.update(keyBytes, 0, keySize);
				keyBytes = md.digest();
				keySize = keyBytes.length;
				md.reset();
			}
		} catch (ClassCastException e) {
			throw UnsupportedErr.make("key parameter must be memory buffer");
		}

		// RFC 2104:
		// ipad = the byte 0x36 repeated B times
		// opad = the byte 0x5C repeated B times
		// H(K XOR opad, H(K XOR ipad, text))

		// inner digest: H(K XOR ipad, text)
		for (int i = 0; i < blockSize; ++i) {
			if (i < keySize)
				md.update((byte) (keyBytes[i] ^ 0x36));
			else
				md.update((byte) 0x36);
		}
		md.update(self.unsafeArray().array(), 0, (int) self.size());
		byte[] innerDigest = md.digest();

		// outer digest: H(K XOR opad, innerDigest)
		md.reset();
		for (int i = 0; i < blockSize; ++i) {
			if (i < keySize)
				md.update((byte) (keyBytes[i] ^ 0x5C));
			else
				md.update((byte) 0x5C);
		}
		md.update(innerDigest);

		// return result
		return MemBuf.makeBuf(new ByteArray(md.digest()));
	}

	//////////////////////////////////////////////////////////////////////////
	// pbk
	//////////////////////////////////////////////////////////////////////////

	public static Buf pbk(String algorithm, String pass, Buf _salt, long _iterations, long _keyLen) {
		try {
			// get low-level representation of args
			byte[] salt = _salt.safeArray().array();
			int iterations = (int) _iterations;
			int keyLen = (int) _keyLen;

			// this is not supported until Java8, so use custom implementation
			if (algorithm.equals("PBKDF2WithHmacSHA256"))
				return MemBuf.makeBuf(new ByteArray(PBKDF2WithHmacSHA256.gen(pass, salt, iterations, keyLen)));

			// use built-in Java APIs
			PBEKeySpec spec = new PBEKeySpec(pass.toCharArray(), salt, iterations, keyLen * 8);
			SecretKeyFactory skf = SecretKeyFactory.getInstance(algorithm);
			return MemBuf.makeBuf(new ByteArray(skf.generateSecret(spec).getEncoded()));
		} catch (NoSuchAlgorithmException e) {
			throw ArgErr.make("Unsupported algorithm: " + algorithm, e);
		} catch (Exception e) {
			throw Err.make(e);
		}
	}

	// Implementation from:
	// http://stackoverflow.com/questions/9147463/java-pbkdf2-with-hmacsha256-as-the-prf
	static class PBKDF2WithHmacSHA256 {
		static byte[] gen(String pass, byte[] salt, int iterations, int dkLen) throws Exception {
			SecretKeySpec keyspec = new SecretKeySpec(pass.getBytes(), "HmacSHA256");
			Mac prf = Mac.getInstance("HmacSHA256");
			prf.init(keyspec);

			int hLen = prf.getMacLength(); // 20 for SHA1
			int l = java.lang.Math.max(dkLen, hLen); // 1 for 128bit (16-byte)
														// keys
			int r = dkLen - (l - 1) * hLen; // 16 for 128bit (16-byte) keys
			byte T[] = new byte[l * hLen];
			int ti_offset = 0;
			for (int i = 1; i <= l; i++) {
				F(T, ti_offset, prf, salt, iterations, i);
				ti_offset += hLen;
			}

			if (r < hLen) {
				// Incomplete last block
				byte DK[] = new byte[dkLen];
				System.arraycopy(T, 0, DK, 0, dkLen);
				return DK;
			}
			return T;
		}

		private static void F(byte[] dest, int offset, Mac prf, byte[] S, int c, int blockIndex) {
			final int hLen = prf.getMacLength();
			byte U_r[] = new byte[hLen];
			byte U_i[] = new byte[S.length + 4];
			System.arraycopy(S, 0, U_i, 0, S.length);
			INT(U_i, S.length, blockIndex);
			for (int i = 0; i < c; i++) {
				U_i = prf.doFinal(U_i);
				xor(U_r, U_i);
			}
			System.arraycopy(U_r, 0, dest, offset, hLen);
		}

		private static void xor(byte[] dest, byte[] src) {
			for (int i = 0; i < dest.length; i++)
				dest[i] ^= src[i];
		}

		private static void INT(byte[] dest, int offset, int i) {
			dest[offset + 0] = (byte) (i / (256 * 256 * 256));
			dest[offset + 1] = (byte) (i / (256 * 256));
			dest[offset + 2] = (byte) (i / (256));
			dest[offset + 3] = (byte) (i);
		}
	}
}
