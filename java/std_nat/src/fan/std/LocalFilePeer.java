//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fan.std;

import java.io.FileInputStream;
import java.io.FileOutputStream;

import fan.sys.ArgErr;
import fan.sys.IOErr;
import fan.sys.List;

public class LocalFilePeer {
	static void init(LocalFile self) {
		String path = self.uri.pathStr;
		self.peer = new java.io.File(path);
	}

	static FileStore store() {
		// TODO
		return null;
	}

	static File copyTo(LocalFile self, LocalFile to) {
		return copyTo(self, to, null);
	}

	static File copyTo(LocalFile self, LocalFile to, Map options) {
		// TODO
		return null;
	}

	static boolean exists(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		return jfile.exists();
	}

	static long size(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		if (jfile.isDirectory())
			return 0;
		return jfile.length();
	}

	static TimePoint modified(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		long mills = jfile.lastModified();
		return TimePoint.fromMillis(mills);
	}

	static String osPath(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		return jfile.getPath();
	}

	static File parent(LocalFile self) {
		// java.io.File jfile = (java.io.File)self.peer;
		return fan.std.File.make(self.uri.parent());
	}

	static File javaToFan(java.io.File jfile) {
		LocalFile f = new LocalFile();
		f.uri = Uri.fromStr(jfile.getPath());
		f.peer = jfile;
		return f;
	}

	static List list(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		java.io.File[] ls = jfile.listFiles();
		List res = List.make(self.typeof(), ls.length);
		for (java.io.File f : ls) {
			res.add(javaToFan(f));
		}
		return res;
	}

	static File normalize(LocalFile self) {
		try {
			java.io.File jfile = (java.io.File) self.peer;
			java.io.File canonical = jfile.getCanonicalFile();
			return javaToFan(canonical);
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	private static void createFile(java.io.File file) {
		if (file.exists()) {
			if (file.isDirectory())
				throw IOErr.make("Already exists as dir: " + file);
		}

		java.io.File parent = file.getParentFile();
		if (parent != null && !parent.exists()) {
			if (!parent.mkdirs())
				throw IOErr.make("Cannot create dir: " + parent);
		}

		try {
			java.io.FileOutputStream out = new java.io.FileOutputStream(file);
			out.close();
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	private static void createDir(java.io.File file) {
		if (file.exists()) {
			if (!file.isDirectory())
				throw IOErr.make("Already exists as file: " + file);
		} else {
			if (!file.mkdirs())
				throw IOErr.make("Cannot create dir: " + file);
		}
	}

	static File create(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		if (jfile.isDirectory())
			createDir(jfile);
		else
			createFile(jfile);
		return self;
	}

	static File moveTo(LocalFile self, File ato) {
		java.io.File file = (java.io.File) self.peer;

		if (file.isDirectory() != ato.isDir()) {
			if (file.isDirectory())
				throw ArgErr.make("moveTo must be dir `" + ato + "`");
			else
				throw ArgErr.make("moveTo must not be dir `" + ato + "`");
		}

		if (!(ato instanceof LocalFile))
			throw IOErr.make("Cannot move LocalFile to " + ato.typeof());

		java.io.File dest = (java.io.File) (((LocalFile) ato).peer);

		if (dest.exists())
			throw IOErr.make("moveTo already exists: " + ato);

		if (!file.isDirectory()) {
			File destParent = ato.parent();
			if (destParent != null && !destParent.exists())
				destParent.create();
		}

		if (!file.renameTo(dest))
			throw IOErr.make("moveTo failed: " + ato);

		return ato;
	}

	static void delete(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		if (jfile.exists() && jfile.isDirectory()) {
			java.io.File[] kids = jfile.listFiles();
			for (int i = 0; i < kids.length; ++i)
				kids[i].delete();
		}

		try {
			// java.io.File has some issues on macOS (and Linux?) with
			// broken symlinks; and will report they do not exist; use
			// Files.deleteIfExists to cleanup properly
			java.nio.file.Files.deleteIfExists(jfile.toPath());
		} catch (java.io.IOException err) {
			throw fan.sys.IOErr.make("Cannot delete: " + self.toStr(), err);
		}
	}

	static File deleteOnExit(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		jfile.deleteOnExit();
		return self;
	}

	static Buf open(LocalFile self, String mode) {
		java.io.File jfile = (java.io.File) self.peer;
		return null;
	}

	static Buf open(LocalFile self) {
		return open(self, "rw");
	}

	static Buf mmap(LocalFile self, String mode, long pos, long size) {
		java.io.File jfile = (java.io.File) self.peer;
		return null;
	}

	static Buf mmap(LocalFile self, String mode, long pos) {
		return mmap(self, mode, pos, self.size());
	}

	static Buf mmap(LocalFile self, String mode) {
		return mmap(self, mode, 0, self.size());
	}

	static Buf mmap(LocalFile self) {
		return mmap(self, "rw", 0, self.size());
	}

	static InStream in(LocalFile self, long bufferSize) {
		java.io.File jfile = (java.io.File) self.peer;
		try {
			FileInputStream fin = new FileInputStream(jfile);
			return SysInStreamPeer.make(fin, bufferSize);
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	static InStream in(LocalFile self) {
		return in(self, 4096);
	}

	static OutStream out(LocalFile self, boolean append, long bufferSize) {
		java.io.File jfile = (java.io.File) self.peer;
		try {
			FileOutputStream fin = new FileOutputStream(jfile, append);
			return SysOutStreamPeer.make(fin, bufferSize);
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	static OutStream out(LocalFile self, boolean append) {
		return out(self, append, 4096);
	}

	static OutStream out(LocalFile self) {
		return out(self, false, 4096);
	}
}
