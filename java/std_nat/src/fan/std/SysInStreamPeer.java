//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fan.std;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PushbackInputStream;
import java.io.Reader;

import fan.sys.ByteArray;
import fan.sys.FanInt;
import fan.sys.IOErr;

public class SysInStreamPeer {
	
	java.nio.charset.Charset jcharset;
	final InputStream originalStream;

	// PushbackInputStream
	InputStream inputStream;

	Reader inputReader;// read chars
	DataInputStream dataStream;// read utf8

	SysInStreamPeer(InputStream orig) {
		originalStream = orig;
	}

	void init(InputStream in, java.nio.charset.Charset cs) {
		inputStream = in;
		jcharset = cs;
		inputReader = new InputStreamReader(in, jcharset);
		dataStream = new DataInputStream(in);
	}
	
	public static InStream make(InputStream in, long bufSize) {
		return make(in, Endian.big, Charset.utf8, bufSize);
	}

	public static InStream make(InputStream in, Endian e, Charset c, long bufSize) {
		SysInStreamPeer peer = new SysInStreamPeer(in);
		SysInStream sin = SysInStream.make(e, c);
		sin.peer = peer;
		java.nio.charset.Charset jcharset = java.nio.charset.Charset.forName(c.name);
		if (bufSize > 0) {
			in = new BufferedInputStream(in, (int) bufSize);
		}
		peer.init(in, jcharset);
		return sin;
	}

	static long avail(SysInStream self) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			return peer.inputStream.available();
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static long r(SysInStream self) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			long res = peer.inputStream.read();
//			if (res == -1) return FanInt.invalidVal;
			return res;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static long skip(SysInStream self, long n) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			return peer.inputStream.skip(n);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	long readByteArray(SysInStream self, ByteArray ba, long off, long len) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			return peer.inputStream.read(ba.array(), (int)off, (int)len);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	long readByteArray(SysInStream self, ByteArray ba, long off) {
		return readByteArray(self, ba, off, ba.size());
	}

	long readByteArray(SysInStream self, ByteArray ba) {
		return readByteArray(self, ba, 0, ba.size());
	}

	private static void unreadF(SysInStreamPeer peer, int n) throws IOException {
		if (peer.inputStream instanceof PushbackInputStream) {
			((PushbackInputStream) peer.inputStream).unread(n);
		} else {
			PushbackInputStream p = new PushbackInputStream(peer.inputStream);
			peer.init(p, peer.jcharset);
			((PushbackInputStream) peer.inputStream).unread(n);
		}
	}

	static InStream unread(SysInStream self, long n) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			unreadF(peer, (int) n);
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static boolean close(SysInStream self) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			peer.inputStream.close();
			return true;
		} catch (IOException e) {
			return false;
		}
	}

	static long peek(SysInStream self) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		int x;
		try {
			x = peer.inputStream.read();
			if (x != -1)
				unread(self, x);
			return x;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static String readUtf(SysInStream self) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			return peer.dataStream.readUTF();
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static long rChar(SysInStream self) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			return peer.inputReader.read();
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static InStream unreadChar(SysInStream self, long b) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			char[] cs = new char[1];
			cs[0] = (char) b;
			String x = new String(cs);
			byte[] bs = x.getBytes(peer.jcharset);
			for (int i = 0; i < bs.length; ++i) {
				unreadF(peer, (int) bs[i]);
			}
		} catch (IOException e) {
			throw IOErr.make(e);
		}
		return self;
	}

	static long peekChar(SysInStream self) {
		long x = rChar(self);
		if (x != -1)
			unreadChar(self, x);
		return x;
	}

	static String readChars(SysInStream self, long n) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		char[] cbuf = new char[(int) n];
		try {
			peer.inputReader.read(cbuf, 0, (int) n);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
		return new String(cbuf);
	}

	static String readLine(SysInStream self, long max) {
		try {
			SysInStreamPeer peer = (SysInStreamPeer) self.peer;
			StringBuilder sb = new StringBuilder();
			if (max < 0) {
				while (true) {
					int r = peer.inputReader.read();
					if (r == -1)
						break;
					char c = (char) r;
					sb.append(c);
				}
				return sb.toString();
			}
			for (int i = 0; i < max; ++i) {
				int r = peer.inputReader.read();
				if (r == -1)
					break;
				char c = (char) r;
				sb.append(c);
			}

			return sb.toString();
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static String readLine(SysInStream self) {
		return readLine(self, -1);
	}

	static String readAllStr(SysInStream self, boolean normalizeNewlines) {
		SysInStreamPeer peer = (SysInStreamPeer) self.peer;
		try {
			char[] buf = new char[4096];
			int n = 0;
			boolean normalize = normalizeNewlines;

			// read characters
			int last = -1;
			while (true) {
				int c = peer.inputReader.read();
				if (c < 0)
					break;

				// grow buffer if needed
				if (n >= buf.length) {
					char[] temp = new char[buf.length * 2];
					System.arraycopy(buf, 0, temp, 0, n);
					buf = temp;
				}

				// normalize newlines and add to buffer
				if (normalize) {
					if (c == '\r')
						buf[n++] = '\n';
					else if (last == '\r' && c == '\n') {
					} else
						buf[n++] = (char) c;
					last = c;
				} else {
					buf[n++] = (char) c;
				}
			}

			return new String(buf, 0, n);
		} catch (IOException e) {
			throw IOErr.make(e);
		} finally {
			try {
				peer.inputReader.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	static String readAllStr(SysInStream self) {
		return readAllStr(self, true);
	}
}
