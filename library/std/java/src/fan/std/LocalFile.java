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
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Files;

import fan.sys.ArgErr;
import fan.sys.IOErr;
import fan.sys.List;
import fanx.util.FileUtil;
import fanx.main.Sys;
import fanx.main.Type;

public class LocalFile extends fan.std.File {
	java.io.File jfile;

	// boiler plate for reflection
	public Type typeof()
	{
		if (type == null) type = Sys.findType("std::LocalFile");
		return type;
	}
	private static Type type;

	public static LocalFile make(Uri uri, boolean checkSlash) {
		LocalFile self = new LocalFile();
	    make$(self, uri, checkSlash);
	    return self;
	}

	public static LocalFile make(Uri uri) {
		return make(uri, true);
	}

	// constructor implementation called by subclasses
	public static void make$(LocalFile self, Uri uri, boolean checkSlash) {
		String path = uri.pathStr();
		java.io.File file = new java.io.File(path);
		if (file.exists()) {
			if (file.isDirectory()) {
				if (!uri.isDir()) {
					if (checkSlash)
						throw IOErr.make("Must use trailing slash for dir: " + uri);
					else
						uri = uri.plusSlash();
				}
			} else {
				if (uri.isDir())
					throw IOErr.make("Cannot use trailing slash for file: " + uri);
			}
		}
		self.jfile = file;
		fan.std.File.privateMake$(self, uri);
	}

	public static LocalFile fromJava(java.io.File file) {
		Uri uri = fileToUri(file, false);
		return make(file, uri, false);
	}

	static LocalFile make(java.io.File file, Uri uri, boolean check) {
		if (check && file.exists()) {
			if (file.isDirectory()) {
				if (!uri.isDir())
					throw IOErr.make("Must use trailing slash for dir: " + uri);
			} else {
				if (uri.isDir())
					throw IOErr.make("Cannot use trailing slash for file: " + uri);
			}
		}

		LocalFile f = new LocalFile();
		f.jfile = file;
		f._uri = uri;
		return f;
	}
	
	private static Uri fileToUri(java.io.File file, boolean normalize) {
		String path;
		if (normalize) {
			try {
				path = file.getCanonicalPath();
			} catch (IOException e) {
				path = file.getAbsolutePath();
			}
		} else {
			path = file.getPath();
		}
		
		path = FileUtil.osPahtToUri(path, true);
		
		if (normalize) {
			path = "file:" + path;
		}
		
		return Uri.fromStr(path);
	}
	
	public static java.io.File toJava(File self) {
		java.io.File jfile = (java.io.File)((LocalFile)self).jfile;
		return jfile;
	}

	public FileStore store() {
		FileStore fs = new FileStore();
		boolean spaceKnown = jfile.getTotalSpace() > 0;
		fs.totalSpace = spaceKnown ? jfile.getTotalSpace() : -1;
		fs.availSpace = spaceKnown ? jfile.getUsableSpace() : -1;
		fs.freeSpace = spaceKnown ? jfile.getFreeSpace() : -1;
		return fs;
	}

	public boolean exists() {
		return jfile.exists();
	}

	public long size() {
		if (jfile.isDirectory())
			return 0;
		return jfile.length();
	}

	public void modified(TimePoint time) {
		long t = time.toMillis();
		jfile.setLastModified(t);
	}

	public TimePoint modified() {
		long mills = jfile.lastModified();
		return TimePoint.fromMillis(mills);
	}

	public boolean isReadable() {
		return Files.isReadable(jfile.toPath());
	}

	public boolean isWritable() {
		return Files.isWritable(jfile.toPath());
	}

	public boolean isExecutable() {
		return Files.isExecutable(jfile.toPath());
	}

	public String osPath() {
		return jfile.getPath();
	}

	public List list() {
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

	public File normalize() {
		try {
			jfile = jfile.getCanonicalFile();
		} catch (IOException e) {
			jfile = jfile.getAbsoluteFile();
		}
		Uri uri = fileToUri(jfile, true);
		return make(jfile, uri, false);
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

		// try {
		// 	java.io.FileOutputStream out = new java.io.FileOutputStream(file);
		// 	out.close();
		// } catch (java.io.IOException e) {
		// 	throw IOErr.make(e);
		// }
		try {
			file.createNewFile();
		}
	    catch (java.io.IOException err)
	    {
	      throw IOErr.make("Cannot create: " + file, err);
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

	public File create() {
		if (this.isDir())
			createDir(jfile);
		else
			createFile(jfile);
		return this;
	}

	public File moveTo(File ato) {
		java.io.File file = jfile;

		if (file.isDirectory() != ato.isDir()) {
			if (file.isDirectory())
				throw ArgErr.make("moveTo must be dir `" + ato + "`");
			else
				throw ArgErr.make("moveTo must not be dir `" + ato + "`");
		}

		if (!(ato instanceof LocalFile))
			throw IOErr.make("Cannot move LocalFile to " + ato.typeof());

		java.io.File dest = (java.io.File) (((LocalFile) ato).jfile);

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

	public void delete() {
		deleteJFile(jfile);
	}

	static void deleteJFile(java.io.File jfile) {
		if (!jfile.exists()) return;
		
		if (jfile.isDirectory()) {
			java.io.File[] kids = jfile.listFiles();
			for (int i = 0; i < kids.length; ++i)
				deleteJFile(kids[i]);
		}
		
		try
	    {
	      // java.io.File has some issues on macOS (and Linux?) with
	      // broken symlinks; and will report they do not exist; use
	      // Files.deleteIfExists to cleanup properly
	      java.nio.file.Files.deleteIfExists(jfile.toPath());
	    }
	    catch (java.io.IOException err)
	    {
	      throw IOErr.make("Cannot delete: " + jfile, err);
	    }
	}

	public File deleteOnExit() {
		jfile.deleteOnExit();
		return this;
	}

	public InStream in() {
		return in(4096);
	}
	public InStream in(long bufferSize) {
		try {
			FileInputStream fin = new FileInputStream(jfile);
			return SysInStreamPeer.fromJava(fin, bufferSize);
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	public OutStream out() {
		return out(false);
	}
	public OutStream out(boolean append) {
		return out(append, 4096);
	}
	public OutStream out(boolean append, long bufferSize) {
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

	public Buf open() {
		return open("rw");
	}
	public Buf open(String mode) {
		return FileBuf.make(this, mode);
	}

	public Buf mmap() {
		return mmap("rw");
	}
	public Buf mmap(String mode) {
		return mmap(mode, 0);
	}
	public Buf mmap(String mode, long pos) {
		return mmap(mode, pos, this.size());
	}
	public Buf mmap(String mode, long pos, long size) {
		return NioBuf.fromFile(this, mode, pos, size);
	}
}
