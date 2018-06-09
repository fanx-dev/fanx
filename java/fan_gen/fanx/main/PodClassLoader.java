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
import java.net.*;
import fanx.emit.*;
import fanx.fcode.FPod;
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

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public PodClassLoader(FPod pod)
  {
    super(new URL[0], extClassLoader);
    this.pod = pod;
    try {
    	if (pod.podName.equals("sys")) {
    		addURL(new File("../sys_nat/bin").toURI().toURL());
    	} else if (pod.podName.equals("std")) {
    		addURL(new File("../std_nat/bin").toURI().toURL());
    	} else if (pod.podName.equals("reflect")) {
    		addURL(new File("../reflect/bin").toURI().toURL());
    	} else {
    		addURL(new File("../"+pod.podName+"/bin").toURI().toURL());
    	}
	} catch (MalformedURLException e) {
		e.printStackTrace();
	}
  }

  private final Class<?> doDefineClass(String name, Box classfile) {
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
//      try {
//    	  cls = super.findClass(name);
//    	  if (cls != null) return cls;
//      } catch (Exception e) {
//      }

      // anything starting with "fan." maps to a Fantom Type (or native peer code)
      cls = loadClassData(name);
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
    catch (Exception e)
    {
      String s = e.toString();
      if (s.contains("swt"))
      {
        String msg = "cannot load SWT library; see http://fantom.org/doc/docTools/Setup.html#swt";
        System.out.println("\nERROR: " + msg + "\n");
      }
      throw new RuntimeException(e);
    }
  }

  private Class loadClassData(String name)
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
    	FPodEmit.initFields(pod, podClz);
    	return podClz;
    }

    // if the type name ends with $ then this is a mixin body
    // class being used before we have loaded the mixin interface,
    // so load them both
    if (typeName.endsWith("$"))
    {
      int strip = typeName.endsWith("$") ? 1 : 4;
      String tname = typeName.substring(0, typeName.length()-strip);
      FType ft = pod.type(tname, false);
      if (ft == null) return null;
      if (ft.isNative()) return null;
      FTypeEmit[] emitted = FTypeEmit.emit(ft);
      Class c = null;
      for (int j=0; j<emitted.length; ++j)
      {
        FTypeEmit emit = emitted[j];
        c = doDefineClass(name, emit.classFile);
      }
      if (c != null) return c;
    }

    // if there wasn't a precompiled class, then this must
    // be a normal fcode type which we need to emit
    FType ft = pod.type(typeName, false);
    if (ft == null) return null;
    ft.load();
    if (ft.isNative()) return null;
    FTypeEmit[] emitted = FTypeEmit.emit(ft);
    FTypeEmit emit = emitted[0];
    cls = doDefineClass(name, emit.classFile);
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
        Type type = Sys.findType(fanTypeName);
        if (type != null) type.precompiled(cls);
//        else if (fanTypeName.equals("$Pod")) pod.precompiled(cls);
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
// ClassLoader - Resources
//////////////////////////////////////////////////////////////////////////

//  public URL findResource(String name)
//  {
//    if (!name.startsWith("/")) name = "/" + name;
//    fan.sys.File file = pod.file(Uri.fromStr(name), false);
//    if (file == null) return null;
//    return file.toJavaURL();
//  }

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
      this.addFanDir(new File(Sys.homeDir));
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
        java.io.File platDir = new java.io.File(extDir, Sys.platform);
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