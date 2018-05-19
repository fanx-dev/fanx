package fan.std;

public class FilePeer {
	static File make(Uri uri, boolean checkSlash) {
		return null;
	}
	
	static File make(Uri uri) {
		return make(uri, true);
	}
	
	static File os(String osPath) {
		return null;
	}
	
	static File[] osRoots() {
		return null;
	}
	
	static File createTemp(String prefix, String suffix, File dir) {
		return null;
	}
	static File createTemp(String prefix, String suffix) {
		return createTemp(prefix, suffix, null);
	}
	static File createTemp(String prefix) {
		return createTemp(prefix, ".tmp", null);
	}
	static File createTemp() {
		return createTemp("fan", ".tmp", null);
	}
	
	static String sep() { return java.io.File.separator; }
	
	static String pathSep() { return java.io.File.pathSeparator; }
}
