package fan.std;

import fan.sys.IOErr;
import fan.sys.List;

public class FilePeer {
	static File make(Uri uri, boolean checkSlash) {
		String path = uri.pathStr;
		java.io.File jfile = new java.io.File(path);
	    if (jfile.isDirectory() && !checkSlash && !uri.isDir())
	      uri = uri.plusSlash();
	    return LocalFilePeer.make(jfile, uri);
	}
	
	static File make(Uri uri) {
		return make(uri, true);
	}
	
	static File os(String osPath) {
		return LocalFilePeer.make(osPath);
	}
	
	static List osRoots() {
		java.io.File[] roots = java.io.File.listRoots();
		List list = List.make(roots.length);
	    for (int i=0; i<roots.length; ++i) {
	      list.add(LocalFilePeer.make(roots[i]));
	    }
	    return list;
	}
	
	static File createTemp(String prefix, String suffix, File dir) {
		if (prefix == null || prefix.length() == 0) prefix = "fan";
	    if (prefix.length() == 1) prefix = prefix + "xx";
	    if (prefix.length() == 2) prefix = prefix + "x";

	    if (suffix == null) suffix = ".tmp";

	    java.io.File d = null;
	    if (dir != null)
	    {
	      if (!(dir instanceof LocalFile)) throw IOErr.make("Dir is not on local file system: " + dir);
	      d = LocalFilePeer.getJFile((LocalFile)dir);
	    }

	    try
	    {
	      return LocalFilePeer.make(java.io.File.createTempFile(prefix, suffix, d));
	    }
	    catch (java.io.IOException e)
	    {
	      throw IOErr.make(e);
	    }
	}
	
	static String sep() { return java.io.File.separator; }
	
	static String pathSep() { return java.io.File.pathSeparator; }
}
