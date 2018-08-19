package fanx.main;

import java.io.File;
import java.lang.ref.SoftReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fanx.fcode.FPod;
import fanx.fcode.FStore;
import fanx.fcode.FType;
import fanx.fcode.FTypeRef;
import fanx.util.FanUtil;
import fanx.util.Reflection;

public class Sys {

	public static final String TypeClassPathName = "fanx/main/Type";
	public static final String TypeClassDotName = "fanx.main.Type";
	public static final String TypeClassJsig = "L" + Sys.TypeClassPathName + ";";

	public static interface IEnv {
		public abstract FStore loadPod(String name);

		public abstract String platform();

		public abstract List<String> envPaths();

		public abstract List<String> listPodNames();

		public String os();

		public String arch();

		public String homeDir();

		public String workDir();

		public File getPodFile(String name, boolean checked);
	}

	public static IEnv env;
	private static Map<String, SoftReference<FPod>> pods = new HashMap<String, SoftReference<FPod>>();

	public static boolean isAndroid = false;
	static {
		try {
			Class.forName("android.app.Activity");
			isAndroid = true;
		} catch (Throwable e) {
			isAndroid = false;
		}

		// check FAN_ENV environment variable
		String var = System.getenv("FAN_SYS_ENV");
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
				throw makeErr("sys::ArgErr", signature);
			}
			return null;
		}
		String podName = signature.substring(0, pos);
		int pos2 = signature.indexOf('<');
		if (pos2 < 0)
			pos2 = signature.length();

		String typeName = signature.substring(pos + 2, pos2);
		
		if (podName.startsWith("[java]")) {
			Type t = JavaType.loadJavaType(podName, typeName);
			return t;
		}
		
		FType ftype = findFType(podName, typeName, checked);
		if (ftype == null)
			return null;
		Type res = Type.fromFType(ftype, signature);

		if (nullable) {
			return res.toNullable();
		}
		return res;
	}
	
	public static Type getTypeByRefId(FPod pod, int typeRefId) {
		FTypeRef ref = pod.typeRef(typeRefId);
		if (ref.podName.startsWith("[java]")) {
			Type t = JavaType.loadJavaType(ref.podName, ref.typeName);
			return t;
		}
		
		FType ft = Sys.findFType(ref.podName, ref.typeName);
		Type t = Type.fromFType(ft, ref.signature);
		if (ref.signature.endsWith("?")) {
			t = t.toNullable();
		}
		return t;
	}
	
	public static FType getFTypeByRefId(FPod pod, int typeRefId) {
		FTypeRef ref = pod.typeRef(typeRefId);
		if (ref.podName.startsWith("[java]")) {
			return null;
		}
		FType x = Sys.findFType(ref.podName, ref.typeName);
		return x;
	}

	private static FType findFType(String podName, String typeName) {
		return findFType(podName, typeName, true);
	}

	private static FType findFType(String podName, String typeName, boolean checked) {

		FPod pod = findPod(podName, checked);
		if (pod == null) {
			if (checked) {
				throw makeErr("sys::UnknownPodErr", podName);
			}
			return null;
		}
		FType type = pod.type(typeName, false);
		if (type == null) {
			if (typeName.indexOf('^') != -1) {
				return findFType("sys", "Obj", checked);
			}

			if (checked) {
				throw makeErr("sys::UnknownTypeErr", podName + "::" + typeName);
			}
		}
		return type;
	}

	public static FPod findPod(String podName) {
		return findPod(podName, true);
	}

	public static synchronized void addPod(FPod pod) {
		String podName = pod.podName;
		SoftReference<FPod> ref = pods.get(podName);
		if (ref != null && ref.get() != null)
			throw new RuntimeException("Duplicate pod name: " + podName);

		pods.put(podName, new SoftReference<FPod>(pod));
		if (pod.podClassLoader == null) {
			PodClassLoader cl = new PodClassLoader(pod);
			pod.podClassLoader = cl;
		}
	}

	public static RuntimeException makeErr(String qname, String msg) {
		Type type = findType(qname, false);
		if (type == null) {
			throw new RuntimeException("not found type:" + qname + ",msg:" + msg);
		}
		RuntimeException re = (RuntimeException) Reflection.callStaticMethod(type.getJavaActualClass(), "make", msg);
		return re;
	}

	public static synchronized FPod findPod(String podName, boolean checked) {
		try {
			SoftReference<FPod> sref = pods.get(podName);
			FPod pod = sref != null ? sref.get() : null;
			if (pod != null)
				return pod;

			FStore podStore = env.loadPod(podName);
			pod = new FPod(podName, podStore);
			pod.read();

			pods.put(podName, new SoftReference<FPod>(pod));

			PodClassLoader cl = new PodClassLoader(pod);
			pod.podClassLoader = cl;
			return pod;
		} catch (Exception e) {
			if (checked) {
				throw makeErr("sys::UnknownPodErr", podName);
			}
		}
		return null;
	}
}
