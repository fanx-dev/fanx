package fan.std;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;
import java.nio.charset.CoderResult;

import fan.sys.ByteArray;
import fan.sys.IOErr;

public class NativeCharsetPeer {
	java.nio.charset.Charset jcharset;

	static public NativeCharsetPeer make(NativeCharset charset) {
		return new NativeCharsetPeer();
	}

	static Charset fromStr(String name) {
		try {
			java.nio.charset.Charset jcharset = java.nio.charset.Charset.forName(name);

			// check normalized name for predefined charsets
			String csName = jcharset.name().toUpperCase();
			if (csName.equals("UTF-8"))
				return Charset.utf8;
			if (csName.equals("UTF-16BE"))
				return Charset.utf16BE;
			if (csName.equals("UTF-16LE"))
				return Charset.utf16LE;

			NativeCharset encoder = NativeCharset.make();
			encoder.peer.jcharset = jcharset;
			
			Charset charset = Charset.privateMake(csName, encoder);
			return charset;
		} catch (Exception e) {
			return null;
		}
	}

	long encode(NativeCharset self, long ch, OutStream out) {
		CharsetEncoder encoder = jcharset.newEncoder();
		CharBuffer cbuf = CharBuffer.allocate(1);
		ByteBuffer bbuf = ByteBuffer.allocate(16);

		// ready input char buffer
		cbuf.clear();
		cbuf.put((char)ch);
		cbuf.flip();

		// call into encoder
		CoderResult r;
		r = encoder.encode(cbuf, bbuf, true);
		if (r.isError())
			throw IOErr.make("Invalid " + jcharset.name() + " encoding");
		r = encoder.flush(bbuf);
		if (r.isError())
			throw IOErr.make("Invalid " + jcharset.name() + " encoding");

		// drain from internal byte buffer to fan buf
		bbuf.flip();
		int s = bbuf.position() + 1;
		while (bbuf.hasRemaining())
			out.write(bbuf.get());
		return s;
	}

	long encodeArray(NativeCharset self, long ch, ByteArray out, long offset) {
		CharsetEncoder encoder = jcharset.newEncoder();
		CharBuffer cbuf = CharBuffer.allocate(1);
//		ByteBuffer bbuf = ByteBuffer.allocate(16);
		ByteBuffer bbuf = ByteBuffer.wrap(out.array(), (int)offset, (int)(out.size()-offset));

		// ready input char buffer
		cbuf.clear();
		cbuf.put((char)ch);
		cbuf.flip();

		// call into encoder
		CoderResult r;
		r = encoder.encode(cbuf, bbuf, true);
		if (r.isError())
			throw IOErr.make("Invalid " + jcharset.name() + " encoding");
		r = encoder.flush(bbuf);
		if (r.isError())
			throw IOErr.make("Invalid " + jcharset.name() + " encoding");

		// drain from internal byte buffer to fan buf
		int s = bbuf.position() + 1;
//		bbuf.flip();
//		int i = 0;
//		while (bbuf.hasRemaining())
//			out.set(i++, bbuf.get());
		return s;
	}

	long decode(NativeCharset self, InStream in) {
		CharsetDecoder decoder = jcharset.newDecoder();
		CharBuffer cbuf = CharBuffer.allocate(16);
		ByteBuffer bbuf = ByteBuffer.allocate(16);

		// many thanks to Ron Hitchens (author of O'Reilly Java NIO)
		// for helping me figure out how to make this work - it's still
		// a bit of black magic to me - now I can go watch Battlestar
		// Galactica

		// reset buffers
		decoder.reset();
		bbuf.clear();

		// pass thru one byte at a time until we have a char
		while (true) {
			int b = (int) in.r();
			if (b < 0)
				return -1;

			cbuf.clear();
			bbuf.put((byte) b);
			bbuf.flip();

			CoderResult r = decoder.decode(bbuf, cbuf, false);

			if (r.isError())
				throw IOErr.make("Invalid " + jcharset.name() + " encoding");

			bbuf.compact();
			cbuf.flip();

			if (cbuf.hasRemaining())
				return cbuf.get();
		}
	}
}
