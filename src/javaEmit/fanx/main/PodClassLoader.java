//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Dec 05  Brian Frank  Creation
//
package fanx.main;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.*;
import java.util.HashMap;

import fanx.emit.*;
import fanx.fcode.FPod;
import fanx.fcode.FStore;
import fanx.fcode.FType;
import fanx.util.*;

/**
 * FanClassLoader is used to emit fcode to Java bytecode.  It manages
 * the "fan." namespace to map to dynamically loaded Fantom classes.
 */
public class PodClassLoader
  extends URLClassLoader
{
	private FPod pod;
	private HashMap<String, Box> pendingClasses = new HashMap<String, Box>(); // name -> Box

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public PodClassLoader(FPod pod)
  {
    super(new URL[0], extClassLoader);
    this.pod = pod;
    try {
    	if ("true".equals(System.getenv("FAN_DEBUG"))) {
	    	if (pod.podName.equals("sys")) {
	    		addURL(new File("../sys_nat/bin").toURI().toURL());
	    	} else if (pod.podName.equals("std")) {
	    		addURL(new File("../std_nat/bin").toURI().toURL());
	    	} else {
	    		addURL(new File("../"+pod.podName+"/bin").toURI().toURL());
	    	}
    	}
    	
	} catch (MalformedURLException e) {
		e.printStackTrace();
	}
  }

  private final Class<?> doDefineClass(String name, Box classfile) {
//	  System.out.println("doDefineClass:"+name);
	  return defineClass(name, classfile.buf, 0, classfile.len);
  }

//////////////////////////////////////////////////////////////////////////
// ClassLoader - Classes
//////////////////////////////////////////////////////////////////////////

  public String toString()
  {
    return "PodClassLoader[" + pod.podName + "]";
  }

  @Override
  protected Class findClass(String name)
    throws ClassNotFoundException
  {
    try
    {
//      System.out.println("loading:"+name);
      Class cls = null;

      // first check if the classfile in my pending queue
      cls = findPendingClass(name);
      if (cls != null) return cls;

      // anything starting with "fan." maps to a Fantom Type (or native peer code)
      cls = loadFanClassData(name);
      if (cls != null) return cls;

      // look in my own pod zip file for class
      cls = findPrecompiledClass(name, null);
      if (cls != null) return cls;

      // look in my dependencies for pre-compiled class
      for (int i=0; i<pod.depends.length; ++i)
      {
    	  String depend = pod.depends[i];
    	  int pos = depend.indexOf(' ');
    	  String podName = depend.substring(0, pos);
    	  
    	  PodClassLoader d = (PodClassLoader)Sys.findPod(podName).podClassLoader;
    	  
    	  if (d.findPrecompiledFile(name) != null) {
    		  return d.loadClass(name);
    	  }
      }

      // fallback to default URLClassLoader loader
      // implementation which searches my ext jars
      return super.findClass(name);
//      throw new ClassNotFoundException(name);
    }
    catch (java.lang.ClassNotFoundException e)
    {
      String s = e.toString();
      if (s.contains("swt"))
      {
        String msg = "cannot load SWT library; see http://fantom.org/doc/docTools/Setup.html#swt";
        System.out.println("\nERROR: " + msg + "\n");
      }
      throw e;
    }
    catch (Exception e)
    {
      throw new RuntimeException(e);
    }
  }

  private Class loadFanClassData(String name)
    throws Exception
  {
    // anything starting with "fan." maps to a Fantom Type (or native peer code)
    if (!name.startsWith("fan.")) return null;

    // fan.{pod}.{type}
    int dot = name.indexOf('.', 4);
    String podName  = name.substring(4, dot);
    String typeName = name.substring(dot+1);

    // check if this is my pod
    if (!pod.podName.equals(podName))
    {
      FPod pod = Sys.findPod(podName);
      return pod.podClassLoader.loadClass(name);
    }
    
    // see if we can find a precompiled class
    Class cls = findPrecompiledClass(name, typeName);
    if (cls != null) return cls;

    // ensure pod is emitted with our constant pool before
    // loading any classes inside of it (if this was the
    // actual class to load, then we are done)
    if (typeName.equals("$Pod")) {
    	FPodEmit podEmit = FPodEmit.emit(pod);
    	Class podClz = doDefineClass(name, podEmit.classFile);
    	//FPodEmit.initFields(pod, podClz);
    	return podClz;
    }

    // if the type name ends with $ then this is a mixin body
    // class being used before we have loaded the mixin interface,
    // so load them both
    boolean isMixinBody = false;
    if (typeName.endsWith("$"))
    {
      typeName = typeName.substring(0, typeName.length()-1);
      isMixinBody = true;
    }

    // if there wasn't a precompiled class, then this must
    // be a normal fcode type which we need to emit
    FType ft = pod.type(typeName, false);
    if (ft == null) return null;
    ft.load();
    if (ft.isNative()) return null;
    FTypeEmit[] emitted = FTypeEmit.emit(ft);
    
    //Load Mixin Body
    if (emitted.length > 1) {
    	if (!isMixinBody) {
    		cls = doDefineClass(name, emitted[0].classFile);
    		loadFan(name+"$", emitted[1].classFile);
    	}
    	else {
    		loadFan(name.substring(0, name.length()-1), emitted[0].classFile);
    		cls = doDefineClass(name, emitted[1].classFile);
    	}
    }
    //normal
    else {
    	cls = doDefineClass(name, emitted[0].classFile);
    }
    
    if (cls != null) ft.clearBuf();
    return cls;
  }

  private Box findPrecompiledFile(String name)
  {
    try
    {
      if (pod.store == null) return null;
      String path = name.replace('.', '/') + ".class";
      return pod.store.readToBox(path);
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return null;
    }
  }

  private Class findPrecompiledClass(String name, String fanTypeName)
  {
    try
    {
      Box precompiled = findPrecompiledFile(name);
      if (precompiled == null) return null;

      // definePackage before defineClass
      int dot = name.lastIndexOf('.');
      if (dot > 0)
      {
        String packageName = name.substring(0, dot);
        if (getPackage(packageName) == null)
          definePackage(packageName, null, null, null, null, null, null, null);
      }

      // defineClass
      Class cls = doDefineClass(name, precompiled);

      // if the precompiled class is a fan type, then we need
      // to finish the emit process since we skipped the normal
      // code path thru Type.emit() for fcode to bytecode generation
      if (fanTypeName != null)
      {
        Type type = Sys.findType(pod.podName + "::" + fanTypeName, false);
        if (type != null) type.precompiled(cls);
        /*
        else if (fanTypeName.equals("$Pod")) {
        	FPodEmit.initFields(pod, cls);
        }
        */
      }

      return cls;
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return null;
    }
  }
  
//////////////////////////////////////////////////////////////////////////
// Pending
//////////////////////////////////////////////////////////////////////////
  
  public Class loadFan(String name, Box classfile)
  {
    try
    {
      synchronized(pendingClasses)
      {
        pendingClasses.put(name, classfile);
      }
      return loadClass(name);
    }
    catch (ClassNotFoundException e)
    {
      throw new RuntimeException(e);
    }
  }
  
  private Class findPendingClass(String name)
  {
    Box pending = null;
    synchronized(pendingClasses)
    {
      pending = (Box)pendingClasses.get(name);
      if (pending != null) pendingClasses.remove(name);
    }
    if (pending == null) return null;
    return doDefineClass(name, pending);
  }

//////////////////////////////////////////////////////////////////////////
// ClassLoader - Resources
//////////////////////////////////////////////////////////////////////////

//  public URL findResource(String name)
//  {
//    if (!name.startsWith("/")) name = "/" + name;
//    pod.store.read(path)(Uri.fromStr(name), false);
//    if (file == null) return null;
//    return file.toJavaURL();
//  }
  public InputStream getResourceAsStream(String name) {
	FStore.Input input = null;
	try {
		input = pod.store.read(name);
	} catch (IOException e) {
		e.printStackTrace();
	}
	if (input != null) {
		return input;
	}
	return super.getResourceAsStream(name);
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  static void dumpToFile(String name, Box classfile)
  {
    try
    {
      File f = new File(name.substring(name.lastIndexOf('.')+1) + ".class");
      System.out.println("Dump: " + f);
      FileOutputStream out = new FileOutputStream(f);
      out.write(classfile.buf, 0, classfile.len);
      out.close();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

//////////////////////////////////////////////////////////////////////////
// ExtClassLoader
//////////////////////////////////////////////////////////////////////////
  
  static final ExtClassLoader extClassLoader = new ExtClassLoader();

  static class ExtClassLoader extends URLClassLoader
  {
    public ExtClassLoader()
    {
      super(new URL[0], ExtClassLoader.class.getClassLoader());
      
      for (String path : Sys.env.envPaths()) {
  		this.addFanDir(new File(path));
  	  }
    }

    /**
     * Given a home or working directory, add the following directories  to the path:
     *    {fanDir}/lib/java/ext/
     *    {fanDir}/lib/java/ext/{platform}/
     */
    void addFanDir(java.io.File fanDir)
    {
      try
      {
        String sep = java.io.File.separator;
        java.io.File extDir = new java.io.File(fanDir, "lib" + sep + "java" + sep + "ext");
        java.io.File platDir = new java.io.File(extDir, Sys.env.platform());
        addExtJars(extDir);
        addExtJars(platDir);
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }
    }

    private void addExtJars(java.io.File extDir) throws Exception
    {
      java.io.File[] list = extDir.listFiles();
      for (int i=0; list != null && i<list.length; ++i)
      {
        if (list[i].getName().endsWith(".jar"))
          addURL(list[i].toURI().toURL());
      }
    }
  }

}