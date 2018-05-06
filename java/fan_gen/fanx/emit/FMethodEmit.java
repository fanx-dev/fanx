//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Mar 06  Brian Frank  Creation
//
package fanx.emit;

import java.util.*;
import fanx.fcode.*;
import fanx.util.*;

/**
 * FMethodEmit is used to emit Java bytecode methods from fcode methods.
 * It encapsulates lot of nitty details like when to include an implicit
 * self paramater, etc.
 */
public class FMethodEmit
  implements EmitConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  /**
   * Constructor
   */
  public FMethodEmit(FTypeEmit emit, FMethod method)
  {
    this.emit     = emit;
    this.method   = method;
    this.code     = method.code;
    this.name     = method.name;
    this.jflags   = FTypeEmit.jflags(method.flags);
    this.paramLen = method.paramCount;
    this.isStatic = (method.flags & FConst.Static) != 0;
    this.isCtor   = (method.flags & FConst.Ctor) != 0;
    this.isNative = (method.flags & FConst.Native) != 0;
    this.ret      = emit.pod.typeRef(method.inheritedRet); // we don't actually use Java covariance
    this.selfName = emit.selfName;
    this.lineNum  = method.attrs.lineNum;
  }

  /**
   * Constructor
   */
  public FMethodEmit(FTypeEmit emit)
  {
    this.emit = emit;
  }

