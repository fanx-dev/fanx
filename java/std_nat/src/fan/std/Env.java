package fan.std;

import java.lang.management.ClassLoadingMXBean;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;
import java.util.Iterator;

import fan.sys.ArgErr;
import fan.sys.Err;
import fan.sys.FanObj;
import fan.sys.Func;
import fan.sys.List;
import fan.sys.NotImmutableErr;
import fan.sys.UnknownPodErr;
import fan.sys.UnresolvedErr;
import fanx.main.BootEnv;
import fanx.main.EnvIndex;
import fanx.main.Sys;
import fanx.main.Type;

public class Env extends FanObj {

	String host = initHost();
	String user = initUser();
	InStream in;
	OutStream out;
	OutStream err;

	public static Env cur = new Env();

	//////////////////////////////////////////////////////////////////////////
	// Construction
	//////////////////////////////////////////////////////////////////////////

	public Sys.IEnv sysEnv() {
		return Sys.env;
	}

	public static Env cur() {
		return cur;
	}

	public static void make$(Env self) {
	}

	public Env() {
		in = SysInStreamPeer.fromJava(System.in, 0);
		out = SysOutStreamPeer.fromJava(System.out, 0);
		err = SysOutStreamPeer.fromJava(System.err, 0);
	}

	public String host() {
		return host;
	}

	public String user() {
		return user;
	}

	public InStream in() {
		return in;
	}

	public OutStream out() {
		return out;
	}

	public OutStream err() {
		return err;
	}

	//////////////////////////////////////////////////////////////////////////
	// Obj
	//////////////////////////////////////////////////////////////////////////

	private static Type type = null;

	public Type typeof() {
		if (type == null)
			type = Sys.findType("std::Env");
		return type;
	}

	public String toStr() {
		return typeof().toString();
	}

	//////////////////////////////////////////////////////////////////////////
	// Non-Virtuals
	//////////////////////////////////////////////////////////////////////////

	// public final Env parent() { return parent; }

	public final String os() {
		return sysEnv().os();
	}

	public final String arch() {
		return sysEnv().arch();
	}

	public final String platform() {
		return sysEnv().platform();
	}

	public final String runtime() {
		return "java";
	}

	public final long idHash(Object obj) {
		return System.identityHashCode(obj);
	}

	//////////////////////////////////////////////////////////////////////////
	// Virtuals
	//////////////////////////////////////////////////////////////////////////
	List args = initArgs();

	public List args() {
		return args;
	}

	public List initArgs() {
		List args = List.make(BootEnv.args.length);
		for (String a : BootEnv.args) {
			args.add(a);
		}
		return (List) args.toImmutable();
	}

	// public Method mainMethod() { return parent.mainMethod(); }

	Map vars = initVars();
	
	public Map vars()  { return vars; }

	private static Map initVars() {
		Map vars = CIMap.make(64);
		try {
			// environment variables
			java.util.Map getenv = System.getenv();
			Iterator it = getenv.keySet().iterator();
			while (it.hasNext()) {
				String key = (String) it.next();
				String val = (String) getenv.get(key);
				vars.set(key, val);
			}

			// Java system properties
			it = System.getProperties().keySet().iterator();
			while (it.hasNext()) {
				String key = (String) it.next();
				String val = System.getProperty(key);
				vars.set(key, val);
			}
		} catch (Throwable e) {
			e.printStackTrace();
		}
		return (Map) vars.toImmutable();
	}

	private static String initHost() {
		try {
			return java.net.InetAddress.getLocalHost().getHostName();
		} catch (Throwable e) {
		}

		try {
			// fallbacks if DNS resolution fails
			String s;
			s = System.getenv("HOSTNAME");
			if (s != null)
				return s;
			s = System.getenv("FAN_HOSTNAME");
			if (s != null)
				return s;
		} catch (Throwable e) {
		}

		return "unknown";
	}

	private static String initUser() {
		return System.getProperty("user.name", "unknown");
	}

