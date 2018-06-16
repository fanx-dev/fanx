package fan.std;

import fan.sys.*;
import fanx.main.*;

public class Env extends FanObj {
	static Env cur = new Env();

	//////////////////////////////////////////////////////////////////////////
	// Construction
	//////////////////////////////////////////////////////////////////////////

	public static Env cur() {
		return cur;
	}

	public static void make$(Env self) {
	}

	public Env() {
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
		return Sys.os;
	}

	public final String arch() {
		return Sys.arch;
	}

	public final String platform() {
		return Sys.platform;
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
	List args;

	public List args() {
		return args;
	}

	// public Method mainMethod() { return parent.mainMethod(); }

	Map vars;

	public Map vars() {
		return vars;
	}

	Map diagnostics;

	public Map diagnostics() {
		return diagnostics;
	}

	public void gc() {
		System.gc();
	}

	public String host() {
		return Sys.host;
	}

	public String user() {
		return Sys.user;
	}

	public InStream in() {
		return SysInStreamPeer.make(System.in, 0);
	}

	public OutStream out() {
		return SysOutStreamPeer.make(System.out, 0);
	}

	public OutStream err() {
		return SysOutStreamPeer.make(System.err, 0);
	}

	//////////////////////////////////////////////////////////////////////////
	// Prompt JLine
	//////////////////////////////////////////////////////////////////////////
	private Object jline;  // null, Throwable, ConsoleReader
	
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

	File homeDir = File.make(Uri.fromStr(Sys.homeDir));
	public File homeDir() {
		return homeDir;
	}
	File workDir = File.make(Uri.fromStr(Sys.workDir));
	public File workDir() {
		return workDir;
	}

	File tempDir = homeDir.plus(Uri.fromStr("temp/"), false);
	public File tempDir() {
		return tempDir;
	}

	public void exit() {
		this.exit(0);
	}

	public void exit(long status) {
		System.exit((int)status);
	}

	private final java.util.HashMap shutdownHooks = new java.util.HashMap();  // Func => Thread
	public void addShutdownHook(Func f)
	  {
	    if (!f.isImmutable()) throw NotImmutableErr.make();
	    Thread thread = new ShutdownHookThread(f);
	    shutdownHooks.put(f, thread);
	    Runtime.getRuntime().addShutdownHook(thread);
	  }

	  public boolean removeShutdownHook(Func f)
	  {
	    Thread thread = (Thread)shutdownHooks.get(f);
	    if (thread == null) return false;
	    return Runtime.getRuntime().removeShutdownHook(thread);
	  }

	  static class ShutdownHookThread extends Thread
	  {
	    ShutdownHookThread(Func func) { this.func = func; }
	    public void run()
	    {
	      try
	      {
	        func.call();
	      }
	      catch (Throwable e)
	      {
	        e.printStackTrace();
	      }
	    }
	    private final Func func;
	  }

	//////////////////////////////////////////////////////////////////////////
	// Resolution
	//////////////////////////////////////////////////////////////////////////

	public File findFile(Uri uri) {
		return findFile(uri, true);
	}

	public File findFile(Uri uri, boolean checked) {
		List list = findAllFiles(uri);
		if (list == null || list.size() == 0) {
			if (checked) throw UnresolvedErr.make(uri.toStr());
			return null;
		}
		return (File)list.first();
	}

	public List findAllFiles(Uri uri) {
		//TODO
		return null;
	}

	public File findPodFile(String name) {
		findFile(Uri.fromStr("lib/fan/" + name + ".pod"), false);
		File file = findFile(Uri.fromStr("lib/fan/" + name + ".pod"), true);
		if (file == null)
			return null;

		// verify case since Windoze is case insensitive
		String actualName = file.normalize().name();
		if (!actualName.equals(name + ".pod"))
			throw UnknownPodErr.make("Case mismatch: expected '" + name + ".pod' but found '" + actualName + "'");
		return file;
	}

	public List findAllPodNames() {
		List acc = List.make(64);
		List files = findFile(Uri.fromStr("lib/fan/")).list();
		for (int i = 0; i < files.size(); ++i) {
			File f = (File) files.get(i);
			if (f.isDir() || !"pod".equals(f.ext()))
				continue;
			acc.add(f.basename());
		}
		return acc;
	}
	
	//TODO index
//	private EnvIndex index = new EnvIndex(this);
//
//	public List index(String key) {
//		return index.get(key);
//	}
//
//	public List indexKeys() {
//		return index.keys();
//	}

}