//////////////////////////////////////////////////////////////////////////
// Emit
//////////////////////////////////////////////////////////////////////////

  /**
   * Emit a standard instance/static class method.
   */
  public MethodEmit emitStandard()
  {
    // emit method
    MethodEmit main = doEmit();

    // emit param default wrappers
    emitWrappers(main);

    return main;
  }

  /**
   * Emit a constructor - constructors get created as a static
   * factory methods, so that that CallNew can just push args
   * and invoke them
   *   fan:
   *     class Foo { new make(Int? a) { ... } }
   *   java:
   *     static Foo make(Long a) { return make$(new Foo(), a) }
   *     static Foo make$(Foo self, Long a) { ... return self }
   *
   * We call the first method "make" the "factory" and the
   * second method "make$" the "body".  CallNew opcodes are
   * routed to the ctor factory, and CallCtor opcodes are routed
   * to the ctor body.
   */
  public MethodEmit emitCtor()
  {
    String ctorName = this.name;

    // both factory and body are static from Java's perspective
    this.jflags |= STATIC;
    this.isStatic = true;

    // first emit the body with implicit self
    this.name   = ctorName + "$";
    this.self   = true;
    MethodEmit body = doEmit();

    // emit body default parameter wrappers
    MethodEmit[] wrappers = emitWrappers(body);

    // then emit the factory
    this.name = ctorName;
    this.self = false;
    this.ret  = emit.pod.typeRef(emit.type.self);
    this.code = null;
    boolean isAbstract = (emit.type.flags & FConst.Abstract) != 0;
    int init = isAbstract ? -1 : emit.method(selfName+ ".<init>()V");
    MethodEmit factory = emitCtorFactory(init, body, method.paramCount);

    // emit separate factory for each method with default
    // parameters: note each factory allocs the object and
    // passes it to the make$ wrapper; we rely on the make$
    // wrappers to do default params because the factory's
    // signature doesn't match up to what the Fantom compiler
    // generated (ctor assumes local_0 is this pointer)
    for (int i=0; i<method.paramCount; ++i)
      if (method.vars[i].def != null)
        emitCtorFactory(init, wrappers[i], i);

    // return static factory as our primary Java method
    return factory;
  }

  /**
   * Emit the factory part of the constructor:
   *   fan:
   *     new make(Int a, Obj? b := null) {...}
   *   java:
   *     static Foo make(long a) { return make$(new Foo(), a) }
   *     static Foo make(long a, Object b) { return make$(new Foo(), a, b) }
   *
   * If init is -1, then this an abstract method and we just raise exception.
   */
  private MethodEmit emitCtorFactory(int init, MethodEmit body, int paramLen)
  {
    this.paramLen = paramLen;
    MethodEmit factory = doEmit();
    CodeEmit code = factory.emitCode();
    if (init < 0)
    {
      // abstract factory
      code.maxLocals = 2 + paramLen * 2;
      code.maxStack  = 2;
      if (emit.ErrMakeAbstractCtorErr == 0) emit.ErrMakeAbstractCtorErr = emit.method("fan/sys/Err.makeAbstractCtorErr(Ljava/lang/String;)Lfan/sys/Err;");
      code.op2(LDC_W, emit.strConst(emit.type.qname()));
      code.op2(INVOKESTATIC, emit.ErrMakeAbstractCtorErr);
      code.op(ATHROW);
    }
    else
    {
      // concrete factory
      code.op2(NEW, emit.cls(selfName));
      code.op(DUP);
      code.op2(INVOKESPECIAL, init);
      code.op(DUP);
      code.maxLocals = pushArgs(code, false, paramLen);
      code.maxStack  = code.maxLocals + 2;
      code.op2(INVOKESTATIC, body.ref());
      code.op(ARETURN);
    }
    code.emitLineNumber(lineNum);
    return factory;
  }

  /**
   * Emit a Fantom constructor for a class which subclasses from
   * a normal Java class brought into the Fantom type system via FFI.
   * In this case the superclass constructor is a real constructor
   * so we need to emit the code differently:
   *   fan:
   *     class Foo { new make(String a) { ... } }
   *   java:
   *     static Foo make(String a) { return new Foo(a) }
   *     Foo(String a) { ... }
   */
  public MethodEmit emitCtorWithJavaSuper()
  {
    String ctorName = this.name;

    // first emit the body as a true Java constructor
    this.name = "<init>";
    MethodEmit body = doEmit();

    // emit body default parameter wrappers
    emitWrappers(body);

    // then emit the factory
    this.name = ctorName;
    this.self = false;
    this.ret  = emit.pod.typeRef(emit.type.self);
    this.code = null;
    this.jflags |= STATIC;
    this.isStatic = true;
    MethodEmit factory = doEmit();
    CodeEmit code = factory.emitCode();
    code.op2(NEW, emit.cls(selfName));
    code.op(DUP);
    code.maxLocals = pushArgs(code, false, method.paramCount) + 1;
    code.maxStack  = code.maxLocals + 2;
    code.op2(INVOKESPECIAL, body.ref());
    code.op(ARETURN);
    code.emitLineNumber(lineNum);

    // emit factory default parameter wrappers
    emitWrappers(factory);
    return factory;
  }

  /**
   * Emit a native method
   */
  public MethodEmit emitNative()
  {
    // emit an empty method
    this.code = null;
    MethodEmit main = doEmit();

    // emit code which calls the peer
    CodeEmit code = main.emitCode();
    if (isStatic)
    {
      int peerMethod = emit.method(selfName + "Peer." + name + sig);
      code.maxLocals = pushArgs(code, false, paramLen);
      code.maxStack  = Math.max(code.maxLocals, 2);
      code.op2(INVOKESTATIC, peerMethod);
    }
    else
    {
      // generate peer's signature with self
      this.self = true;
      String sig = signature();
      this.self = false;

      int peerMethod = emit.method(selfName + "Peer." + name + sig);
      code.op(ALOAD_0);
      code.op2(GETFIELD, emit.peerField.ref());
      code.maxLocals = pushArgs(code, true, paramLen) + 1;
      code.maxStack  = Math.max(code.maxLocals, 2);
      code.op2(INVOKEVIRTUAL, peerMethod);
    }
    code.op(FCodeEmit.returnOp(ret));

    // emit default parameter wrappers
    emitWrappers(main);
    return main;
  }


  /**
   * Emit the method as a mixin interface
   */
  public void emitMixinInterface()
  {
    // we only emit instance methods in the interface
    if (isStatic || isCtor) return;

    // set abstract/public flags and clear code
    this.jflags |= (ABSTRACT | PUBLIC);
    this.code = null;

    // emit main
    doEmit();

    // emit a signature for each overload based on param defaults
    for (int i=0; i<method.paramCount; ++i)
    {
      if (method.vars[i].def != null)
      {
        paramLen = i;
        doEmit();
      }
    }
  }

  /**
   * Emit the method as a mixin body class which ends with $.
   */
  public void emitMixinBody()
  {
    // skip abstract methods without code
    if (method.code == null) return;

    // instance methods have an implicit self
    if (!isStatic) this.self = true;

    // bodies are always public static
    this.jflags |= (STATIC | PUBLIC);

    // emit main body
    MethodEmit main = doEmit();

    // emit param default wrappers
    emitWrappers(main);
  }

  /**
   * Emit a mixin router from a class to the mixin body methods.
   */
  public void emitMixinRouter(FMethod m, FType type)
  {
    String parent  = "fan/" + type.podName() + "/" + type.typeName();
    String name    = m.name;
    int jflags     = emit.jflags(m.flags) | PUBLIC | SYNTHETIC;
    FMethodVar[] params    = m.params();
    int paramCount = params.length;

    // find first param with default value
    int firstDefault = paramCount;
    for (int i=0; i<paramCount; ++i)
      if (params[i].hasDefault())
        { firstDefault = i; break; }

    // generate routers
    for (int i=firstDefault; i<=paramCount; ++i)
    {
      String mySig = signature(m, null, i, type);
      String implSig = signature(m, parent, i, type);

      MethodEmit me = emit.emitMethod(name, mySig, jflags);
      CodeEmit code = me.emitCode();
      code.op(ALOAD_0); // push this
      int jindex = 1;
      for (int p=0; p<i; ++p)
      {
        // push args
    	FMethodVar param = m.params()[p];
        jindex = FCodeEmit.loadVar(code
        		, FanUtil.toJavaStackType(type.pod.typeRef(param.type)), jindex);
      }
      code.op2(INVOKESTATIC, emit.method(parent + "$." + name + implSig));
      code.op(FCodeEmit.returnOp(FanUtil.toJavaStackType(type.pod.typeRef(m.ret))));
      code.maxLocals = jindex;
      code.maxStack = jindex+1;  // leave room for wide return

      // use line number of class header
      code.emitLineNumber(emit.lineNum);
    }
  }

