//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;

import fanx.emit.FTypeEmit.LiteralType;
import fanx.fcode.*;
import fanx.fcode.FAttrs.FFacet;
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
//    boolean hasNative = (type.flags & FConst.Native) != 0;
	boolean resolved = false;
	if (type.attrs.facets != null) {
		for (FFacet facet : type.attrs.facets) {
			FTypeRef tr = type.pod.typeRef(facet.type);
			if (tr.podName.equals("sys") && tr.typeName.equals("NoPeer")) {
				hasPeer = false;
				resolved = true;
				break;
			}
		}
	}
	
    if (!resolved) {
      for (int i=0; i<type.methods.length; ++i)
        if ((type.methods[i].flags & Native) != 0) {
        	if ((type.methods[i].flags & Static) == 0 && (type.methods[i].flags & Ctor) == 0) {
        		this.hasPeer = true;
        		break;
        	}
        }
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
    if (hasPeer)
      peerField = emitField("peer", "L" + className + "Peer;", EmitConst.PUBLIC);
    else
      peerField = null;
    
//    if (isFuncType) {
//    	staticMethodHandleField = emitField("staticMethodHandle", "Ljava/lang/invoke/MethodHandle;", EmitConst.PUBLIC|EmitConst.STATIC|EmitConst.FINAL);
//    }
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
      // make const class once fields volatile
      int jflags = jflags(f.flags);
      if ((f.flags & FConst.Once) != 0 && (type.flags & FConst.Const) != 0)
        jflags |= EmitConst.VOLATILE;

      FieldEmit fe = emitField(f.name, pod.typeRef(f.type).jsig(), jflags);
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
    //for (int i=0; i<m.paramCount; ++i)
    //  if (m.vars[i].def != null) emitMethodParamDef(m, m.vars[i]);

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
//      code.op2(GETSTATIC, typeField.ref());
//      code.op2(CHECKCAST, cls("fan/sys/FuncType"));
//      code.op2(INVOKESPECIAL, method(superClassName +".<init>(Lfan/sys/FuncType;)V"));
//      
      code.op2(INVOKESPECIAL, method(superClassName +".<init>()V"));
      
//      code.op(ALOAD_0);
//      code.op2(GETSTATIC, staticMethodHandleField.ref());
//      code.op2(PUTFIELD, field("fan/sys/Func.methodHandle:Ljava/lang/invoke/MethodHandle;"));
      
      code.op(ALOAD_0);
      FTypeRef tref = pod.typeRef(type.base);
      code.op2(LDC_W, strConst(tref.signature));
      code.op2(PUTFIELD, field("fan/sys/Func.signature:Ljava/lang/String;"));
    }
    else
    {
      code.op2(INVOKESPECIAL, method(superClassName +".<init>()V"));
    }

//     make peer
    if (hasPeer)
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
    
