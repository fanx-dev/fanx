package fanx.main;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fanx.fcode.FPod;
import fanx.fcode.FStore;
import fanx.fcode.FType;
import fanx.util.Reflection;

public class Sys {

	public static final String TypeClassPathName = "fanx/main/Type";
	public static final String TypeClassDotName = "fanx.main.Type";
	public static final String TypeClassJsig = "L" + Sys.TypeClassPathName + ";";

	public static interface IEnv {
		public abstract FStore loadPod(String name);

		public abstract String platform();

		public abstract List<String> envPaths();

		public abstract List<String> listPodFiles();

		public String os();

		public String arch();

		public String homeDir();

		public String workDir();

		public File getPodFile(String name);
	}

	public static IEnv env;
	private static Map<String, FPod> pods = new HashMap<String, FPod>();

	public static boolean isAndroid = false;
	static {
		try {
			Class.forName("android.app.Activity");
			isAndroid = true;
		} catch (Throwable e) {
			isAndroid = false;
		}

		// check FAN_ENV environment variable
		String var = System.getenv("FAN_ENV");
		if (var != null) {
			try {
				env = (IEnv) Class.forName(var).newInstance();
			} catch (InstantiationException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		if (env == null) {
			env = new BootEnv();
		}
	}

	public static Type findType(String signature) {
		return findType(signature, true);
	}

	public static Type findType(String signature, boolean checked) {
		int len = signature.length();
		boolean nullable = false;
		if (signature.charAt(len - 1) == '?') {
			nullable = true;
			signature = signature.substring(0, len - 1);
		}

		int pos = signature.indexOf("::");
		if (pos <= 0 || pos >= len - 2) {
			if (checked) {
				Type etype = findType("sys::ArgErr");
				RuntimeException re = (RuntimeException) Reflection.callStaticMethod(etype.getJavaActualClass(), "make",
						signature);
				throw re;
			}
			return null;
		}
		String podName = signature.substring(0, pos);
		int pos2 = signature.indexOf('<');
		if (pos2 < 0)
			pos2 = signature.length();

		String typeName = signature.substring(pos + 2, pos2);
		FType ftype = findFType(podName, typeName, checked);
		if (ftype == null)
			return null;
		Type res = Type.fromFType(ftype, signature);

		if (nullable) {
			return res.toNullable();
		}
		return res;
	}

	public static FType findFType(String podName, String typeName) {
		return findFType(podName, typeName, true);
	}

	public static FType findFType(String podName, String typeName, boolean checked) {
		FPod pod = findPod(podName, checked);
		FType type = pod.type(typeName, false);
		if (type == null) {
			if (typeName.indexOf('^') != -1) {
				return findFType("sys", "Obj", checked);
			}

			if (checked) {
				Type etype = findType("sys::UnknownTypeErr");
				RuntimeException re = (RuntimeException) Reflection.callStaticMethod(etype.getJavaActualClass(), "make",
						podName + "::" + typeName);
				throw re;
			}
		}
		return type;
	}

	public static FPod findPod(String podName) {
		return findPod(podName, true);
	}

	public static FPod findPod(String podName, boolean checked) {
		try {
			synchronized (Sys.class) {
				FPod p = pods.get(podName);
				if (p != null)
					return p;

				FStore podStore = env.loadPod(podName);
				FPod pod = new FPod(podName, podStore);
				pod.read();

				pods.put(podName, pod);

				PodClassLoader cl = new PodClassLoader(pod);
				pod.podClassLoader = cl;
				return pod;
			}
		} catch (Exception e) {
			if (checked) {
				Type type = findType("sys::UnknownPodErr");
				RuntimeException re = (RuntimeException) Reflection.callStaticMethod(type.getJavaActualClass(), "make",
						podName);
				throw re;
			}
		}
		return null;
	}

}