//////////////////////////////////////////////////////////////////////////
// Param Default Wrappers
//////////////////////////////////////////////////////////////////////////

  /**
   * Emit wrappers, return wrapper methods indexed by param length or null.
   */
  private MethodEmit[] emitWrappers(MethodEmit main)
  {
    // change flags so that defaults aren't abstract
    int oldFlags = this.jflags;
    this.jflags = jflags & ~ABSTRACT;

    // handle generating default param wrappers
    MethodEmit[] wrappers = null;
    for (int i=0; i<method.paramCount; ++i)
      if (method.vars[i].def != null)
      {
        if (wrappers == null) wrappers = new MethodEmit[method.paramCount];
        wrappers[i] = emitWrapper(main, i);
      }
    this.paramLen = method.paramCount;

    this.jflags = oldFlags;
    return wrappers;
  }

  /**
   * Emit wrapper.
   */
  private MethodEmit emitWrapper(MethodEmit main, int paramLen)
  {
    // use explicit param count, and clear code
    this.paramLen = paramLen;
    this.code     = null;

    // emit code
    CodeEmit code  = doEmit().emitCode();

    // push arguments passed thru
    pushArgs(code, !(isStatic && !self), paramLen);

    // emit default arguments
    FCodeEmit.Reg[] regs = FCodeEmit.initRegs(emit, isStatic & !isCtor, method.vars);
    for (int i=paramLen; i<method.paramCount; ++i)
    {
      FCodeEmit e = new FCodeEmit(emit, method.vars[i].def, code, regs, emit.pod.typeRef(method.ret));
      e.emit();
    }
    code.maxStack = code.maxLocals + 4; // leave room for wide return or type literal loading and null coercion

    // call master implementation
    code.op2((main.flags & STATIC) != 0 ? INVOKESTATIC : INVOKEVIRTUAL, main.ref());

    // return
    code.op(FCodeEmit.returnOp(ret));

    return me;
  }

//////////////////////////////////////////////////////////////////////////
// Emit
//////////////////////////////////////////////////////////////////////////

  /**
   * This is the method that all the public emitX methods
   * route to once everything is setup correctly.
   */
  protected MethodEmit doEmit()
  {
    this.sig = signature();
    this.me = emit.emitMethod(name, sig, jflags);
    if (code != null)
    {
      new FCodeEmit(emit, method, me.emitCode()).emit();
    }
    return this.me;
  }

//////////////////////////////////////////////////////////////////////////
// Signature Utils
//////////////////////////////////////////////////////////////////////////

  /**
   * Generate the java method signature base on our current setup.
   */
  private String signature()
  {
    StringBuilder sig = new StringBuilder();

    // params (with optional implicit self)
    sig.append('(');
    if (self) sig.append('L').append(selfName).append(';');
    for (int i=0; i<paramLen; ++i)
      emit.pod.typeRef(method.vars[i].type).jsig(sig);
    sig.append(')');

    // return
    ret.jsig(sig);

    return sig.toString();
  }

  /**
   * Generate a method signature from a reflection sys::Method.
   */
  private String signature(FMethod m, String self, int paramLen, FType type)
  {
    StringBuilder sig = new StringBuilder();

    // params
    sig.append('(');
    if (self != null) sig.append('L').append(self).append(';');
    for (int i=0; i<paramLen; ++i)
    {
    	FMethodVar param = m.params()[i];
    	FTypeRef pt = type.pod.typeRef(param.type);
    	sig.append(FanUtil.toJavaMemberSig(pt));
    }
    sig.append(')');

    // return
    sig.append(FanUtil.toJavaMemberSig(type.pod.typeRef(m.inheritedRet)));

    return sig.toString();
  }

//////////////////////////////////////////////////////////////////////////
// Code Utils
//////////////////////////////////////////////////////////////////////////

  /**
   * Push the specified number of arguments onto the stack.
   */
  private int pushArgs(CodeEmit code, boolean self, int count)
  {
    int jindex = 0;
    if (self) { code.op(ALOAD_0); ++jindex; }
    for (int i=0; i<count; ++i)
    {
      FTypeRef var = emit.pod.typeRef(method.vars[i].type);
      jindex = FCodeEmit.loadVar(code, var.stackType, jindex);
    }
    return jindex;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FTypeEmit emit;    // parent type class emitter
  FMethod method;    // fan method info
  FBuf code;         // code to emit
  String name;       // method name
  int jflags;        // java flags
  boolean isStatic;  // are we emitting a static method
  boolean isCtor;    // are we emitting a constructor
  boolean isNative;  // are we emitting a native method
  FTypeRef ret;      // java return sig
  boolean self;      // add implicit self as first parameter
  String selfName;   // class name for self if self is true
  int paramLen;      // number of parameters to use
  String sig;        // last java signature emitted
  MethodEmit me;     // last java method emitted
  int lineNum;       // line number of method (or zero)


}