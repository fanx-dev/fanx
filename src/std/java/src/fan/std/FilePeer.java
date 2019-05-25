package fan.std;

import fan.sys.ArgErr;
import fan.sys.Func;
import fan.sys.IOErr;
import fan.sys.List;

public class FilePeer {
	static File make(Uri uri, boolean checkSlash) {
		if (uri.scheme != null && !uri.scheme.equals("file")) {
			throw ArgErr.make("Invalid Uri scheme for local file: " + uri);
		}
		String path = uri.pathStr;
		java.io.File jfile = new java.io.File(path);
		if (jfile.isDirectory() && !checkSlash && !uri.isDir())
			uri = uri.plusSlash();
		return LocalFilePeer.make(jfile, uri, true);
	}

	static File make(Uri uri) {
		return make(uri, true);
	}

	static File os(String osPath) {
		return LocalFilePeer.fromJava(new java.io.File(osPath));
	}

	static List osRoots() {
		java.io.File[] roots = java.io.File.listRoots();
		List list = List.make(roots.length);
		for (int i = 0; i < roots.length; ++i) {
			list.add(LocalFilePeer.fromJava(roots[i]));
		}
		return list;
	}

	static File createTemp(String prefix, String suffix, File dir) {
		if (prefix == null || prefix.length() == 0)
			prefix = "fan";
		if (prefix.length() == 1)
			prefix = prefix + "xx";
		if (prefix.length() == 2)
			prefix = prefix + "x";

		if (suffix == null)
			suffix = ".tmp";

		java.io.File d = null;
		if (dir != null) {
			if (!(dir instanceof LocalFile))
				throw IOErr.make("Dir is not on local file system: " + dir);
			d = LocalFilePeer.toJava((LocalFile) dir);
		}

		try {
			return LocalFilePeer.fromJava(java.io.File.createTempFile(prefix, suffix, d));
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	static String sep() {
		return java.io.File.separator;
	}

	static String pathSep() {
		return java.io.File.pathSeparator;
	}

	static File plusNameOf(File self, File x) {
		String name = x.name();
		if (x.isDir())
			name += "/";
		return self.plus(Uri.fromStr(name));
	}
	

	static File copyTo(File self, File to, Map options) {
		// sanity
		if (self.isDir() != to.isDir()) {
			if (self.isDir())
				throw ArgErr.make("copyTo must be dir `" + to + "`");
			else
				throw ArgErr.make("copyTo must not be dir `" + to + "`");
		}

		// options
		Object exclude = null, overwrite = null;
		if (options != null) {
			exclude = options.get("exclude");
			overwrite = options.get("overwrite");
		}

		// recurse
		doCopyTo(self, to, exclude, overwrite);
		return to;
	}

	private static void doCopyTo(File self, File to, Object exclude, Object overwrite) {
		// check exclude
		//TODO
//		if (exclude instanceof Regex) {
//			if (((Regex) exclude).matches(uri.toStr()))
//				return;
//		} else 
		if (exclude instanceof Func) {
			if (((Func) exclude).callBool(self)) return;
		}

		// check for overwrite
		if (to.exists()) {
			if (overwrite instanceof Boolean) {
				if (!((Boolean) overwrite).booleanValue())
					return;
			} else if (overwrite instanceof Func) {
				if (!((Func) overwrite).callBool(to, self))
					return;
			} else {
				throw IOErr.make("No overwrite policy for `" + to + "`");
			}
		}

		// copy directory
		if (self.isDir()) {
			to.create();
			List kids = self.list();
			for (int i = 0; i < kids.size(); ++i) {
				File kid = (File) kids.get(i);
				doCopyTo(kid, FilePeer.plusNameOf(to, kid), exclude, overwrite);
			}
		}

		// copy file contents
		else {
			OutStream out = to.out();
			try {
				self.in().pipe(out);
			} finally {
				out.close();
			}
			copyPermissions(self, to);
		}
	}

	private static void copyPermissions(File from, File to) {
		// if both are LocaleFiles, try to hack the file
		// permissions until we get 1.7 support
		try {
			if (from instanceof LocalFile && to instanceof LocalFile) {
				java.io.File jfrom = (java.io.File) ((LocalFile)from).peer;
				java.io.File jto = (java.io.File) ((LocalFile)to).peer;
				jto.setReadable(jfrom.canRead(), false);
				jto.setWritable(jfrom.canWrite(), false);
				jto.setExecutable(jfrom.canExecute(), false);
			}
		} catch (NoSuchMethodError e) {
		} // ignore if not on 1.6
	}
}
