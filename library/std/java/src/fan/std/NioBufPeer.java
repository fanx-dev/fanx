package fan.std;

import java.io.FileNotFoundException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileChannel.MapMode;

import fan.sys.ArgErr;
import fan.sys.IOErr;
import fan.sys.UnsupportedErr;

public class NioBufPeer {
	ByteBuffer buf;

	public static NioBufPeer make(NioBuf buf) {
		return new NioBufPeer();
	}
	
	public static NioBuf fromJava(java.nio.ByteBuffer buf) {
		NioBuf fbuf = NioBuf.make();
		((NioBufPeer)fbuf.peer).buf = buf;
		return fbuf;
	}

	void alloc(NioBuf self, long size) {
		buf = ByteBuffer.allocate((int)size);
	}

	void init(NioBuf self, File file, String mode, long pos, Long size) throws FileNotFoundException {
		LocalFile lfile = (LocalFile) file;
		try {
			// map mode
			String rw;
			MapMode mm;
			if (mode.equals("r")) {
				rw = "r";
				mm = MapMode.READ_ONLY;
			} else if (mode.equals("rw")) {
				rw = "rw";
				mm = MapMode.READ_WRITE;
			} else if (mode.equals("p")) {
				rw = "rw";
				mm = MapMode.PRIVATE;
			} else
				throw ArgErr.make("Invalid mode: " + mode);

			// if size is null, use file size
			if (size == null)
				size = file.size();

			// traverse the various Java APIs
			RandomAccessFile fp = null;
			FileChannel chan = null;
			try {
				fp = new RandomAccessFile((java.io.File) lfile.jfile, rw);
				chan = fp.getChannel();
				buf = (chan.map(mm, pos, size.longValue()));
			} finally {
				if (chan != null)
					chan.close();
				if (fp != null)
					fp.close();
			}
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	long size(NioBuf self) {
		return buf.limit();
	}

	public final void size(NioBuf self, long x) {
		buf.limit((int) x);
	}

	long capacity(NioBuf self) {
		return buf.capacity();
	}

	void capacity(NioBuf self, long capa) {
		throw UnsupportedErr.make("mmap capacity fixed");
	}

	long pos(NioBuf self) {
		return buf.position();
	}

	void pos(NioBuf self, long x) {
		buf.position((int) x);
	}

	long getByte(NioBuf self, long pos) {
		return buf.get((int) pos) & 0xff;
	}

	void setByte(NioBuf self, long pos, long b) {
		buf.put((int) pos, (byte) b);
	}

	long getBytes(NioBuf self, long pos, byte[] dst, long off, long len) {
		int oldPos = buf.position();
		buf.position((int) pos);
		buf.get(dst, (int) off, (int) len);
		buf.position(oldPos);
		return len;
	}

	void setBytes(NioBuf self, long pos, byte[] src, long off, long len) {
		int oldPos = buf.position();
		buf.position((int) pos);
		buf.put(src, (int) off, (int) len);
		buf.position(oldPos);
	}

	boolean close(NioBuf self) {
		return true;
	}

	Buf sync(NioBuf self) {
		if (buf instanceof MappedByteBuffer)
			((MappedByteBuffer) buf).force();
		return self;
	}

	public ByteBuffer toByteBuffer() {
		//return buf.duplicate();
		return buf;
	}
}
