package fanx.main;

import java.io.File;
import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodType;
import java.lang.ref.SoftReference;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import fanx.fcode.FPod;
import fanx.fcode.FStore;
import fanx.fcode.FType;
import fanx.fcode.FTypeRef;
import fanx.util.Reflection;

public class Sys {

	public static final String TypeClassPathName = "fanx/main/Type";
	public static final String TypeClassDotName = "fanx.main.Type";
	public static final String TypeClassJsig = "L" + Sys.TypeClassPathName + ";";

	public static interface IEnv {
		public abstract FStore loadPod(String name, boolean checked);

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

//	public static boolean isAndroid = false;
	static {
//		try {
//			Class.forName("android.app.Activity");
//			isAndroid = true;
//		} catch (Throwable e) {
//			isAndroid = false;
//		}

		// check FAN_ENV environment variable
		String var = getPropOrEnv("fan.sys.env", "FAN_SYS_ENV");
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
	
	static String getPropOrEnv(String propKey, String envKey) {
		// lookup system property
		String val = System.getProperty(propKey);
		// fallback to environment variable
		if (val == null)
			val = System.getenv(envKey);
		if (val == null)
			val = System.getenv(envKey.toLowerCase());
		return val;
	}

	public static Type findType(String signature) {
		return findType(signature, true);
	}

	public static Type findType(String signature, boolean checked) {
		String str = signature;
		if (str.length() < 1) {
			throw makeErr("sys::ArgErr", signature);
		}
		
		if (str.charAt(str.length() - 1) == '?') {
			str = str.substring(0, str.length() - 1);
			Type nonNull = findType(str, checked);
			return nonNull.toNullable();
		}
		
		String ffi = null;
		if (str.charAt(0) == '[') {
			int p = str.indexOf(']');
			if (p < 0) throw makeErr("sys::ArgErr", signature);
			ffi = str.substring(1, p);
		}
		
		int pos = str.indexOf("::");
		if (pos < 0 || pos >= str.length()-2) {
			if (checked) {
				throw makeErr("sys::ArgErr", signature);
			}
//			System.out.println("ERROR1:"+signature);
			return null;
		}
		String podName = str.substring(0, pos);
		int pos2 = str.indexOf('<');
		if (pos2 < 0)
			pos2 = str.length();

		String typeName = str.substring(pos + 2, pos2);

		if (ffi != null) {
			if ("java".equals(ffi)) {
				Type t = JavaType.loadJavaType(null, podName, typeName);
				return t;
			}
			throw makeErr("sys::ArgErr", str);
		}
		
		if (podName.length() == 0) {
			if (checked) {
				throw makeErr("sys::ArgErr", signature);
			}
			return null;
		}
		
		FType ftype = findFType(podName, typeName, checked);
		if (ftype == null) {
//			System.out.println("ERROR2:"+signature);
			return null;
		}
		Type res = Type.fromFType(ftype, str);
		return res;
	}
	
	public static Type getTypeByRefId(FPod pod, int typeRefId) {
		FTypeRef ref = pod.typeRef(typeRefId);
		if (ref.podName.startsWith("[java]")) {
			Type t = JavaType.loadJavaType(pod.podClassLoader, ref.podName, ref.typeName);
			if (ref.signature.endsWith("?")) {
				t = t.toNullable();
			}
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

	public static FType findFType(String podName, String typeName, boolean checked) {

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
			
			if (podName.equals("sys")) {
				if (typeName.equals("Int8") || typeName.equals("Int16") ||
						typeName.equals("Int32")  || typeName.equals("Int64") ) {
					return findFType("sys", "Int", checked);
				}
				else if (typeName.equals("Float32")  || typeName.equals("Float64") ) {
					return findFType("sys", "Float", checked);
				}
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
		SoftReference<FPod> sref = pods.get(podName);
		FPod pod = sref != null ? sref.get() : null;
		if (pod != null)
			return pod;

		FStore podStore = env.loadPod(podName, false);
		if (podStore == null) {
			if (checked) throw makeErr("sys::UnknownPodErr", "not found pod:"+podName);
			return null;
		}
		
		try {
			pod = new FPod(podName, podStore);
			pod.read();

			pods.put(podName, new SoftReference<FPod>(pod));

			PodClassLoader cl = new PodClassLoader(pod);
			pod.podClassLoader = cl;
			return pod;
		} catch (Exception e) {
			if (checked) {
				e.printStackTrace();
				throw makeErr("sys::UnknownPodErr", "bad pod file:"+podName);
			}
		}
		
		return null;
	}
	
	public static MethodHandle findMethodHandle(Class cls) throws Exception {
		MethodHandles.Lookup lookup = MethodHandles.lookup();
		Method[] mths = cls.getDeclaredMethods();
		Method mth = null;
		for (Method f : mths) {
			if (f.getName().equals("doCall")) {
				mth = f;
				break;
			}
		}
		
		if (mth == null) {
			System.out.println("method not found:" + cls.getName() + ", " + Arrays.toString(mths));
		}
		
		MethodHandle mh = lookup.unreflect(mth);
		return mh;
	}
}
