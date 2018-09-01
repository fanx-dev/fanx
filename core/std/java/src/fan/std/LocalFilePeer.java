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
		String path = self.uri().pathStr;
		self.peer = new java.io.File(path);
	}

	public static LocalFile fromJava(java.io.File file) {
		LocalFile f = new LocalFile();
		f.peer = file;
		String uri = file.getPath();
		if (file.isDirectory())
			uri = uri + "/";
		f._uri = Uri.fromStr(uri);
		return f;
	}
	
	public static java.io.File toJava(File self) {
		java.io.File jfile = (java.io.File)((LocalFile)self).peer;
		return jfile;
	}

	static LocalFile make(java.io.File file, Uri uri) {
		if (file.exists()) {
			if (file.isDirectory()) {
				if (!uri.isDir())
					throw IOErr.make("Must use trailing slash for dir: " + uri);
			} else {
				if (uri.isDir())
					throw IOErr.make("Cannot use trailing slash for file: " + uri);
			}
		}

		LocalFile f = new LocalFile();
		f.peer = file;
		f._uri = uri;
		return f;
	}

	static FileStore store(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		FileStore fs = new FileStore();
		boolean spaceKnown = jfile.getTotalSpace() > 0;
		fs.totalSpace = spaceKnown ? jfile.getTotalSpace() : -1;
		fs.availSpace = spaceKnown ? jfile.getUsableSpace() : -1;
		fs.freeSpace = spaceKnown ? jfile.getFreeSpace() : -1;
		return fs;
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

	static void modified(LocalFile self, TimePoint time) {
		java.io.File jfile = (java.io.File) self.peer;
		long t = time.toMillis();
		jfile.setLastModified(t);
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

	static List list(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		java.io.File[] ls = jfile.listFiles();
		if (ls == null) {
			return List.defVal;
		}
		List res = List.make(ls.length);
		for (java.io.File f : ls) {
			res.add(fromJava(f));
		}
		return res;
	}

	static File normalize(LocalFile self) {
		try {
			java.io.File jfile = (java.io.File) self.peer;
			java.io.File canonical = jfile.getCanonicalFile();
			String path = "file:" + canonical.getCanonicalPath();
			if (canonical.exists() && canonical.isDirectory()) {
				path = path + "/";
			}
			Uri uri = Uri.fromStr(path);
			return make(canonical, uri);
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
		if (self.isDir())
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
		deleteJFile(jfile);
	}

	static void deleteJFile(java.io.File jfile) {
		if (!jfile.exists()) return;
		
		if (jfile.isDirectory()) {
			java.io.File[] kids = jfile.listFiles();
			for (int i = 0; i < kids.length; ++i)
				deleteJFile(kids[i]);
		}
		
		if (!jfile.delete())
		   throw IOErr.make("Cannot delete: " + jfile);
	}

	static File deleteOnExit(LocalFile self) {
		java.io.File jfile = (java.io.File) self.peer;
		jfile.deleteOnExit();
		return self;
	}

	static InStream in(LocalFile self, long bufferSize) {
		java.io.File jfile = (java.io.File) self.peer;
		try {
			FileInputStream fin = new FileInputStream(jfile);
			return SysInStreamPeer.fromJava(fin, bufferSize);
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	static OutStream out(LocalFile self, boolean append, long bufferSize) {
		java.io.File jfile = (java.io.File) self.peer;
		try {
			java.io.File parent = jfile.getParentFile();
		    if (parent != null && !parent.exists()) parent.mkdirs();
		      
			FileOutputStream fin = new FileOutputStream(jfile, append);
			SysOutStream out = SysOutStreamPeer.fromJava(fin, bufferSize);
			out.peer.fd = fin.getFD();
			return out;
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}
}
