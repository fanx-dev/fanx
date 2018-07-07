package fan.std;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;

import fan.sys.ByteArray;
import fan.sys.IOErr;

public class FileBufPeer {
	private RandomAccessFile fp;

	public FileBufPeer make(FileBuf buf) {
		return new FileBufPeer();
	}

	void init(FileBuf self, File file, String mode) throws FileNotFoundException {
		LocalFile lfile = (LocalFile) file;
		fp = new RandomAccessFile((java.io.File) lfile.peer, mode);
	}

	long size(FileBuf self) {
		try {
			return fp.length();
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	public final void size(FileBuf self, long x) {
		try {
			fp.setLength(x);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	long capacity(FileBuf self) {
		return Long.MAX_VALUE;
	}
	
	void capacity(FileBuf self, long capa) {
	}

	long pos(FileBuf self) {
		try {
			return fp.getFilePointer();
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	void pos(FileBuf self, long x) {
		try {
			fp.seek(x);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	long getByte(FileBuf self, long pos) {
		try {
			long oldPos = fp.getFilePointer();
			fp.seek(pos);
			int b = fp.read();
			fp.seek(oldPos);
			return b;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	void setByte(FileBuf self, long pos, long b) {
		try {
			long oldPos = fp.getFilePointer();
			fp.seek(pos);
			fp.write((int) b);
			fp.seek(oldPos);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	long getBytes(FileBuf self, long pos, ByteArray dst, long off, long len) {
		try {
			long oldPos = fp.getFilePointer();
			fp.seek(pos);
			int r = fp.read(dst.array(), (int)off, (int)len);
			fp.seek(oldPos);
			return r;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}
	
	void setBytes(FileBuf self, long pos, ByteArray src, long off, long len) {
		try {
			long oldPos = fp.getFilePointer();
			fp.seek(pos);
			fp.write(src.array(), (int)off, (int)len);
			fp.seek(oldPos);
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}

	boolean close(FileBuf self) {
		try {
			fp.close();
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	FileBuf sync(FileBuf self) {
		try {
			fp.getFD().sync();
			return self;
		} catch (IOException e) {
			throw IOErr.make(e);
		}
	}
}