	public Map diagnostics() {
		Map d = Map.make(100);

		// memory
		MemoryMXBean mem = ManagementFactory.getMemoryMXBean();
		d.add("mem.heap", Long.valueOf(mem.getHeapMemoryUsage().getUsed()));
		d.add("mem.nonHeap", Long.valueOf(mem.getNonHeapMemoryUsage().getUsed()));

		// threads
		ThreadMXBean thread = ManagementFactory.getThreadMXBean();
		long[] threadIds = thread.getAllThreadIds();
		d.add("thread.size", Long.valueOf(threadIds.length));
		for (int i = 0; i < threadIds.length; ++i) {
			ThreadInfo ti = thread.getThreadInfo(threadIds[i]);
			if (ti == null)
				continue;
			d.add("thread." + i + ".name", ti.getThreadName());
			d.add("thread." + i + ".state", ti.getThreadState().toString());
			d.add("thread." + i + ".cpuTime", Duration.make(thread.getThreadCpuTime(threadIds[i])));
		}

		// class loading
		ClassLoadingMXBean cls = ManagementFactory.getClassLoadingMXBean();
		d.add("classes.loaded", Long.valueOf(cls.getLoadedClassCount()));
		d.add("classes.total", Long.valueOf(cls.getTotalLoadedClassCount()));
		d.add("classes.unloaded", Long.valueOf(cls.getUnloadedClassCount()));

		return d;
	}

	public void gc() {
		System.gc();
	}

	//////////////////////////////////////////////////////////////////////////
	// Prompt JLine
	//////////////////////////////////////////////////////////////////////////
	private Object jline; // null, Throwable, ConsoleReader

	public String prompt() {
		return this.prompt("");
	}

	public String promptPassword() {
		return this.promptPassword("");
	}

	public String prompt(String msg) {
		// attempt to initilize JLine and if we can't fallback to Java API
		if (!jlineInit()) {
			java.io.Console console = System.console();
			if (console == null)
				return promptStdIn(msg);
			return console.readLine(msg);
		}

		// use reflection to call JLine ConsoleReader.readLine
		try {
			return (String) jline.getClass().getMethod("readLine", new Class[] { String.class }).invoke(jline,
					new Object[] { msg });
		} catch (Exception e) {
			throw Err.make(e);
		}
	}

	public String promptPassword(String msg) {
		// attempt to initilize JLine and if we can't fallback to Java API
		if (!jlineInit()) {
			java.io.Console console = System.console();
			if (console == null)
				return promptStdIn(msg);
			char[] pass = console.readPassword(msg);
			if (pass == null)
				return null;
			return new String(pass);
		}

		// use reflection to call JLine ConsoleReader.readLine
		try {
			return (String) jline.getClass().getMethod("readLine", new Class[] { String.class, Character.class })
					.invoke(jline, new Object[] { msg, Character.valueOf('#') });
		} catch (Exception e) {
			throw Err.make(e);
		}
	}

	private boolean jlineInit() {
		if (jline == null) {
			// use reflection to see if jline.console.ConsoleReader
			// is available in classpath
			try {
				// jline = new ConsoleReader()
				Class cls = Class.forName("jline.console.ConsoleReader");
				jline = cls.getConstructor(new Class[] {}).newInstance();
			} catch (Throwable e) {
				jline = e;
			}
		}
		return !(jline instanceof Throwable);
	}

