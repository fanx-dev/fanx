package fanx.main;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fanx.fcode.FPod;
import fanx.fcode.FType;

public class Sys {
	
	public static final String TypeClassPathName = "fanx/main/Type";
	public static final String TypeClassDotName = "fanx.main.Type";
	public static final String TypeClassJsig = "L"+Sys.TypeClassPathName+";";

	public static String[] args;
	
	public static String homeDir = initHomeDir();
	public static String workDir = homeDir;
	
	public static String os = initOs();
	public static String arch = initArch();
	public static String platform = os + "_" + arch;
	public static String host = initHost();
	public static String user = initUser();
	
	private static String initHomeDir() {
		homeDir = System.getenv("FAN_HOME");
		if (homeDir == null) {
			homeDir = "/Users/yangjiandong/workspace/fantom/final/";
		}
		return homeDir;
	}
	
	private static Map<String, FPod> pods = new HashMap<String, FPod>();
	
	
	public static Type findType(String signature, boolean checked) {
		return findType(signature);
	}
	
	public static Type findType(String signature) {
		int len = signature.length();
		boolean nullable = false;
		if (signature.charAt(len-1) == '?') {
			nullable = true;
			signature = signature.substring(0, len-1);
		}
		
		int pos = signature.indexOf("::");
		String podName = signature.substring(0, pos);
		int pos2 = signature.lastIndexOf('<');
		if (pos2 < 0) pos2 = signature.length();
		String typeName = signature.substring(pos+2, pos2);
		FType ftype = findFType(podName, typeName);
		Type res = Type.fromFType(ftype, signature);
		
		if (nullable) {
			return res.toNullable();
		}
		return res;
	}
	
	public static FType findFType(String podName, String typeName) {
		FPod pod = findPod(podName);
		return pod.type(typeName);
	}

	public static FPod findPod(String podName) {
		try {
			synchronized(Sys.class) {
				FPod p = pods.get(podName);
				if (p != null) return p;
				
				File podFile = getPodFile(podName);
				FPod pod = FPod.fromFile(podName, podFile);
				
				pods.put(podName, pod);
				
				PodClassLoader cl = new PodClassLoader(pod);
				pod.podClassLoader = cl;
				return pod;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	private static File getPodFile(String name) {
		String p = workDir + "lib/fan/" + name + ".pod";
		File f = new File(p);
		if (f.exists())
			return f;
		p = homeDir + "lib/fan/" + name + ".pod";
		f = new File(p);
		if (f.exists())
			return f;
		throw new RuntimeException("Pod not found:" + name);
	}

	public static List<String> listPod() {
		List<String> classPath = new ArrayList<String>();
		classPath.add(homeDir + "lib/fan/");
		classPath.add(workDir + "lib/fan/");
		
		List<String> pods = new ArrayList<String>();
		for (String p : classPath) {
			File f = new File(p);
			File[] fs = f.listFiles(new FilenameFilter() {
				@Override
				public boolean accept(File dir, String name) {
					if (name.endsWith(".pod"))
						return true;
					return false;
				}
			});
			for (File pf : fs) {
				pods.add(pf.getPath());
			}
		}
		return pods;
	}
	

	  private static String initOs()
	  {
	    try
	    {
	      String os = System.getProperty("os.name", "unknown");
	      os = sanitize(os);
	      if (os.contains("win"))   return "win32";
	      if (os.contains("mac"))   return "macosx";
	      if (os.contains("sunos")) return "solaris";
	      return os;
	    }
	    catch (Throwable e)
	    {
	      throw new RuntimeException("os", e);
	    }
	  }

	  private static String initArch()
	  {
	    try
	    {
	      String arch = System.getProperty("os.arch", "unknown");
	      arch = sanitize(arch);
	      if (arch.contains("i386"))  return "x86";
	      if (arch.contains("amd64")) return "x86_64";
	      return arch;
	    }
	    catch (Throwable e)
	    {
	      throw new RuntimeException("arch", e);
	    }
	  }

	  private static String sanitize(String s)
	  {
	    StringBuilder buf = new StringBuilder();
	    for (int i=0; i<s.length(); ++i)
	    {
	      int c = s.charAt(i);
	      if (c == '_') { buf.append((char)c); continue; }
	      if ('a' <= c && c <= 'z') { buf.append((char)c); continue; }
	      if ('0' <= c && c <= '9') { buf.append((char)c); continue; }
	      if ('A' <= c && c <= 'Z') { buf.append((char)(c | 0x20)); continue; }
	      // skip it
	    }
	    return buf.toString();
	  }
	  
	  private static String initHost()
	  {
	    try
	    {
	      return java.net.InetAddress.getLocalHost().getHostName();
	    }
	    catch (Throwable e) {}

	    try
	    {
	      // fallbacks if DNS resolution fails
	      String s;
	      s = System.getenv("HOSTNAME");     if (s != null) return s;
	      s = System.getenv("FAN_HOSTNAME"); if (s != null) return s;
	    }
	    catch (Throwable e) {}

	    return "unknown";
	  }

	  private static String initUser()
	  {
	    return System.getProperty("user.name", "unknown");
	  }
}
