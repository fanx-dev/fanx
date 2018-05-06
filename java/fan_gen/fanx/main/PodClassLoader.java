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
import java.security.*;
import java.util.*;
import fanx.emit.*;
import fanx.fcode.FPod;
import fanx.util.*;

/**
 * FanClassLoader is used to emit fcode to Java bytecode.  It manages
 * the "fan." namespace to map to dynamically loaded Fantom classes.
 */
public class PodClassLoader
  extends URLClassLoader
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public PodClassLoader(FPod pod)
  {
    super(new URL[0], extClassLoader);
    try
    {
//      pod = Sys.findPod(podName);
      this.pod = pod;
      this.allPermissions = new AllPermission().newPermissionCollection();
      this.codeSource = new CodeSource(new java.net.URL("file://"), (CodeSigner[])null);
    }
    catch (Throwable e)
    {
      e.printStackTrace();
    }
  }

//////////////////////////////////////////////////////////////////////////
// Load Fan
//////////////////////////////////////////////////////////////////////////

//  public Class loadFan(String name, Box classfile)
//  {
//    try
//    {
//      synchronized(pendingClasses)
//      {
//        pendingClasses.put(name, classfile);
//      }
//      return loadClass(name);
//    }
//    catch (ClassNotFoundException e)
//    {
//      e.printStackTrace();
//      throw new RuntimeException("Cannot load class: " + name, e);
//    }
//  }
  
  private final Class<?> loadDefineClass(String name, Box classfile) {
	  return defineClass(name, classfile.buf, 0, classfile.len, codeSource);
  }

//////////////////////////////////////////////////////////////////////////
// ClassLoader - Classes
//////////////////////////////////////////////////////////////////////////

  public String toString()
  {
    return "FanClassLoader[" + pod.podName + "]";
  }

  protected PermissionCollection getPermissions(CodeSource src)
  {
    return allPermissions;
  }

  @Override
  protected Class findClass(String name)
    throws ClassNotFoundException
  {
    try
    {
      Class cls;

      // first check if the classfile in my pending queue
//      cls = findPendingClass(name);
//      if (cls != null) return cls;

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
    	  
    	  if (d.findPrecompiledClassFile(name) != null) {
    		  return d.loadClass(name);
    	  }
      }

      // fallback to default URLClassLoader loader
      // implementation which searches my ext jars
      return super.findClass(name);
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

//  private Class findPendingClass(String name)
//  {
//    Box pending = null;
//    synchronized(pendingClasses)
//    {
//      pending = (Box)pendingClasses.get(name);
//      if (pending != null) pendingClasses.remove(name);
//    }
//    if (pending == null) return null;
////if (name.indexOf("Foo") > 0) dumpToFile(name, pending);
//    return defineClass(name, pending.buf, 0, pending.len, codeSource);
//  }

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
    	Class podClz = loadDefineClass(name, podEmit.classFile);
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
      FTypeEmit[] emitted = FTypeEmit.emit(pod.type(tname));
      Class c = null;
      for (int j=0; j<emitted.length; ++j)
      {
        FTypeEmit emit = emitted[j];
        c = loadDefineClass(name, emit.classFile);
      }
      if (c != null) return c;
    }

    // if there wasn't a precompiled class, then this must
    // be a normal fcode type which we need to emit
    FTypeEmit[] emitted = FTypeEmit.emit(pod.type(typeName));
    FTypeEmit emit = emitted[0];
    cls = loadDefineClass(name, emit.classFile);
    return cls;
  }

  private Box findPrecompiledClassFile(String name)
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
      Box precompiled = findPrecompiledClassFile(name);
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
      Class cls = loadDefineClass(name, precompiled);

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
      super(new URL[0], PodClassLoader.class.getClassLoader());
      addFanDir(new File(Sys.homeDir));
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

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private FPod pod;
  private PermissionCollection allPermissions;
  private CodeSource codeSource;
//  private HashMap pendingClasses = new HashMap(); // name -> Box
}