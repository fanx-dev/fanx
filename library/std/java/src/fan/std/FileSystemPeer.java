package fan.std;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

import fan.sys.ArgErr;
import fan.sys.IOErr;
import fan.sys.List;
import fanx.util.FileUtil;
import fanx.main.Sys;
import fanx.main.Type;

public class FileSystemPeer {
	static boolean exists(String path) {
		return new java.io.File(path).exists();
	}
	static long size(String path) {
		java.io.File jfile = new java.io.File(path);
		if (jfile.isDirectory())
			return 0;
		return jfile.length();
	}
	static long modified(String path) {
		java.io.File jfile = new java.io.File(path);
		long mills = jfile.lastModified();
		return mills;
	}
	static boolean setModified(String path, long time) {
		java.io.File jfile = new java.io.File(path);
		jfile.setLastModified(time);
		return true;
	}
	static String uriToPath(String uri) {
		String path = uri;
		java.io.File file = new java.io.File(path);
		return file.getPath();
	}
	static String pathToUri(String ospath) {
		return FileUtil.osPahtToUri(ospath, true);
	}
	static List list(String path) {
		java.io.File jfile = new java.io.File(path);
		java.io.File[] ls = jfile.listFiles();
		if (ls == null) {
			return List.defVal;
		}
		List res = List.make(ls.length);
		for (java.io.File f : ls) {
			res.add(f.getPath());
		}
		return res;
	}
	static String normalize(String path) {
		java.io.File jfile = new java.io.File(path);
		try {
			jfile = jfile.getCanonicalFile();
		} catch (IOException e) {
			jfile = jfile.getAbsoluteFile();
		}
		return jfile.getPath();
	}
	static boolean createDirs(String path) {
		java.io.File file = new java.io.File(path);
		if (file.exists()) {
			if (!file.isDirectory())
				throw IOErr.make("Already exists as file: " + file);
		} else {
			if (!file.mkdirs())
				throw IOErr.make("Cannot create dir: " + file);
		}
		return true;
	}
	static boolean createFile(String path) {
		java.io.File file = new java.io.File(path);
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
			file.createNewFile();
			return true;
		}
	    catch (java.io.IOException err)
	    {
	      throw IOErr.make("Cannot create: " + file, err);
	    }
	}
	static boolean moveTo(String path, String to) {
		java.io.File file = new java.io.File(path);
		java.io.File ato = new java.io.File(to);

		if (file.isDirectory() != ato.isDirectory()) {
			if (file.isDirectory())
				throw ArgErr.make("moveTo must be dir `" + ato + "`");
			else
				throw ArgErr.make("moveTo must not be dir `" + ato + "`");
		}

		// if (!(ato instanceof LocalFile))
		// 	throw IOErr.make("Cannot move LocalFile to " + ato.typeof());

		java.io.File dest = ato;

		if (dest.exists())
			throw IOErr.make("moveTo already exists: " + ato);

		if (!file.isDirectory()) {
			java.io.File destParent = ato.getParentFile();
			if (destParent != null && !destParent.exists())
				destParent.mkdirs();
		}

		if (!file.renameTo(dest))
			throw IOErr.make("moveTo failed: " + ato);

		return true;
	}
	static boolean copyTo(String path, String to) {
		try {
			Files.copy(Paths.get(path), Paths.get(to),
				java.nio.file.StandardCopyOption.REPLACE_EXISTING,
				java.nio.file.StandardCopyOption.COPY_ATTRIBUTES);
			return true;
		}
	    catch (java.io.IOException err)
	    {
	        return false;
	    }
	}
	static boolean delete(String path) {
		java.io.File jfile = new java.io.File(path);
		if (!jfile.exists()) return true;
		
		if (jfile.isDirectory()) {
			java.io.File[] kids = jfile.listFiles();
			for (int i = 0; i < kids.length; ++i)
				delete(kids[i].getPath());
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
	    return true;
	}
	static boolean deleteOnExit(String path) {
		java.io.File jfile = new java.io.File(path);
		jfile.deleteOnExit();
		return true;
	}
	static boolean isReadable(String path) {
		java.io.File jfile = new java.io.File(path);
		return Files.isReadable(jfile.toPath());
	}
	static boolean isWritable(String path) {
		java.io.File jfile = new java.io.File(path);
		return Files.isWritable(jfile.toPath());
	}
	static boolean isExecutable(String path) {
		java.io.File jfile = new java.io.File(path);
		return Files.isExecutable(jfile.toPath());
	}
	static boolean isDir(String path) {
		java.io.File jfile = new java.io.File(path);
		return jfile.isDirectory();
	}
	
	private static String _tempDir;
	static String tempDir() {
		if (_tempDir == null) {
			try {
				java.io.File tempFile = java.io.File.createTempFile("temp", null);
				_tempDir = tempFile.getParent();
			}
		    catch (java.io.IOException err)
		    {
		      	//throw IOErr.make("Cannot create tempDir", err);
		      	err.printStackTrace();
		      	java.io.File baseDir = new java.io.File(System.getProperty("java.io.tmpdir"));
		      	_tempDir = baseDir.getPath();
		    }
		}
		return _tempDir;
	}
	static List osRoots() {
		java.io.File[] roots = java.io.File.listRoots();
		List list = List.make(roots.length);
		for (int i = 0; i < roots.length; ++i) {
			list.add(roots[i].getPath());
		}
		return list;
	}
	static boolean getSpaceInfo(String path, long[] out) {
		java.io.File jfile = new java.io.File(path);
		boolean spaceKnown = jfile.getTotalSpace() > 0;
		out[0] = spaceKnown ? jfile.getTotalSpace() : -1;
		out[1] = spaceKnown ? jfile.getUsableSpace() : -1;
		out[2] = spaceKnown ? jfile.getFreeSpace() : -1;
		return true;
	}

	static String fileSep() { return java.io.File.separator; }
	static String pathSep() { return java.io.File.pathSeparator; }
}
