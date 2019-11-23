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
import java.io.FileDescriptor;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

import fan.std.SysInStreamPeer.JInputStream;
import fan.sys.IOErr;

public class SysOutStreamPeer {
//	final OutputStream originalStream;
	OutputStream outStream;
//	Writer outWrite;
//	DataOutputStream dataStream;
	FileDescriptor fd;
	
	static class JOutputStream extends OutputStream {
		OutStream out;
		
		public JOutputStream(OutStream out) {
			this.out = out;
		}
		
		@Override
		public void write(int b) throws IOException {
			out.write(b);
		}
		
		@Override
		public void write(byte b[], int off, int len) {
			byte[] ba = b;
			out.writeBytes(ba, off, len);
		}
		
		@Override
		public void flush() throws IOException {
			out.flush();
	    }
		
		@Override
		public void close() throws IOException {
			out.close();
	    }
	}
	
	public static OutputStream toJava(OutStream out) {
		if (out instanceof SysOutStream) {
			SysOutStreamPeer peer = (SysOutStreamPeer)((SysOutStream)out).peer;
			return peer.outStream;
		}
		return new JOutputStream(out);
	}

	private void init(OutputStream out) {
		outStream = out;
//		java.nio.charset.Charset jcharset = java.nio.charset.Charset.forName(c.name);
//		outWrite = new OutputStreamWriter(out, cs);
//		dataStream = new DataOutputStream(out);
	}
	
	public static SysOutStreamPeer make(SysOutStream self) {
		return new SysOutStreamPeer();
	}
	
	public static SysOutStream fromJava(OutputStream out) {
		return fromJava(out, Endian.big, Charset.utf8, 0);
	}

	public static SysOutStream fromJava(OutputStream out, long bufSize) {
		return fromJava(out, Endian.big, Charset.utf8, bufSize);
	}

	public static SysOutStream fromJava(OutputStream out, Endian e, Charset c, long bufSize) {
		SysOutStream sin = SysOutStream.make(e, c);
		if (bufSize > 0) {
			out = new BufferedOutputStream(out, (int) bufSize);
		}
		((SysOutStreamPeer)sin.peer).init(out);
		return sin;
	}

	public OutStream write(SysOutStream self, long b) {
		try {
			this.outStream.write((int) b);
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	public OutStream writeBytes(SysOutStream self, byte[] buf, long off, long len) {
		try {
			this.outStream.write(buf, (int) off, (int) len);
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

//	static OutStream writeByteArray(SysOutStream self, ByteArray buf, long off) {
//		return writeByteArray(self, buf, off, buf.size());
//	}

//	static OutStream writeByteArray(SysOutStream self, ByteArray buf) {
//		return writeByteArray(self, buf, 0, buf.size());
//	}

	public OutStream sync(SysOutStream self) {
		try {
			this.outStream.flush();
			if (fd != null) fd.sync();
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	public OutStream flush(SysOutStream self) {
		try {
			this.outStream.flush();
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	public boolean close(SysOutStream self) {
		try {
			if (this.outStream != null)
				this.outStream.close();
			return true;
		} catch (IOException e) {
			return false;
		}
	}
}
