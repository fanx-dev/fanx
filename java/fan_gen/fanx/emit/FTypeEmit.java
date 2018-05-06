//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.fcode.*;
import fanx.main.Sys;
import fanx.util.*;

/**
 * FTypeEmit translates FType fcode to Java bytecode.
 */
public abstract class FTypeEmit
  extends Emitter
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  public static FTypeEmit[] emit(FType ftype)
    throws Exception
  {
    // route based on type
    if ((ftype.flags & Mixin) != 0)
    {
      // interface
      FMixinInterfaceEmit iemit = new FMixinInterfaceEmit(ftype);
      iemit.emit();

      // body class
      FMixinBodyEmit bemit = new FMixinBodyEmit(ftype);
      bemit.emit();

      return new FTypeEmit[] { iemit, bemit };
    }
    else
    {
      FClassEmit emit = new FClassEmit(ftype);
      emit.emit();
      return new FTypeEmit[] { emit };
    }
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  protected FTypeEmit(FType ftype)
  {
//    this.parent  = type;
    this.pod     = ftype.pod;
    this.type    = ftype;
    this.lineNum = ftype.attrs.lineNum;
  }

//////////////////////////////////////////////////////////////////////////
// Emit
//////////////////////////////////////////////////////////////////////////

  /**
   * Emit to bytecode classfile.
   */
  public Box emit()
  {
    init(jname(type.self), base(), mixins(), jflags(type.flags) | SUPER);
    this.selfName = className;
    preview();
    emitType();
    for (int i=0; i<type.fields.length; ++i)  emit(type.fields[i]);
    for (int i=0; i<type.methods.length; ++i) emit(type.methods[i]);
    emitAttributes(type.attrs);
    emitMixinRouters();
    if (!hasInstanceInit) emitInstanceInit(null);
    if (!hasStaticInit) emitStaticInit(null);
    emitTypeConstFields();
    return classFile = pack();
  }

  abstract String base();

  String[] mixins()
  {
    String[] mixins = new String[type.mixins.length];
    for (int i=0; i<mixins.length; ++i)
      mixins[i] = jname(type.mixins[i]);
    return mixins;
  }

  private void preview()
  {
    this.isNative = (type.flags & FConst.Native) != 0;
    if (!this.isNative)
    {
      for (int i=0; i<type.methods.length; ++i)
        if ((type.methods[i].flags & Native) != 0) { this.isNative = true; break; }
    }
  }

  private void emitType()
  {
    // generate public static Type $Type; set in clinit
    typeField = emitField("$Type", Sys.TypeClassJsig, EmitConst.PUBLIC|EmitConst.STATIC|EmitConst.FINAL);

    // generate typeof() instance method
    MethodEmit me = emitMethod("typeof", "()"+Sys.TypeClassJsig, EmitConst.PUBLIC);
    CodeEmit code = me.emitCode();
    code.maxLocals = 1;
    code.maxStack  = 2;
    code.op2(GETSTATIC, typeField.ref());
    code.op(ARETURN);
    code.emitLineNumber(lineNum);

    // if native generate peer field and peer() override
    if (isNative)
      peerField = emitField("peer", "L" + className + "Peer;", EmitConst.PUBLIC);
  }

  /**
   * Emit an attribute
   */
  protected void emitAttributes(FAttrs attrs)
  {
    // source file
    if (attrs.sourceFile != null)
    {
      AttrEmit attr = emitAttr("SourceFile");
      attr.info.u2(utf(attrs.sourceFile));
    }

    // any Java facets get emitted as annotations
    FFacetEmit.emitType(this, pod, attrs);
  }

  /**
   * Emit a field
   */
  protected void emit(FField f)
  {
    if ((f.flags & FConst.Storage) != 0)
    {
      FieldEmit fe = emitField(f.name, pod.typeRef(f.type).jsig(), jflags(f.flags));
      FFacetEmit.emitField(fe, pod, f.attrs);
    }
  }

  /**
   * Emit a method
   */
  private void emit(FMethod m)
  {
    String name = m.name;
    boolean isNative = (m.flags & FConst.Native) != 0;
    boolean isStatic = (m.flags & FConst.Static) != 0;
    boolean isCtor   = (m.flags & FConst.Ctor) != 0;

    // static$init -> <clinit>
    // instance$init -> <init>
    if (name.equals("static$init"))   { emitStaticInit(m); return; }
    if (name.equals("instance$init")) { emitInstanceInit(m); return; }

    // handle native/constructor/normal method
    MethodEmit me = null;
    if (isNative)
    {
      me = new FMethodEmit(this, m).emitNative();
    }
    else if (isCtor && !isStatic)
    {
      if (type.baseIsJava())
        me = new FMethodEmit(this, m).emitCtorWithJavaSuper();
      else
        me = new FMethodEmit(this, m).emitCtor();
    }
    else
    {
      me = new FMethodEmit(this, m).emitStandard();
    }

    // generate method for each parameter default to use for reflection
    for (int i=0; i<m.paramCount; ++i)
      if (m.vars[i].def != null) emitMethodParamDef(m, m.vars[i]);

    // Java annotations
    FFacetEmit.emitMethod(me, pod, m.attrs);

    // if closure doCall, emit its params names for reflection
    if (isFuncType && name.equals("doCall"))
      emitFuncParamNames(m);
  }

  protected void emitInstanceInit(FMethod m)
  {
    // if base class is normal Java class imported via FFI, then
    // the Fantom constructors are the Java constructors
    if (type.baseIsJava()) return;

    hasInstanceInit = true;
    MethodEmit me = emitMethod("<init>", "()V", EmitConst.PUBLIC);
    // initalize code to call super
    CodeEmit code = me.emitCode();
    code.maxLocals = 1;
    code.maxStack  = 3;
    code.op(ALOAD_0);

    // if func, push FuncType static field
    if (isFuncType)
    {
      code.op2(GETSTATIC, typeField.ref());
      code.op2(CHECKCAST, cls("fan/sys/FuncType"));
      code.op2(INVOKESPECIAL, method(superClassName +".<init>(Lfan/sys/FuncType;)V"));
    }
    else
    {
      code.op2(INVOKESPECIAL, method(superClassName +".<init>()V"));
    }

    // make peer
    if (isNative)
    {
      code.op(ALOAD_0);  // for putfield
      code.op(DUP);      // for arg to make
      code.op2(INVOKESTATIC, method(selfName + "Peer.make(L" + className + ";)L" + className + "Peer;"));
      code.op2(PUTFIELD, peerField.ref());
    }

    if (m == null)
    {
      code.op(RETURN);
      code.emitLineNumber(lineNum);
    }
    else
    {
      new FCodeEmit(this, m, code).emit();
    }
  }

  void emitStaticInit(FMethod m)
  {
    hasStaticInit = true;
    MethodEmit me = emitMethod("<clinit>", "()V", EmitConst.PUBLIC|EmitConst.STATIC);
    CodeEmit code = me.emitCode();
    code.maxLocals = 0;
    code.maxStack  = 1;

    // set $Type field with type (if we this is a function,
    // then the FuncType will be the type exposed)
    if (!type.isMixin())
    {
//      if (parent.base() instanceof FuncType) t = parent.base();
      code.op2(LDC_W, strConst(type.signature()));
      code.op2(INVOKESTATIC, method("fanx/main/Sys.findType(Ljava/lang/String;)"+Sys.TypeClassJsig));
      code.op2(PUTSTATIC, typeField.ref());
    }

    if (m == null)
    {
      code.op(RETURN);
      code.emitLineNumber(lineNum);
    }
    else
    {
      new FCodeEmit(this, m, code).emit();
    }
  }

  void emitTypeConstFields()
  {
    // if during the emitting of all the methods we ran across a non-sys
    // LoadType opcode, then we need to generate a static field called
    // type${pod}${name} we can use to cache the type once it is looked up
    if (typeLiteralFields == null) return;
    Iterator it = typeLiteralFields.values().iterator();
    while (it.hasNext())
    {
      String fieldName = (String)it.next();
      emitField(fieldName, Sys.TypeClassJsig, EmitConst.PRIVATE|EmitConst.STATIC);
    }
  }
  
  public static String paramDefMethodName(String methodName, String paramName)
  {
    return "pdef$" + methodName + "$" + paramName;
  }

  void emitMethodParamDef(FMethod m, FMethodVar p)
  {
    // generate a method called pdef${method}${param} which evaluates
    // the default expression to use for Method.paramDef reflection
    boolean isStatic = (m.flags & FConst.Static) != 0;
    boolean isCtor   = (m.flags & FConst.Ctor) != 0;
    String methodName = paramDefMethodName(m.name, p.name);
    FTypeRef typeRef = pod.typeRef(p.type);
    int flags = EmitConst.PUBLIC;
    FCodeEmit.Reg[] regs = FCodeEmit.noRegs;
    if (isStatic || isCtor)
      flags |= EmitConst.STATIC;
    else
      regs = new FCodeEmit.Reg[] { FCodeEmit.makeThisReg(typeRef) };

    MethodEmit me = emitMethod(methodName, "()Ljava/lang/Object;", flags);
    CodeEmit code = me.emitCode();
    code.maxLocals = m.maxStack * 2;  // assume worst for method
    code.maxStack  = m.maxStack * 2;
    FCodeEmit e = new FCodeEmit(this, p.def, code, regs, typeRef);
    try
    {
      // emit expression, then box it to an object
      e.emit();
      e.boxToObj(typeRef);
      code.op(ARETURN);
    }
    catch (FCodeEmit.InvalidRegException ex)
    {
      // if the default uses previous params, then we FCodeEmit will
      // throw InvalidRegException; since the param can't be reflected
      // on its own just generate code to raise an exception
      if (this.MethodParamDefErr == 0)
        this.MethodParamDefErr = method("fan/sys/Method.makeParamDefErr()Lfan/sys/Err;");
      code.reset();
      code.op2(INVOKESTATIC, this.MethodParamDefErr);
      code.op(ATHROW);
    }
  }

  void emitFuncParamNames(FMethod m)
  {
    // build up string list of param names
    StringBuilder s = new StringBuilder(m.paramCount * 16);
    for (int i=0; i<m.paramCount; ++i)
    {
      if (i > 0) s.append(',');
      s.append(m.vars[i].name);
    }

    // override Func$Indirect.paramNames method
    MethodEmit me = emitMethod("paramNames", "()Ljava/lang/String;", EmitConst.PUBLIC);
    CodeEmit code = me.emitCode();
    code.maxLocals = 1;
    code.maxStack  = 1;
    code.op2(LDC_W, strConst(s.toString()));
    code.op(ARETURN);
  }

//////////////////////////////////////////////////////////////////////////
// Mixin Routers
//////////////////////////////////////////////////////////////////////////

  private void emitMixinRouters()
  {
    // short circuit if no direct mixins implemented
    if (type.mixins.length == 0) return;

    // first we have to find all the mixins I inherit thru my
    // direct mixin inheritances (but not my class extension) - these
    // are the ones I need routers for (but I can skip generating
    // routers for any mixins implemented by my super class)
    HashMap acc = new HashMap();
    findMixins(type, acc);

    // emit routers for concrete instance methods
    Iterator it = acc.values().iterator();
    while (it.hasNext())
    {
      FType mixin = (FType)it.next();
      emitMixinRouters(mixin);
    }
  }

  private void findMixins(FType t, HashMap acc)
  {
    // if mixin I haven't seen add to accumulator
    String qname = t.qname();
    if (((t.flags & FConst.Mixin) != 0)
    		&& acc.get(qname) == null)
      acc.put(qname, t);

    // recurse
    for (int i=0; i<t.mixins.length; ++i) {
    	FTypeRef ref = t.pod.typeRef(t.mixins[i]);
		FType x = Sys.findFType(ref.podName, ref.typeName);
        findMixins(x, acc);
    }
  }

  private void emitMixinRouters(FType type)
  {
    // generate router method for each concrete instance method
    FMethod[] methods = type.methods;
    for (int i=0; i<methods.length; ++i)
    {
    	FMethod m = methods[i];

      // only emit router for non-abstract instance methods
      if (m.isStatic() || m.isAbstract()) continue;

      // only emit the router unless this is the exact one I inherit
      String name = m.name;
//      if (parent.slot(name, true).parent() != type) continue;

      // do it
      new FMethodEmit(this).emitMixinRouter(m, type);
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  /**
   * Map Fantom flags to Java flags.  Note we emit protected as public and
   * internal/private as package-private so that we don't need to deal
   * with scope issues for accessors like closures and helper classes.
   */
  static int jflags(int fflags)
  {
    int jflags = 0;
    if ((fflags & FConst.Private)   != 0) { /* package private */ }  // have to be internal to access private field members in mixins
    if ((fflags & FConst.Protected) != 0) jflags |= EmitConst.PUBLIC;
    if ((fflags & FConst.Public)    != 0) jflags |= EmitConst.PUBLIC;
    if ((fflags & FConst.Internal)  != 0) jflags |= EmitConst.PUBLIC; // have to be public b/c mixin interfaces are forced public
    if ((fflags & FConst.Abstract)  != 0) jflags |= EmitConst.ABSTRACT;
    if ((fflags & FConst.Static)    != 0) jflags |= EmitConst.STATIC;
    if ((fflags & FConst.Mixin)     != 0) jflags |= EmitConst.INTERFACE;
    return jflags;
  }

  /**
   * Given a Fantom qname index, map to a Java class name: fan/sys/Version
   */
  String jname(int index)
  {
    return pod.typeRef(index).jname();
  }

  /**
   * Map a simple name index to it's string value
   */
  String name(int index)
  {
    return pod.name(index);
  }

  /**
   * Get method ref to sys::Type.find(String, boolean)
   */
  int typeFind()
  {
    if (typeFind == 0)
      typeFind = method("fanx/main/Sys.findType(Ljava/lang/String;Z)"+Sys.TypeClassJsig);
    return typeFind;
  }
  private int typeFind;

//////////////////////////////////////////////////////////////////////////
// Cached CpInfo
//////////////////////////////////////////////////////////////////////////

  int BoolBox, BoolUnbox;
  int IntBox, IntUnbox;
  int FloatBox, FloatUnbox;
  int IsViaType;
  int ErrMake;
  int TypeToNullable;
  int NullErrMakeCoerce;
  int ErrMakeAbstractCtorErr;
  int MethodParamDefErr;

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public Box classFile;
//  ClassType parent;
  FPod pod;
  FType type;
  String selfName;               // class name to use as self (for mixin body - this is interface)
  FieldEmit typeField;           // private static final Type $Type
  FieldEmit peerField;           // public static final TypePeer peer
  boolean hasInstanceInit;       // true if we already emitted <init>
  boolean hasStaticInit;         // true if we already emitted <clinit>
//  FuncType funcType;             // if type is a function
  boolean isFuncType;
  HashMap typeLiteralFields;     // signature Strings we need to turn into cached fields
  boolean isNative = false;      // do we have any native methods requiring a peer
  int lineNum;                   // line number of current type (or zero)

}