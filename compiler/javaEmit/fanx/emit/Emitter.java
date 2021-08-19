//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.util.*;

/**
 * Emitter is responsible for generating the bytecode during
 * the emit process.  Emitter buffers the actual bytes being
 * generated and manages writing to the buffer.
 *
 * To use this API first construct an Emitter passing in the name,
 * super class, interfaces, and class level access flags.  Then
 * emit fields, methods, and attributes.  Once you are done, call
 * pack() to write the classfile into buf.
 */
public class Emitter
  implements EmitConst
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  /**
   * Convenience for init()
   */
  public Emitter(String thisClass, String superClass, String[] interfaces, int flags)
  {
    init(thisClass, superClass, interfaces, flags);
  }

  /**
   * Uninitialized Emitter - must call init()
   */
  public Emitter()
  {
  }

  /**
   * Initialize an Emitter to generate a class with given name,
   * super class, interfaces, and class level access flags.
   */
  public void init(String thisClass, String superClass, String[] interfaces, int flags)
  {
    this.className = thisClass;
    this.superClassName = superClass;
    this.cp.add(new CpDummy());  // dummy entry since constant pool starts at 1
    this.thisClassIndex  = cls(thisClass);
    this.superClassIndex = cls(superClass);
    this.interfaces = new int[interfaces.length];
    for (int i=0; i<interfaces.length; ++i)
      this.interfaces[i] = cls(interfaces[i]);
    this.flags = flags;
  }

//////////////////////////////////////////////////////////////////////////
// Emit
//////////////////////////////////////////////////////////////////////////

  /**
   * Define a new field to emit for the class file.
   */
  public FieldEmit emitField(String name, String type, int flags)
  {
    String sig = className + "." + name + ":" + type;
    FieldEmit f = new FieldEmit(this, sig, utf(name), utf(type), flags);
    fields.add(f);
    return f;
  }

  /**
   * Define a new method to emit for the class file.
   */
  public MethodEmit emitMethod(String name, String type, int flags)
  {
    String sig = className + "." + name + type;
    MethodEmit m = new MethodEmit(this, sig, utf(name), utf(type), flags);
    methods.add(m);
    return m;
  }

  /**
   * Define a new class level attribute.  Once the attribute
   * is added, use AttrEmit.info to populate it's value.
   */
  public AttrEmit emitAttr(String name)
  {
    AttrEmit a = new AttrEmit(this, utf(name));
    attrs.add(a);
    return a;
  }

  /**
   * Pack the current definition to a class file byte buffer.
   */
  public Box pack()
  {
    Box box = new Box();
    box.u4(0xCAFEBABE);
    box.u2(0);
    box.u2(49);  // using ldc_w with direct cp_class indices
    box.u2(cp.size());
    for (int i=1; i<cp.size(); ++i) ((CpInfo)cp.get(i)).pack(box);
    /*cpDump();*/
    box.u2(flags);
    box.u2(thisClassIndex);
    box.u2(superClassIndex);
    box.u2(interfaces.length);
    for (int i=0; i<interfaces.length; ++i) box.u2(interfaces[i]);
    box.u2(fields.size());
    for (int i=0; i<fields.size(); ++i)((FieldEmit)fields.get(i)).pack(box);
    box.u2(methods.size());
    for (int i=0; i<methods.size(); ++i) ((MethodEmit)methods.get(i)).pack(box);
    box.u2(attrs.size());
    for (int i=0; i<attrs.size(); ++i) ((AttrEmit)attrs.get(i)).pack(box);
    return box;
  }

