//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Dec 05  Brian Frank  Creation
//
package fanx.main;

import java.io.File;
import java.lang.reflect.Modifier;
import java.util.List;

import fanx.fcode.FPod;
import fanx.util.*;

/**
 * Fantom runtime command line tool.
 */
public class Fan
{

//////////////////////////////////////////////////////////////////////////
// Execute
//////////////////////////////////////////////////////////////////////////

  public int execute(String target, String[] args)
    throws Exception
  {
    // args
    Sys.args = args;

    // check for pods pending installation
    checkInstall();

    // first try as file name
    File file = new File(target);
    if (file.exists() && target.toLowerCase().endsWith(".fan") && !file.isDirectory())
    {
//      return executeFile(file, args);
    }
    else
    {
      return executeType(target, args);
    }
	return 0;
  }

  private void checkInstall()
  {
    // During bootstrap, check for pods located in "lib/install" and
    // if found copy them to "lib/fan".  This gives us a simple way to
    // stage installs which don't effect current program until the next
    // reboot.  This is not really intended to be a long term solution
    // because it suffers from limitations: assumes only one Fantom program
    // being restarted at a time
    try
    {
      // check for {home}/lib/install/
      File installDir = new File(Sys.homeDir, "lib" + File.separator + "install");
      if (!installDir.exists()) return;

      // install to {work}/lib/fan/
      File dir = new File(Sys.homeDir, "lib" + File.separator + "fan");
      dir = new File(dir, "lib" + File.separator + "fan");

      // install each file
      File[] files = installDir.listFiles();
      for (int i=0; files != null && i<files.length; ++i)
      {
        File file = files[i];
        String name = file.getName();
        if (!name.endsWith(".pod")) continue;
        System.out.println("INSTALL POD: " + name);
        FileUtil.copy(file, new File(dir, name));
        file.delete();
      }
      FileUtil.delete(installDir);
    }
    catch (Throwable e)
    {
      System.out.println("ERROR: checkInstall");
      e.printStackTrace();
    }
  }

//  private int executeFile(File file, String[] args)
//    throws Exception
//  {
//    Pod pod = compileScript(file, args);
//    if (pod == null) return -1;
//
//    List types = pod.types();
//    Type type = null;
//    Method main = null;
//    for (int i=0; i<types.sz(); ++i)
//    {
//      type = (Type)types.get(i);
//      main = type.method("main", false);
//      if (main != null) break;
//    }
//
//    if (main == null)
//    {
//      System.out.println("ERROR: missing main method: " + ((Type)types.get(0)).name() + ".main()");
//      return -1;
//    }
//
//    return callMain(type, main);
//  }
//
//  static Pod compileScript(File file, String[] args)
//  {
//    LocalFile f = (LocalFile)(new LocalFile(file).normalize());
//
//    Map options = new Map(Sys.StrType, Sys.ObjType);
//    for (int i=0; args != null && i<args.length; ++i)
//      if (args[i].equals("-fcodeDump")) options.add("fcodeDump", Boolean.TRUE);
//
//    try
//    {
//      // use Fantom reflection to run compiler::Main.compileScript(File)
//      return Env.cur().compileScript(f, options).pod();
//    }
//    catch (Err e)
//    {
//      System.out.println("ERROR: cannot compile script");
//      //if (!e.getClass().getName().startsWith("fan.compiler"))
//        e.trace();
//      return null;
//    }
//    catch (Exception e)
//    {
//      System.out.println("ERROR: cannot compile script");
//      e.printStackTrace();
//      return null;
//    }
//  }
  
  private java.lang.reflect.Method findMethod(Class clz, String name) {
	  try {
		  java.lang.reflect.Method met = clz.getMethod(name);
		  if (met != null) return met;
		  
//		  java.lang.reflect.Method[] ms = clz.getDeclaredMethods();
////		  java.lang.reflect.Method[] ms = clz.getMethods();
//		  for (java.lang.reflect.Method m : ms) {
//			  if (m.getName().equals(name)) {
//				  return m;
//			  }
//		  }
	  } catch (Throwable e) {
		  e.printStackTrace();
	  }
	  return null;
  }

