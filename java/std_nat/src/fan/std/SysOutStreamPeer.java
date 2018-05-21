//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fan.std;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

import fan.sys.ByteArray;
import fan.sys.IOErr;

public class SysOutStreamPeer {
	final OutputStream originalStream;
	OutputStream outStream;
	Writer outWrite;
	DataOutputStream dataStream;

	SysOutStreamPeer(OutputStream orig) {
		originalStream = orig;
	}

	void init(OutputStream out, java.nio.charset.Charset cs) {
		outStream = out;
		outWrite = new OutputStreamWriter(out, cs);
		dataStream = new DataOutputStream(out);
	}

	public static OutStream make(OutputStream out, long bufSize) {
		return make(out, Endian.big, Charset.utf8, bufSize);
	}

	public static OutStream make(OutputStream out, Endian e, Charset c, long bufSize) {
		SysOutStreamPeer peer = new SysOutStreamPeer(out);
		SysOutStream sin = SysOutStream.make(e, c);
		sin.peer = peer;
		java.nio.charset.Charset jcharset = java.nio.charset.Charset.forName(c.name);
		if (bufSize > 0) {
			out = new BufferedOutputStream(out, (int) bufSize);
		}
		peer.init(out, jcharset);
		return sin;
	}

	static OutStream write(SysOutStream self, long b) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.outStream.write((int) b);
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static OutStream writeByteArray(SysOutStream self, ByteArray buf, long off, long len) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.outStream.write(buf.array(), (int) off, (int) len);
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static OutStream writeByteArray(SysOutStream self, ByteArray buf, long off) {
		return writeByteArray(self, buf, off, buf.size());
	}

	static OutStream writeByteArray(SysOutStream self, ByteArray buf) {
		return writeByteArray(self, buf, 0, buf.size());
	}

	static OutStream sync(SysOutStream self) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.outStream.flush();
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static OutStream flush(SysOutStream self) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.outStream.flush();
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	static boolean close(SysOutStream self) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			if (peer.outStream != null)
				peer.outStream.close();
			return true;
		} catch (IOException e) {
			return false;
		}
	}

	static OutStream writeUtf(SysOutStream self, String s) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.dataStream.writeUTF(s);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
		return self;
	}

	static OutStream writeChar(SysOutStream self, long ch) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.outWrite.write((char) ch);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
		return self;
	}

	static OutStream writeChars(SysOutStream self, String str, long off, long len) {
		SysOutStreamPeer peer = (SysOutStreamPeer) self.peer;
		try {
			peer.outWrite.write(str, (int) off, (int) len);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
		return self;
	}

	static OutStream writeChars(SysOutStream self, String str, long off) {
		return writeChars(self, str, off, str.length() - off);
	}

	static OutStream writeChars(SysOutStream self, String str) {
		return writeChars(self, str, 0, str.length());
	}
}
