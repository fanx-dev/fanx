//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import java.util.*;
import java.util.zip.*;

import fanx.main.Sys;

/**
 * FPod is the read/write fcode representation of sys::Pod.  It's main job in
 * life is to manage all the pod-wide constant tables for names, literals,
 * type/slot references and type/slot definitions.
 */
public final class FPod
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FPod(String podName, FStore store)
  {
    if (store != null) store.fpod = this;
    this.podName    = podName;
    this.store      = store;
    this.names      = new FTable.Names(this);
    this.typeRefs   = new FTable.TypeRefs(this);
    this.fieldRefs  = new FTable.FieldRefs(this);
    this.methodRefs = new FTable.MethodRefs(this);
  }
  
  public static FPod fromFile(String podName, File podFile) throws Exception {
	FStore podStore = FStore.makeZip(podFile);
	FPod pod = new FPod(podName, podStore);
	pod.read();
	return pod;
  }

//////////////////////////////////////////////////////////////////////////
// Lookup
//////////////////////////////////////////////////////////////////////////

  public FType type(String name) { return type(name, true); }
  
  public FType type(String name, boolean checked)
  {
	  if (typeMap == null) {
		Map<String, FType> map = new HashMap<String, FType>();
	    for (int i=0; i<types.length; ++i)
	      map.put(typeRef(types[i].self).typeName, types[i]);
	    typeMap = map;
	  }
	  FType t = typeMap.get(name);
	  if (t != null) return t;
	  
	  if (checked) throw new RuntimeException("UnknownTypeErr:"+name);
	  else return null;
  }