	private String promptStdIn(String msg) {
		try {
			out().print(msg).flush();
			return new java.io.BufferedReader(new java.io.InputStreamReader(System.in)).readLine();
		} catch (Exception e) {
			throw Err.make(e);
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Exit and Shutdown Hooks
	//////////////////////////////////////////////////////////////////////////

	public void exit() {
		this.exit(0);
	}

	public void exit(long status) {
		System.exit((int) status);
	}

	private final java.util.HashMap shutdownHooks = new java.util.HashMap(); // Func
																				// =>
																				// Thread

	public void addShutdownHook(Func f) {
		if (!f.isImmutable())
			throw NotImmutableErr.make();
		Thread thread = new ShutdownHookThread(f);
		shutdownHooks.put(f, thread);
		Runtime.getRuntime().addShutdownHook(thread);
	}

	public boolean removeShutdownHook(Func f) {
		Thread thread = (Thread) shutdownHooks.get(f);
		if (thread == null)
			return false;
		return Runtime.getRuntime().removeShutdownHook(thread);
	}

	static class ShutdownHookThread extends Thread {
		ShutdownHookThread(Func func) {
			this.func = func;
		}

		public void run() {
			try {
				func.call();
			} catch (Throwable e) {
				e.printStackTrace();
			}
		}

		private final Func func;
	}

	//////////////////////////////////////////////////////////////////////////
	// Resolution
	//////////////////////////////////////////////////////////////////////////

	File homeDir = File.make(Uri.fromStr(sysEnv().homeDir()));

	public File homeDir() {
		return homeDir;
	}

	File workDir = File.make(Uri.fromStr(sysEnv().workDir()));

	public File workDir() {
		return workDir;
	}

	File tempDir = workDir.plus(Uri.fromStr("temp/"), false);

	public File tempDir() {
		return tempDir;
	}

	public File findFile(Uri uri) {
		return findFile(uri, true);
	}

	public File findFile(Uri uri, boolean checked) {
		if (uri.isPathAbs())
			throw ArgErr.make("Uri must be relative: " + uri);
		java.util.List<String> envPaths = sysEnv().envPaths();
		for (String p : envPaths) {
			File f = File.make(Uri.fromStr(p).plus(uri), false);
			if (f.exists()) {
				return f;
			}
		}
		if (!checked)
			return null;
		throw UnresolvedErr.make("File not found in Env: " + uri);
	}

	public List findAllFiles(Uri uri) {
		if (uri.isPathAbs())
			throw ArgErr.make("Uri must be relative: " + uri);
		java.util.List<String> envPaths = sysEnv().envPaths();
		List list = List.make(envPaths.size());
		for (String p : envPaths) {
			File f = File.make(Uri.fromStr(p).plus(uri));
			if (f.exists())
				list.add(f);
		}
		return list;
	}

	public File findPodFile(String name) {
		java.io.File jfile = sysEnv().getPodFile(name);
		File file = LocalFilePeer.fromJava(jfile);

		// verify case since Windoze is case insensitive
		String actualName = file.normalize().name();
		if (!actualName.equals(name + ".pod"))
			throw UnknownPodErr.make("Case mismatch: expected '" + name + ".pod' but found '" + actualName + "'");
		return file;
	}

	public List findAllPodNames() {
		List acc = List.make(64);
		java.util.List<String> files = sysEnv().listPodFiles();
		for (int i = 0; i < files.size(); ++i) {
			String f = (String) files.get(i);

			File file = File.make(Uri.fromStr(f), false);
			acc.add(file.basename());
		}
		return acc;
	}
	
	

	private Map index;
	private List keys;
	
	synchronized void onPodReload() {
	    index = null;
	    keys = null;
	}
	
	private void loadIndex() {
		java.util.Map<String, java.util.List<String>> jmap = EnvIndex.load();
		Map map = Map.make();
		for (java.util.Map.Entry<String, java.util.List<String>> e : jmap.entrySet()) {
			java.util.List<String> jlst = e.getValue();
			List v = List.make(jlst.size());
			for (String t : jlst) {
				v.add(t);
			}
			v = (List)v.toImmutable();
			map.set(e.getKey(), v);
		}
		index = map;
		keys = (List)map.keys().toImmutable();
	}

	public synchronized List index(String key) {
		if (index == null) {
			loadIndex();
		}
		
		List list = (List)index.get(key);
		if (list == null) list = List.defVal;
		return list;
	}

	public synchronized List indexKeys() {
		if (keys == null) loadIndex();
		return keys;
	}

}
