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

import fanx.main.Sys;

/**
 * FType is the fcode representation of sys::Type.
 */
public class FType
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public FType(FPod pod)
  {
    this.pod = pod;
  }

//////////////////////////////////////////////////////////////////////////
// Meta IO
//////////////////////////////////////////////////////////////////////////

  public FType readMeta(FStore.Input in) throws IOException
  {
    self   = in.u2();
    base   = in.u2();
    mixins = new int[in.u2()];
    for (int i=0; i<mixins.length; ++i) mixins[i] = in.u2();
    flags  = in.u4();
    int genericCount = in.u1();
    genericParams = new GenericParam[genericCount];
    for (int i=0; i<genericCount; ++i) {
    	genericParams[i] = new GenericParam();
    	genericParams[i].name = in.u2();
    }
    for (int i=0; i<genericCount; ++i) {
    	genericParams[i].bound = in.u2();
    }
    selfRef = pod.typeRef(self);
    return this;
  }

//////////////////////////////////////////////////////////////////////////
// Body IO
//////////////////////////////////////////////////////////////////////////

  public String filename()
  {
    return "fcode/" + pod.typeRef(self).typeName + ".fcode";
  }
  
  public void load() {
	if (!hollow) return;
	try {
		read();
	} catch (IOException e) {
		e.printStackTrace();
	}
  }

  void read() throws IOException
  {
    read(pod.store.read(filename()));
  }

  void read(FStore.Input in) throws IOException
  {
    if (in == null)
      throw new IOException("Cannot read fcode: " +  pod.typeRef(self).signature);

    if (in.fpod.fcodeVersion == null)
      throw new IOException("FStore.Input.fcodeVersion == null");

    fields = new FField[in.u2()];
    for (int i=0; i<fields.length; ++i)
      fields[i] = new FField().read(in);

    methods = new FMethod[in.u2()];
    for (int i=0; i<methods.length; ++i)
      methods[i] = new FMethod().read(in);

    attrs = FAttrs.read(in);

    hollow = false;
    in.close();
  }
  
  public void clearBuf() {
	  for (FMethod m : methods) {
		  m.code = null;
	  }
  }
  
  public boolean isNative() { return (flags & FConst.Native) != 0; }
  
  public FTypeRef findGenericParamBound(String name) {
	  for (GenericParam p : genericParams) {
		  String n = pod.name(p.name);
		  if (n.equals(name)) {
			  return pod.typeRef(p.bound);
		  }
	  }
	  throw new RuntimeException("Unknow Generic Param:" + name + " in " + qname());
  }
  
  public boolean isGeneric() {
	  return genericParams.length > 0;
  }
  
  public FDoc doc() {
	  if (doc == null) {
		  doc = new FDoc(pod.store, typeName());
	  }
	  return doc;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private boolean hollow = true; // have we only read meta-data
  public FPod pod;              // parent pod
  public int self;              // self typeRef index
  public int flags;             // bitmask
  public int base;              // base typeRef index
  public int[] mixins;          // mixin TypeRef indexes
  public FField[] fields;       // fields
  public FMethod[] methods;     // methods
  public FAttrs attrs;          // type attributes
  public GenericParam[] genericParams;
  
  private FDoc doc;
  
  public static class GenericParam {
	  int bound;
	  int name;
  }
  
//////////////////////////////////////////////////////////////////////////
//Utils
//////////////////////////////////////////////////////////////////////////
  
	public FTypeRef selfRef;
	public Object reflectType = null;
	private Map<String, FSlot > slotsMap = null;
	
	public Map<String, FSlot> getSlotsMap() {
		if (slotsMap != null) return slotsMap;
  		Map<String, FSlot > map = new HashMap<String, FSlot>();
  		
  		for (FField f : fields) {
        //if (f.isSynthetic()) continue;
    		map.put(f.name, f);
    	}
  	
  	for (FMethod f : methods) {
  		if ((f.flags & FConst.Getter) != 0) {
        //FField field = (FField)map.get(f.name);
        //field.getter = f;
  			continue;
  		}
  		if ((f.flags & FConst.Setter) != 0) {
        //FField field = (FField)map.get(f.name);
        //field.setter = f;
  			continue;
  		}
      if ((f.flags & FConst.Overload) != 0) {
        continue;
      }
  		
      //if (f.isSynthetic()) continue;
  		map.put(f.name, f);
  	}
  	slotsMap = map;
  	return slotsMap;
	}
	
	public boolean baseIsJava() {
		FTypeRef ref = pod.typeRef(base);
		return ref.isFFI();
	}
	
	public boolean isMixin() {
		return (flags & FConst.Mixin) != 0;
	}
	
	public final boolean isSynthetic() {
		return (flags & FConst.Synthetic) != 0;
	}
	
	public String signature() {
		return selfRef.signature;
	}
	
	public String typeName() {
		return selfRef.typeName;
	}
	
	public String podName() {
		return selfRef.podName;
	}
	
	public String qname() {
		return selfRef.podName + "::" + selfRef.typeName;
	}

}