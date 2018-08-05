//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Dec 05  Brian Frank  Creation
//
package fanx.tools;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Modifier;
import java.util.List;

import fanx.fcode.FPod;
import fanx.fcode.FStore;
import fanx.main.BootEnv;
import fanx.main.Sys;
import fanx.main.Type;
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
	BootEnv.args = args;

    // check for pods pending installation
//    checkInstall();

    // first try as file name
    File file = new File(target);
    if (file.exists() && target.toLowerCase().endsWith(".fan") && !file.isDirectory())
    {
      return executeFile(file, args);
    }
    else
    {
      return executeType(target, args);
    }
  }

//  private void checkInstall()
//  {
//    // During bootstrap, check for pods located in "lib/install" and
//    // if found copy them to "lib/fan".  This gives us a simple way to
//    // stage installs which don't effect current program until the next
//    // reboot.  This is not really intended to be a long term solution
//    // because it suffers from limitations: assumes only one Fantom program
//    // being restarted at a time
//    try
//    {
//      // check for {home}/lib/install/
//      File installDir = new File(Sys.homeDir, "lib" + File.separator + "install");
//      if (!installDir.exists()) return;
//
//      // install to {work}/lib/fan/
//      File dir = new File(Sys.homeDir, "lib" + File.separator + "fan");
//      dir = new File(dir, "lib" + File.separator + "fan");
//
//      // install each file
//      File[] files = installDir.listFiles();
//      for (int i=0; files != null && i<files.length; ++i)
//      {
//        File file = files[i];
//        String name = file.getName();
//        if (!name.endsWith(".pod")) continue;
//        System.out.println("INSTALL POD: " + name);
//        FileUtil.copy(file, new File(dir, name));
//        file.delete();
//      }
//      FileUtil.delete(installDir);
//    }
//    catch (Throwable e)
//    {
//      System.out.println("ERROR: checkInstall");
//      e.printStackTrace();
//    }
//  }
  
  static public interface ScriptCompiler {
	  public abstract int executeScript(String file, String[] args);
  }
  
  private static Class<?> getEnvClass() throws ClassNotFoundException {
	  FPod pod = Sys.findPod("std");
      Class<?> jclass = pod.podClassLoader.loadClass("fan.std.Env");
      return jclass;
  }

  private int executeFile(File file, String[] args)
  {
	  try {
		  FPod pod = Sys.findPod("std");
	      Class<?> clz = pod.podClassLoader.loadClass("fan.std.FanScriptCompiler");
		  ScriptCompiler scriptCompiler = (ScriptCompiler)Reflection.getStaticField(clz, "cur");
		  return scriptCompiler.executeScript(file.getCanonicalPath(), args);
		} catch (Throwable e) {
			e.printStackTrace();
			return -1;
		}
  }

  private java.lang.reflect.Method findMethod(Class<?> clz, String name, Class<?> argClass) throws NoSuchMethodException, SecurityException {
	try { 
	  java.lang.reflect.Method met = clz.getMethod(name);
	  return met;
	}
	catch (Exception e) {
	  if (argClass == null) throw e;
 	  java.lang.reflect.Method met = clz.getMethod(name, argClass);
	  return met;
	}
		  
//		  java.lang.reflect.Method[] ms = clz.getDeclaredMethods();
////		  java.lang.reflect.Method[] ms = clz.getMethods();
//		  for (java.lang.reflect.Method m : ms) {
//			  if (m.getName().equals(name)) {
//				  return m;
//			  }
//		  }
//		  return null;
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
      Class<?> jclass = pod.podClassLoader.loadClass("fan."+podName+"."+typeName);
//      System.out.println(jclass.getClassLoader());
      Class<?> argClass = null;
      Object argObj = null;
      if (args.length > 0) {
    	  argClass = pod.podClassLoader.loadClass("fan.sys.List");
    	  java.lang.reflect.Method m = argClass.getMethod("make", long.class);
    	  argObj = m.invoke(null, (long)args.length);
    	  java.lang.reflect.Method addm = argClass.getMethod("add", Object.class);
    	  for (String s : args) {
    		  addm.invoke(argObj, s);
    	  }
      }
      
//      System.out.println(argObj);
      
      java.lang.reflect.Method m = findMethod(jclass, methodName, argClass);
      
      Object res = null;
      if ((m.getModifiers() & Modifier.STATIC) != 0) {
    	  if (argObj == null || m.getParameterCount() == 0) {
    		  res = m.invoke(null);
    	  }
    	  else {
    		  res = m.invoke(null, argObj);
    	  }
      } else {
    	  java.lang.reflect.Method ctor = findMethod(jclass, "make", null);
    	  Object instance = ctor.invoke(null);
    	  //Object instance = jclass.newInstance();
    	  if (argObj == null || m.getParameterCount() == 0) {
    		  res = m.invoke(instance);
    	  }
    	  else {
    		  res = m.invoke(instance, argObj);
    	  }
      }
      
      return toResult(res);
    }
    catch (Throwable e)
    {
      //System.out.println("ERROR: " + e);
      if (e.getCause() != null) {
    	  e.getCause().printStackTrace();
      } else {
    	  e.printStackTrace();
      }
      return -1;
    }
    finally {
    	cleanup();
    }
  }

  static int toResult(Object obj)
  {
	if (obj == null) return 0;
    if (obj instanceof Long) return ((Long)obj).intValue();
    if (obj instanceof Integer) return ((Integer)obj).intValue();
    return 0;
  }

  static void cleanup()
  {
    try
    {
    	Class<?> clz = getEnvClass();
	    Reflection.callStaticMethod(clz, "cleanup");
    }
    catch (Throwable e) {}
    System.out.flush();
	System.err.flush();
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
    println("  fan.platform:    " + Sys.env.platform());
//    println("  fan.version:     " + Sys.sysPod.version());
//    println("  fan.env:         " + Env.cur());
    println("  fan.home:        " + Sys.env.homeDir());
//    println("  wordDir:        " + Sys.env.workDir());

    List<String> path = Sys.env.envPaths();
    if (path != null)
    {
      println("");
      println("Env Path:");
      for (int i=0; i<path.size(); ++i)
    	  println("  " + path.get(i));
      println("");
    }
  }


  static void pods(String progName)
  {
    version(progName);

    long t1 = System.nanoTime();
    List<String> pods = Sys.env.listPodNames();
    long t2 = System.nanoTime();

    println("");
    println("Fantom Pods [" + (t2-t1)/1000000L + "ms]:");

    println("  Pod\tVersion");
    println("  ---\t-------");
    for (int i=0; i<pods.size(); ++i)
    {
      String name = pods.get(i);
      FStore store = Sys.env.loadPod(name);
      FPod pod = new FPod(name, store);
      try {
		pod.read();
	  } catch (IOException e) {
		e.printStackTrace();
      }
      
      println(name + "\t" + pod.podVersion);
//        FanStr.justl(pod.name(), 18L) + "  " +
//        FanStr.justl(pod.version().toString(), 8));
      try {
		store.close();
	  } catch (IOException e) {
		e.printStackTrace();
	  }
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