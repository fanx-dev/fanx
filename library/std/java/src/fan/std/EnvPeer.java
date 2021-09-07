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
import fanx.main.Sys;
import fanx.main.Type;

public class EnvPeer {

  String host = initHost();
  String user = initUser();
  InStream in;
  OutStream out;
  OutStream err;

  //////////////////////////////////////////////////////////////////////////
  // Construction
  //////////////////////////////////////////////////////////////////////////

  public Sys.IEnv sysEnv() {
    return Sys.env;
  }

  public static EnvPeer make(Env self) {
    return new EnvPeer(self);
  }

  public EnvPeer(Env self) {
    in = SysInStreamPeer.fromJava(System.in, 0);
    out = SysOutStreamPeer.fromJava(System.out, 0);
    err = SysOutStreamPeer.fromJava(System.err, 0);
    shutdownHooks = new ShutdownHookThread(self);
    Runtime.getRuntime().addShutdownHook(shutdownHooks);
  }

  public String host(Env self) {
    return host;
  }

  public String user(Env self) {
    return user;
  }

  public InStream in(Env self) {
    return in;
  }

  public OutStream out(Env self) {
    return out;
  }

  public OutStream err(Env self) {
    return err;
  }

  public void init(Env self) {
  }

  //////////////////////////////////////////////////////////////////////////
  // Non-Virtuals
  //////////////////////////////////////////////////////////////////////////

  // public final Env parent() { return parent; }

  public final String os(Env self) {
    return sysEnv().os();
  }

  public final String arch(Env self) {
    return sysEnv().arch();
  }

  public final String platform(Env self) {
    return sysEnv().platform();
  }

  public final String runtime(Env self) {
    return "java";
  }

  public final boolean isJs(Env self) { return false; }
  
  public final long javaVersion(Env self) { return BootEnv.javaVersion; }

  public final long idHash(Env self, Object obj) {
    return System.identityHashCode(obj);
  }

  //////////////////////////////////////////////////////////////////////////
  // Virtuals
  //////////////////////////////////////////////////////////////////////////
  List args = initArgs();

  public List args(Env self) {
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

  public Map vars(Env self) {
    return vars;
  }

  private static Map initVars() {
    Map vars = CaseInsensitiveMap.make(64);
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
      // use environment vars first to avoid DNS calls
      String s;
      s = System.getenv("HOSTNAME");
      if (s != null)
        return s;
      s = System.getenv("FAN_HOSTNAME");
      if (s != null)
        return s;
    } catch (Throwable e) {
    }

    try {
      // this will block if the network is down
      return java.net.InetAddress.getLocalHost().getHostName();
    } catch (Throwable e) {
    }

    return "unknown";
  }

  private static String initUser() {
    return System.getProperty("user.name", "unknown");
  }

  public Map diagnostics(Env self) {
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

  public void gc(Env self) {
    System.gc();
  }

  //////////////////////////////////////////////////////////////////////////
  // Prompt JLine
  //////////////////////////////////////////////////////////////////////////
  private Object jline; // null, Throwable, ConsoleReader

  public String prompt(Env self) {
    return this.prompt(self, "");
  }

  public String promptPassword(Env self) {
    return this.promptPassword(self, "");
  }

  public String prompt(Env self, String msg) {
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

  public String promptPassword(Env self, String msg) {
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
      out.print(msg).flush();
      return new java.io.BufferedReader(new java.io.InputStreamReader(System.in)).readLine();
    } catch (Exception e) {
      throw Err.make(e);
    }
  }

  //////////////////////////////////////////////////////////////////////////
  // Exit and Shutdown Hooks
  //////////////////////////////////////////////////////////////////////////

  public void exit(Env self) {
    this.exit(self, 0);
  }

  public void exit(Env self, long status) {
    System.exit((int) status);
  }

  private final ShutdownHookThread shutdownHooks;

  static class ShutdownHookThread extends Thread {
    ShutdownHookThread(Env env) {
      this.env = env;
    }

    public void run() {
      try {
        env.onExit();
      } catch (Throwable e) {
        e.printStackTrace();
      }
    }

    private final Env env;
  }

  //////////////////////////////////////////////////////////////////////////
  // Resolution
  //////////////////////////////////////////////////////////////////////////

  public String homeDirPath(Env self) {
    return sysEnv().homeDir();
  }


  public String[] getEnvPaths(Env self) {
    java.util.List<String> list = sysEnv().envPaths();
    String[] array = new String[list.size()];
    list.toArray(array);
    return array;
  }

}