  private int executeType(String target, String[] args)
    throws Exception
  {
    if (target.indexOf("::") < 0) target += "::Main.main";
    else if (target.indexOf('.') < 0) target += ".main";

    try
    {
      int c = target.indexOf("::");
      int dot = target.lastIndexOf('.');
      String podName = target.substring(0, c);
      String typeName = target.substring(c+2, dot);
      String methodName = target.substring(dot+1);
      
      FPod pod = Sys.findPod(podName);
      Class jclass = pod.podClassLoader.loadClass("fan."+podName+"."+typeName);
//      System.out.println(jclass.getClassLoader());
      java.lang.reflect.Method m = findMethod(jclass, methodName);
      
      Object res = null;
      if ((m.getModifiers() * Modifier.STATIC) != 0) {
    	  res = m.invoke(null);
      } else {
    	  java.lang.reflect.Method ctor = findMethod(jclass, "make");
    	  Object instance = ctor.invoke(null);
//    	  Object instance = jclass.newInstance();
    	  res = m.invoke(instance);
      }
      
      if (res instanceof Integer) {
    	  return (Integer)res;
      }
      return 0;
    }
    catch (Throwable e)
    {
      //System.out.println("ERROR: " + e);
      e.printStackTrace();
      return -1;
    }
  }

//  static int callMain(Type t, Method m)
//  {
//    // main method
//    Sys.bootEnv.setMainMethod(m);
//
//    // check parameter type and build main arguments
//    List args;
//    List params = m.params();
//    if (params.sz() == 0)
//    {
//      args = null;
//    }
//    else if (((Param)params.get(0)).type().is(Sys.StrType.toListOf()) &&
//             (params.sz() == 1 || ((Param)params.get(1)).hasDefault()))
//    {
//      args = new List(Sys.ObjType, new Object[] { Env.cur().args() });
//    }
//    else
//    {
//      System.out.println("ERROR: Invalid parameters for main: " + m.signature());
//      return -1;
//    }
//
//    // invoke
//    try
//    {
//      if (m.isStatic())
//        return toResult(m.callList(args));
//      else
//        return toResult(m.callOn(t.make(), args));
//    }
//    catch (Err ex)
//    {
//      ex.trace();
//      return -1;
//    }
//    finally
//    {
//      cleanup();
//    }
//  }

  static int toResult(Object obj)
  {
    if (obj instanceof Long) return ((Long)obj).intValue();
    return 0;
  }

  static void cleanup()
  {
    try
    {
//       Env.cur().out().flush();
//       Env.cur().err().flush();
    }
    catch (Throwable e) {}
  }

//////////////////////////////////////////////////////////////////////////
// Version
//////////////////////////////////////////////////////////////////////////

  static void version(String progName)
  {
    println(progName);
    println("Copyright (c) 2006-2017, Brian Frank and Andy Frank");
    println("Licensed under the Academic Free License version 3.0");
    println("");
    println("Java Runtime:");
    println("  java.version:    " + System.getProperty("java.version"));
    println("  java.vm.name:    " + System.getProperty("java.vm.name"));
    println("  java.vm.vendor:  " + System.getProperty("java.vm.vendor"));
    println("  java.vm.version: " + System.getProperty("java.vm.version"));
    println("  java.home:       " + System.getProperty("java.home"));
    //TODO
//    println("  fan.platform:    " + Env.cur().platform());
//    println("  fan.version:     " + Sys.sysPod.version());
//    println("  fan.env:         " + Env.cur());
//    println("  fan.home:        " + Env.cur().homeDir().osPath());

//    String[] path = Env.cur().toDebugPath();
//    if (path != null)
//    {
//      println("");
//      println("Env Path:");
//      for (int i=0; i<path.length; ++i)
//      println("  " + path[i]);
//      println("");
//    }
  }


  static void pods(String progName)
  {
    version(progName);

    long t1 = System.nanoTime();
    List<String> pods = Sys.listPod();
    long t2 = System.nanoTime();

    println("");
    println("Fantom Pods [" + (t2-t1)/1000000L + "ms]:");

    println("  Pod                 Version");
    println("  ---                 -------");
    for (int i=0; i<pods.size(); ++i)
    {
      String pod = pods.get(i);
      println("  " + pod);
//        FanStr.justl(pod.name(), 18L) + "  " +
//        FanStr.justl(pod.version().toString(), 8));
    }
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  public int run(String[] args)
  {
    try
    {
      if (args.length == 0) { help(); return -1; }

      // process args
      for (int i=0; i<args.length; ++i)
      {
        String a = args[i].intern();
        if (a.length() == 0) continue;
        if (a == "-help" || a == "-h" || a == "-?")
        {
          help();
          return 2;
        }
        else if (a == "-version")
        {
          version("Fantom Launcher");
          return 3;
        }
        else if (a == "-pods")
        {
          pods("Fantom Launcher");
          return 4;
        }
        else if (a.charAt(0) == '-')
        {
          System.out.println("WARNING: Unknown option " + a);
        }
        else
        {
          String target = a;
          String[] targetArgs = new String[args.length-i-1];
          System.arraycopy(args, i+1, targetArgs, 0, targetArgs.length);
          return execute(target, targetArgs);
        }
      }

      help();
      return 2;
    }
    catch (Throwable e)
    {
      e.printStackTrace();
      return 1;
    }
  }

  void help()
  {
    println("Fantom Launcher");
    println("Usage:");
    println("  fan [options] <pod>::<type>.<method> [args]*");
    println("  fan [options] <filename> [args]*");
    println("Options:");
    println("  -help, -h, -?  print usage help");
    println("  -version       print version information");
    println("  -pods          list installed pods");
  }

  public static void println(String s)
  {
    System.out.println(s);
  }

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  public static void main(final String[] args)
    throws Exception
  {
    System.exit(new Fan().run(args));
  }

}