//////////////////////////////////////////////////////////////////////////
// Constant Pool
//////////////////////////////////////////////////////////////////////////

  /**
   * Map a UTF-8 string literal into the constant pool.
   */
  public int utf(String s)
  {
    CpUtf info = (CpUtf)cpUtf.get(s);
    if (info == null)
    {
      info = new CpUtf(s);
      cpUtf.put(s, info);
      add(info);
    }
    return info.index;
  }

  /**
   * Map a string literal into the constant pool.
   */
  public int strConst(String v)
  {
    CpString info = (CpString)cpString.get(v);
    if (info == null)
    {
      info = new CpString(utf(v));
      cpString.put(v, info);
      add(info);
    }
    return info.index;
  }

  /**
   * Map a integer literal into the constant pool.
   */
  public int intConst(Integer v)
  {
    CpInteger info = (CpInteger)cpInteger.get(v);
    if (info == null)
    {
      info = new CpInteger(v.intValue());
      cpInteger.put(v, info);
      add(info);
    }
    return info.index;
  }

  /**
   * Map a long literal into the constant pool.
   */
  public int longConst(Long v)
  {
    CpLong info = (CpLong)cpLong.get(v);
    if (info == null)
    {
      info = new CpLong(v.longValue());
      cpLong.put(v, info);
      add(info);
      add(new CpDummy()); // longs take two entries
    }
    return info.index;
  }

  /**
   * Map a float literal into the constant pool.
   */
  public int floatConst(Float v)
  {
    CpFloat info = (CpFloat)cpFloat.get(v);
    if (info == null)
    {
      info = new CpFloat(v.floatValue());
      cpFloat.put(v, info);
      add(info);
    }
    return info.index;
  }

  /**
   * Map a double literal into the constant pool.
   */
  public int doubleConst(Double v)
  {
    CpDouble info = (CpDouble)cpDouble.get(v);
    if (info == null)
    {
      info = new CpDouble(v.doubleValue());
      cpDouble.put(v, info);
      add(info);
      add(new CpDummy()); // doubles take two entries
    }
    return info.index;
  }

  /**
   * Map a class name into the constant pool.  Class
   * name must in jtype format java/lang/String.
   */
  public int cls(String className)
  {
    // lookup or add
    CpClass info = (CpClass)cpClass.get(className);
    if (info == null)
    {
      info = new CpClass(utf(className));
      cpClass.put(className, info);
      add(info);
    }
    return info.index;
  }

  /**
   * Map a name and type into the constant pool.
   */
  public int nt(int name, int type)
  {
    Integer key = new Integer(name << 16 | type);
    CpNameType info = (CpNameType)cpNt.get(key);
    if (info == null)
    {
      info = new CpNameType(name, type);
      cpNt.put(key, info);
      add(info);
    }
    return info.index;
  }

  /**
   * Map a field ref into the constant pool, where
   * the sig is of the format "com/acme/Foo.f:I".
   */
  public int field(String sig)
  {
    CpField info = (CpField)cpField.get(sig);
    if (info == null)
    {
      int colon = sig.indexOf(':');
      int dot   = sig.lastIndexOf('.', colon -1);

      int cls  = cls(sig.substring(0, dot));
      int name = utf(sig.substring(dot+1, colon));
      int type = utf(sig.substring(colon+1));
      int nt   = nt(name, type);

      info = new CpField(cls, nt);
      cpField.put(sig, info);
      add(info);
    }
    return info.index;

  }

  /**
   * Map a method ref into the constant pool, where
   * the sig is of the format "com/acme/Foo.m(II)V".
   */
  public int method(String sig)
  {
    CpMethod info = (CpMethod)cpMethod.get(sig);
    if (info == null)
    {
      int paren = sig.indexOf('(');
      int dot   = sig.lastIndexOf('.', paren-1);

      int cls  = cls(sig.substring(0, dot));
      int name = utf(sig.substring(dot+1, paren));
      int type = utf(sig.substring(paren));
      int nt   = nt(name, type);

      info = new CpMethod(cls, nt);
      cpMethod.put(sig, info);
      add(info);
    }
    return info.index;

  }

  /**
   * Map a interface ref into the constant pool, where
   * the sig is of the format "com/acme/Foo.m(II)V".
   */
  public int interfaceRef(String sig)
  {
    CpInterface info = (CpInterface)cpInterface.get(sig);
    if (info == null)
    {
      int paren = sig.indexOf('(');
      int dot   = sig.lastIndexOf('.', paren-1);

      int cls  = cls(sig.substring(0, dot));
      int name = utf(sig.substring(dot+1, paren));
      int type = utf(sig.substring(paren));
      int nt   = nt(name, type);

      info = new CpInterface(cls, nt);
      cpInterface.put(sig, info);
      add(info);
    }
    return info.index;

  }

  /**
   * Add an entry to the constant pool.  This assigns an index
   * and adds to the main cp list, but not the individual caches.
   */
  private void add(CpInfo info)
  {
    info.index = cp.size();
    cp.add(info);
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  private void cpDump()
  {
    for (int i=1; i<cp.size(); ++i)
    {
      CpInfo x = (CpInfo)cp.get(i);
      if (x.index != i) throw new IllegalStateException();
      String index = ""+i;
      if (index.length() == 1) index = "0" + index;
      System.out.println("[" + index + "] " + toStr(x));
    }
  }

  String utfToStr(int index)
  {
    return ((CpUtf)cp.get(index)).val;
  }

  String clsToStr(int index)
  {
    return utfToStr( ((CpClass)cp.get(index)).name );
  }

  String ntToStr(int index)
  {
    return utfToStr( ((CpNameType)cp.get(index)).name ) + " " + utfToStr( ((CpNameType)cp.get(index)).type );
  }

  String toStr(CpInfo info)
  {
    if (info instanceof CpUtf)     { return "Utf  " + ((CpUtf)info).val;        }
    if (info instanceof CpInteger) { return "Int  " + ((CpInteger)info).val; }
    if (info instanceof CpLong)    { return "Long " + ((CpLong)info).val;    }
    if (info instanceof CpFloat)   { return "F    " + ((CpFloat)info).val;   }
    if (info instanceof CpDouble)  { return "D    " + ((CpDouble)info).val ; }
    if (info instanceof CpDummy)   { return "Dummy"; }
    if (info instanceof CpString)
    {
      CpString x = (CpString)info;
      return "String  " + x.utf + "=" + utfToStr(x.utf);
    }
    if (info instanceof CpClass)
    {
      CpClass x = (CpClass)info;
      return "Cls  " + x.name + "=" + utfToStr(x.name);
    }
    if (info instanceof CpNameType)
    {
      CpNameType x = (CpNameType)info;
      return "NT   " + x.name + "=" + utfToStr(x.name) + "  " + x.type + "=" + utfToStr(x.type);
    }
    if (info instanceof CpMethod)
    {
      CpMethod x = (CpMethod)info;
      return "M    " + x.cls + "=" + clsToStr(x.cls) + "  " + x.nt + "=" + ntToStr(x.nt);
    }
    if (info instanceof CpField)
    {
      CpField x = (CpField)info;
      return "F    " + x.cls + "=" + clsToStr(x.cls) + "  " + x.nt + "=" + ntToStr(x.nt);
    }
    return info.toString();
  }

//////////////////////////////////////////////////////////////////////////
// CpInfo Structs
//////////////////////////////////////////////////////////////////////////

  static abstract class CpInfo
  {
    abstract void pack(Box box);
    int index;
  }

  static class CpUtf extends CpInfo
  {
    CpUtf(String val)  { this.val = val; }
    void pack(Box box) { box.u1(CP_UTF8); box.utf(val); }
    String val;
  }

  static class CpString extends CpInfo
  {
    CpString(int utf)  { this.utf = utf; }
    void pack(Box box) { box.u1(CP_STRING); box.u2(utf); }
    int utf;
  }

  static class CpInteger extends CpInfo
  {
    CpInteger(int val)  { this.val = val; }
    void pack(Box box) { box.u1(CP_INTEGER); box.u4(val); }
    int val;
  }

  static class CpLong extends CpInfo
  {
    CpLong(long val)  { this.val = val; }
    void pack(Box box) { box.u1(CP_LONG); box.u8(val); }
    long val;
  }

  static class CpFloat extends CpInfo
  {
    CpFloat(float val)  { this.val = val; }
    void pack(Box box) { box.u1(CP_FLOAT); box.f4(val); }
    float val;
  }

  static class CpDouble extends CpInfo
  {
    CpDouble(double val)  { this.val = val; }
    void pack(Box box) { box.u1(CP_DOUBLE); box.f8(val); }
    double val;
  }

  static class CpClass extends CpInfo
  {
    CpClass(int name)  { this.name = name; }
    void pack(Box box) { box.u1(CP_CLASS); box.u2(name); }
    int name;
  }

  static class CpNameType extends CpInfo
  {
    CpNameType(int name, int type) { this.name = name; this.type = type; }
    void pack(Box box) { box.u1(CP_NAMETYPE); box.u2(name); box.u2(type); }
    int name, type;
  }

  static class CpField extends CpInfo
  {
    CpField(int cls, int nt) { this.cls = cls; this.nt  = nt; }
    void pack(Box box) { box.u1(CP_FIELD); box.u2(cls); box.u2(nt); }
    int cls, nt;
  }

  static class CpMethod extends CpInfo
  {
    CpMethod(int cls, int nt) { this.cls = cls; this.nt  = nt; }
    void pack(Box box) { box.u1(CP_METHOD); box.u2(cls); box.u2(nt); }
    int cls, nt;
  }

  static class CpInterface extends CpInfo
  {
    CpInterface(int cls, int nt) { this.cls = cls; this.nt  = nt; }
    void pack(Box box) { box.u1(CP_INTERFACE); box.u2(cls); box.u2(nt); }
    int cls, nt;
  }

  static class CpDummy extends CpInfo
  {
    void pack(Box box) {}
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public String className;
  public String superClassName;

  int thisClassIndex;
  int superClassIndex;
  int[] interfaces;
  int flags;

  ArrayList fields  = new ArrayList();  // FieldEmit
  ArrayList methods = new ArrayList();  // MethodEmit
  ArrayList attrs   = new ArrayList();  // AttrEmit

  ArrayList cp = new ArrayList();        // index   -> CpInfo
  HashMap cpUtf       = new HashMap();   // String  -> CpUtf
  HashMap cpClass     = new HashMap();   // String  -> CpClass
  HashMap cpString    = new HashMap();   // String  -> CpString
  HashMap cpInteger   = new HashMap();   // Integer -> CpInteger
  HashMap cpLong      = new HashMap();   // Long    -> CpLong
  HashMap cpFloat     = new HashMap();   // Float   -> CpFloat
  HashMap cpDouble    = new HashMap();   // Double  -> CpDouble
  HashMap cpNt        = new HashMap();   // Integer -> CpNameType
  HashMap cpMethod    = new HashMap();   // String  -> CpMethod
  HashMap cpField     = new HashMap();   // String  -> CpField
  HashMap cpInterface = new HashMap();   // String  -> CpInterface

}