//////////////////////////////////////////////////////////////////////////
// Tables
//////////////////////////////////////////////////////////////////////////

  public final String name(int index)          { return (String)names.get(index);   }
  public final FTypeRef typeRef(int index)     { return (FTypeRef)typeRefs.get(index);  }
  public final FFieldRef fieldRef(int index)   { return (FFieldRef)fieldRefs.get(index);  }
  public final FMethodRef methodRef(int index) { return (FMethodRef)methodRefs.get(index); }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  /**
   * Read from a FStore which provides random access
   */
  public void read() throws IOException
  {
    // pod meta
    readPodMeta(store.read("meta.props", true));

    names.read(store.read("fcode/names.def"));
    typeRefs.read(store.read("fcode/typeRefs.def"));
    fieldRefs.read(store.read("fcode/fieldRefs.def"));
    methodRefs.read(store.read("fcode/methodRefs.def"));

    // type meta
    readTypeMeta(store.read("fcode/types.def"));

    // full fcode always lazy loaded in Type.reflect()
    
    //replace the generic param with the bound type
    for (int i=0; i<typeRefs.size; ++i) {
    	FTypeRef ref = (FTypeRef)typeRefs.get(i);
    	ref.initGenericParam(this);
    }
  }

  /**
   * Read the literal constant tables (if not already loaded).
   */
  public FLiterals readLiterals() throws IOException
  {
    if (literals == null)
      literals = new FLiterals(this).read();
    return literals;
  }

  /// debug forces full load of Types too
  public void readFully() throws IOException
  {
    read();
    for (int i=0; i<types.length; ++i)
      types[i].read();
  }

  /**
   * Read from an input stream (used for loading scripts from memory)
   */
  public void readFully(final ZipInputStream zip) throws IOException
  {
    FStore.Input in = new FStore.Input(this, zip)
    {
      public void close() throws IOException { zip.closeEntry(); }
    };

    ZipEntry entry;
    literals = new FLiterals(this);
    while ((entry = zip.getNextEntry()) != null)
    {
      String name = entry.getName();
      if (name.equals("meta.props")) { readPodMeta(in); continue; }
      else if (name.startsWith("fcode/") && name.endsWith(".fcode")) readType(name, in);
      else if (name.equals("fcode/names.def")) names.read(in);
      else if (name.equals("fcode/typeRefs.def")) typeRefs.read(in);
      else if (name.equals("fcode/fieldRefs.def")) fieldRefs.read(in);
      else if (name.equals("fcode/methodRefs.def")) methodRefs.read(in);
      else if (name.equals("fcode/types.def")) readTypeMeta(in);
      else if (name.equals("fcode/ints.def")) literals.ints.read(in);
      else if (name.equals("fcode/floats.def")) literals.floats.read(in);
      else if (name.equals("fcode/decimals.def")) literals.decimals.read(in);
      else if (name.equals("fcode/strs.def")) literals.strs.read(in);
      else if (name.equals("fcode/durations.def")) literals.durations.read(in);
      else if (name.equals("fcode/uris.def")) literals.uris.read(in);
      else System.out.println("WARNING: unexpected file in pod: " + name);
      
      
    }
    
		for (int i = 0; i < typeRefs.size; ++i) {
			FTypeRef ref = (FTypeRef) typeRefs.get(i);
			ref.initGenericParam(this);
		}
  }
  
  private static Map<String, String> readProps(FStore.Input in) throws IOException {
	  BufferedReader r = new BufferedReader(new InputStreamReader(in));
	  String line;
	  Map<String,String> map = new HashMap<String, String>();
	  while (true) {
		  line = r.readLine();
		  if (line == null) break;
		  line = line.trim();
		  if (line.startsWith("//")) continue;
		  String[] fs = line.split("=", 2);
		  if (fs.length != 2) {
			  System.out.println("ERROR read:"+line);
        continue;
		  }
		  String key = fs[0].trim();
		  String val = fs[1].trim();
		  map.put(key, val);
	  }
	  return map;
  }

  private void readPodMeta(FStore.Input in) throws IOException
  {
    // handle sys bootstrap specially using just java.util.Properties
    String metaName;
//    if ("sys".equals(podName))
//    {
//      Properties props = new Properties();
//      props.load(in);
//      in.close();
//      metaName =  props.getProperty("pod.name");
//      podVersion = props.getProperty("pod.version");
//      fcodeVersion = props.getProperty("fcode.version");
//      depends = new String[0];
//      return;
//    }
//    else
    {
//      SysInStream sysIn = new SysInStream(in);
      this.meta = readProps(in);
      in.close();

      metaName = meta("pod.name");
      podVersion = meta("pod.version");

      fcodeVersion = (String)meta.get("fcode.version");
      if (fcodeVersion == null) fcodeVersion = "unspecified";

      String dependsStr = meta("pod.depends").trim();
      if (dependsStr.length() == 0) depends = new String[0];
      else
      {
        String[] toks = dependsStr.split(";");
        depends = new String[toks.length];
        for (int i=0; i<depends.length; ++i) depends[i] = (toks[i].trim());
      }
    }

    // check meta name matches podName passed to ctor
    if (podName == null) podName = metaName;
    if (!podName.equals(metaName))
      throw new IOException("Pod name mismatch " + podName + " != " + metaName);
    
    // if we have types, then ensure we have correct fcode
    if (FConst.FCodeVersion.equals(fcodeVersion)) {
    	fcodeVer = 113;//add methodRef.arity
    }
    else if (fcodeVersion.equals("1.1.2")) {
    	fcodeVer = 112;//overload for param default
    }
    else if (fcodeVersion.equals("1.1.1")) {
    	fcodeVer = 111;//remove jumpFinally
    }
    else if (fcodeVersion.equals("1.1.0")) {
    	fcodeVer = 110;
    }
    else {
      throw new IOException("Invalid fcode version: " + fcodeVersion + " != " + FConst.FCodeVersion);
    }
  }

  private String meta(String key) throws IOException
  {
    String val = (String)meta.get(key);
    if (val == null) throw new IOException("meta.prop missing " + key);
    return val;
  }

  private void readTypeMeta(FStore.Input in) throws IOException
  {
    if (in == null) { types = new FType[0]; return; }

    types = new FType[in.u2()];
    for (int i=0; i<types.length; ++i)
    {
      types[i] = new FType(this).readMeta(in);
//      types[i].hollow = true;
    }
    in.close();
  }

  private void readType(String name, FStore.Input in) throws IOException
  {
    if (types == null || types.length == 0)
      throw new IOException("types.def must be defined first");

    String typeName = name.substring(6, name.length()-".fcode".length());
    for (int i=0; i<types.length; ++i)
    {
      String n = typeRef(types[i].self).typeName;
      if (n.equals(typeName )) { types[i].read(in); return; }
    }

    throw new IOException("Unexpected fcode file: " + name);
  }

//  public java.io.File loadFile()
//  {
//    if (store == null) return null;
//    return store.loadFile();
//  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public String podName;      // pod's unique name
  public String podVersion;   // pod's version
  public String[] depends;    // pod dependencies
  public String fcodeVersion; // fcode format version
  public Map<String, String> meta;            // meta Str:Str map
  public FStore store;        // store we using to read
  public FType[] types;       // pod's declared types
  public FTable names;        // identifier names: foo
  public FTable typeRefs;     // types refs:   [pod,type,variances*]
  public FTable fieldRefs;    // fields refs:  [parent,name,type]
  public FTable methodRefs;   // methods refs: [parent,name,ret,params*]
  public FLiterals literals;  // literal constants (on read fully or lazy load)
  
  public ClassLoader podClassLoader;
  private Map<String, FType> typeMap;
  
  public Object reflectPod = null;
  public Object compilerCache = null;
  
  public int fcodeVer;
}