//    if (isFuncType) {
//    	code.op2(LDC_W, cls(className));
//    	code.op2(INVOKESTATIC, method("fanx/main/Sys.findMethodHandle(Ljava/lang/Class;)Ljava/lang/invoke/MethodHandle;"));
//        code.op2(PUTSTATIC, staticMethodHandleField.ref());
//    }

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
    for (Map.Entry<String, LiteralType> entry : typeLiteralFields.entrySet())
    {
      String fieldName = entry.getKey();
      String fieldType = "";
      switch (entry.getValue()) {
	  case Type:
		  fieldType = Sys.TypeClassJsig;
		  break;
	  case Field:
		  fieldType = "Lfan/std/Field;";
		  break;
	  case Method:
		  fieldType = "Lfan/std/Method;";
		  break;
	  default:
		  throw new RuntimeException("unknow type:"+entry.getValue());
	  }
      emitField(fieldName, fieldType, EmitConst.PRIVATE|EmitConst.STATIC);
    }
  }
  
  /*  
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
        this.MethodParamDefErr = method("fan/std/Method.makeParamDefErr()Lfan/sys/Err;");
      code.reset();
      code.op2(INVOKESTATIC, this.MethodParamDefErr);
      code.op(ATHROW);
    }
  }
*/
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
  
  static class FatMethod {
	  FMethod method;
	  FType type;
  }

  private void emitMixinRouters()
  {
    // short circuit if no direct mixins implemented
    if (type.mixins.length == 0) return;

    // first we have to find all the mixins I inherit thru my
    // direct mixin inheritances (but not my class extension) - these
    // are the ones I need routers for (but I can skip generating
    // routers for any mixins implemented by my super class)
    HashMap<String,FatMethod> methods = new HashMap<String,FatMethod>();
    resolveMethodForMixin(type, methods);

    // emit routers for concrete instance methods
    Iterator<FatMethod> it = methods.values().iterator();
    while (it.hasNext())
    {
      FatMethod fm = (FatMethod)it.next();
      //class methods
      if (fm == null) continue;
      
//      fm.type.load();
      new FMethodEmit(this).emitMixinRouter(fm.method, fm.type);
//      emitMixinRouters(mixin);
    }
  }

  private void resolveMethodForMixin(FType t, HashMap<String,FatMethod> methods)
  {
	  t.load();
	  if (!t.isMixin()) {
		  //skip sys::Obj
		  if (t.base == 0xFFFF) return;
		  
		  //if is not mixin clear to null
		  for (Map.Entry<String, FSlot> entry : t.getSlotsMap().entrySet()) {
			  FSlot slot = entry.getValue();
			  if (slot.isStatic()) continue;
			  if (t != type && slot.isAbstract()) continue;
			  String name = entry.getKey();
			  if ("isMixin".equals(name)) {
				  System.out.print(name);
			  }
			  methods.put(name, null);
		  }
	  }
	  else {
		  for (FMethod m : t.methods) {
			  if (m.isStatic() || m.isAbstract()) continue;
			  if (!methods.containsKey(m.name)) {
				  FatMethod fm = new FatMethod();
				  fm.method = m;
				  fm.type = t;
				  methods.put(m.name, fm);
			  }
		  }
	  }
	  
//    // if mixin I haven't seen add to accumulator
//    String qname = t.qname();
//    if (((t.flags & FConst.Mixin) != 0)
//    		&& acc.get(qname) == null)
//      acc.put(qname, t);
//	
	//base class
	if (t.base != 0xFFFF) {
		FType x = Sys.getFTypeByRefId(t.pod, t.base);
		if (x != null) resolveMethodForMixin(x, methods);
	}

    //mixin
    for (int i=0; i<t.mixins.length; ++i) {
		FType x = Sys.getFTypeByRefId(t.pod, t.mixins[i]);
		if (x != null) resolveMethodForMixin(x, methods);
    }
  }

//  private void emitMixinRouters(FMethod m, FType type)
//  {
    // generate router method for each concrete instance method
//    FMethod[] methods = type.methods;
//    for (int i=0; i<methods.length; ++i)
//    {
//    	FMethod m = methods[i];

      // only emit router for non-abstract instance methods
//      if (m.isStatic() || m.isAbstract()) return;

      // only emit the router unless this is the exact one I inherit
//      String name = m.name;
//      if (parent.slot(name, true).parent() != type) continue;
      //already override

//       do it
//      new FMethodEmit(this).emitMixinRouter(m, type);
//    }
//  }

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
  enum LiteralType {
	  Type,Field,Method
  }
  
  public String literalField(LiteralType type, int i) {
	  String fieldName = "";
	  switch (type) {
	  case Type:
		  fieldName = "type$literal$"+i;
		  break;
	  case Field:
		  fieldName = "field$literal$"+i;
		  break;
	  case Method:
		  fieldName = "method$literal$"+i;
		  break;
	  }
	  
	  if (typeLiteralFields == null) typeLiteralFields= new HashMap<String, LiteralType>();
	  if (!typeLiteralFields.containsKey(fieldName)) {
		  typeLiteralFields.put(fieldName, type);
	  }
	  return fieldName;
  }

  public Box classFile;
//  ClassType parent;
  FPod pod;
  FType type;
  String selfName;               // class name to use as self (for mixin body - this is interface)
  FieldEmit typeField;           // private static final Type $Type
  FieldEmit peerField;           // public static final TypePeer peer
  FieldEmit staticMethodHandleField;
  boolean hasInstanceInit;       // true if we already emitted <init>
  boolean hasStaticInit;         // true if we already emitted <clinit>
//  FuncType funcType;             // if type is a function
  boolean isFuncType;
  private HashMap<String, LiteralType> typeLiteralFields;     // signature Strings we need to turn into cached fields
  private boolean hasPeer = false;      // do we have any native methods requiring a peer
//  private boolean hasNative = false;      // do we have any native methods requiring a peer
  int lineNum;                   // line number of current type (or zero)

}