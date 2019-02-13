package fanx.main;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import fanx.fcode.FStore;
import fanx.main.Sys.IEnv;

public class BootEnv implements IEnv {

	String os = initOs();
	String arch = initArch();
	String platform = os + "-" + arch;

	List<String> envPaths;
	String homeDir;

	public static String[] args;
	
	private static void checkSlash(String dir) {
		if (dir.charAt(dir.length()-1) != '/') {
			throw new IllegalArgumentException("Dir must ends with slash: "+ dir);
		}
	}

	public BootEnv() {
		homeDir = System.getProperty("fan.home");
		if (homeDir == null) {
			homeDir = System.getenv("FAN_HOME");
			if (homeDir == null) {
				throw new NullPointerException("ERROR: Not set fan.home");
			}
		}
		
		if (os.startsWith("win")) {
			homeDir = homeDir.replace("\\", "/");
		}
		checkSlash(homeDir);
		
		envPaths = new ArrayList<String>(4);

		String workDirs = System.getenv("FAN_ENV_PATH");
		if (workDirs != null && workDirs.length() > 0) {
			String[] paths = workDirs.split(File.pathSeparator);
			for (String p : paths) {
				checkSlash(p);
				envPaths.add(p);
			}
		}
		envPaths.add(homeDir);
	}

	public String os() {
		return os;
	}

	public String arch() {
		return arch;
	}

	@Override
	public String platform() {
		return platform;
	}

	private static String initOs() {
		try {
			String os = System.getProperty("os.name", "unknown");
			os = sanitize(os);
			if (os.contains("win"))
				return "win32";
			if (os.contains("mac"))
				return "macosx";
			if (os.contains("sunos"))
				return "solaris";
			return os;
		} catch (Throwable e) {
			throw new RuntimeException("os", e);
		}
	}

	private static String initArch() {
		try {
			String arch = System.getProperty("os.arch", "unknown");
			arch = sanitize(arch);
			if (arch.contains("i386"))
				return "x86";
			if (arch.contains("amd64"))
				return "x86_64";
			return arch;
		} catch (Throwable e) {
			throw new RuntimeException("arch", e);
		}
	}

	private static String sanitize(String s) {
		StringBuilder buf = new StringBuilder();
		for (int i = 0; i < s.length(); ++i) {
			int c = s.charAt(i);
			if (c == '_') {
				buf.append((char) c);
				continue;
			}
			if ('a' <= c && c <= 'z') {
				buf.append((char) c);
				continue;
			}
			if ('0' <= c && c <= '9') {
				buf.append((char) c);
				continue;
			}
			if ('A' <= c && c <= 'Z') {
				buf.append((char) (c | 0x20));
				continue;
			}
			// skip it
		}
		return buf.toString();
	}

	public String homeDir() {
		return homeDir;
	}
	
	public String workDir() {
		return envPaths.get(0);
	}

	@Override
	public List<String> envPaths() {
		return envPaths;
	}

	public File getPodFile(String name, boolean checked) {
		for (String p : envPaths) {
			p = p + "lib/fan/" + name + ".pod";
			File f = new File(p);
			if (f.exists())
				return f;
		}
		
		if (checked) throw new RuntimeException("Pod not found:" + name);
		return null;
	}

	@Override
	public List<String> listPodNames() {
		List<String> pods = new ArrayList<String>();
		HashMap<String, String> map = new HashMap<String, String>();
		for (String p : envPaths) {
			File f = new File(p + "lib/fan");
			File[] fs = f.listFiles(new FilenameFilter() {
				@Override
				public boolean accept(File dir, String name) {
					if (name.endsWith(".pod"))
						return true;
					return false;
				}
			});
			if (fs == null) continue;
			for (File pf : fs) {
				String name = pf.getName();
				int pos = name.lastIndexOf(".");
				if (pos > 0) {
					name = name.substring(0, pos);
				}
				if (map.containsKey(name)) continue;
				map.put(name, pf.getPath());
				pods.add(name);
			}
		}
		return pods;
	}

	@Override
	public FStore loadPod(String name, boolean checked) {
		try {
			File podFile = getPodFile(name, checked);
			if (!checked && podFile == null) return null;
			FStore podStore = FStore.makeZip(podFile);
			return podStore;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

}
