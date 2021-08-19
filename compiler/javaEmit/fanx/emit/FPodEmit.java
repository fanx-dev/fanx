//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.emit;

import fanx.fcode.*;
import fanx.main.JavaType;
import fanx.main.Sys;
import fanx.main.Type;
import fanx.util.*;

/**
 * FPodEmit translates FPod fcode to Java bytecode as a class called <podName>.$Pod.
 * The pod class itself defines all the constants used by it's types.
 */
public class FPodEmit
  extends Emitter
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  public static FPodEmit emit(FPod pod)
    throws Exception
  {
    FPodEmit emit = new FPodEmit(pod);
    emit.classFile = emit.emit();
    return emit;
  }
  
  private static Object makeLiteral(String typeSig, String methodName, Object args, Class argClass) {
	  try {
		  Type type = Sys.findType(typeSig);
		  Class<?> clz = type.getJavaImplClass();
		  java.lang.reflect.Method method = clz.getMethod(methodName, argClass);
		  return method.invoke(null, args);
	  } catch (Throwable e) {
		  e.printStackTrace();
	  }
	  return null;
  }

  public static void initFields(FPod fpod, Class cls)
    throws Exception
  {
    FLiterals literals = fpod.readLiterals();

    // NOTE: ints, floats, and strings use direct Java constants

    // decimals
    for (int i=0; i<literals.decimals.size(); ++i) {
      Object obj = literals.decimals.get(i);
//      cls.getField("D"+i).set(null, makeLiteral("std::Decimal", "fromStr", obj, String.class));
      cls.getField("D"+i).set(null, obj);
    }
    literals.decimals = null;

    // durations
    for (int i=0; i<literals.durations.size(); ++i) {
      Object obj = literals.durations.get(i);
      cls.getField("Dur"+i).set(null, makeLiteral("std::Duration", "fromNanos", obj, long.class));
    }
    literals.durations = null;

    // uris
    for (int i=0; i<literals.uris.size(); ++i) {
      Object obj = literals.uris.get(i);
      cls.getField("U"+i).set(null, makeLiteral("std::Uri", "fromStr", obj, String.class));
    }
    literals.uris = null;

    // we only generate type fields for [java] types
    for (int i=0; i<fpod.typeRefs.size(); ++i)
    {
      FTypeRef t = fpod.typeRef(i);
      if (t.isFFI()) 
    	  cls.getField("Type" + i)
    	  .set(null, JavaType.loadJavaType(fpod.podClassLoader, t.podName, t.typeName));
    }
  }

  private FPodEmit(FPod pod)
    throws Exception
  {
    this.pod = pod;
    this.literals = pod.readLiterals();
  }

//////////////////////////////////////////////////////////////////////////
// Emit
//////////////////////////////////////////////////////////////////////////

  /**
   * Emit to bytecode classfile.
   */
  private Box emit()
  {
	String clzName = "fan/" + pod.podName + "/$Pod";
    init(clzName, "java/lang/Object", new String[0], EmitConst.PUBLIC | EmitConst.FINAL);

    // NOTE: ints, floats, and strings use direct Java constants

    // generate constant fields other types will reference, we don't
    // initialize them, rather we do that later via reflection
    for (int i=0; i<literals.decimals.size(); ++i)
      emitField("D" + i, "Ljava/math/BigDecimal;", EmitConst.PUBLIC | EmitConst.STATIC);
    for (int i=0; i<literals.durations.size(); ++i)
      emitField("Dur" + i, "Lfan/std/Duration;", EmitConst.PUBLIC | EmitConst.STATIC);
    for (int i=0; i<literals.uris.size(); ++i)
      emitField("U" + i, "Lfan/std/Uri;", EmitConst.PUBLIC | EmitConst.STATIC);

    // we only generate type fields for [java] types
    for (int i=0; i<pod.typeRefs.size(); ++i)
      if (pod.typeRef(i).isFFI())
        emitField("Type" + i, Sys.TypeClassJsig, EmitConst.PUBLIC | EmitConst.STATIC);

    
    MethodEmit me = emitMethod("<clinit>", "()V", EmitConst.PUBLIC|EmitConst.STATIC);
    CodeEmit code = me.emitCode();
    code.maxLocals = 0;
    code.maxStack  = 2;
    
    code.op2(LDC_W, strConst(pod.podName));
    code.op2(LDC_W, cls(clzName));
    code.op2(INVOKESTATIC, method("fanx/emit/FPodEmit.onStaticInit(Ljava/lang/String;Ljava/lang/Class;)V"));
    code.op(RETURN);
    
    return pack();
  }
  
  public static void onStaticInit(String podName, Class cls) {
	FPod pod = Sys.findPod(podName);
	try {
		initFields(pod, cls);
	} catch (Exception e) {
		e.printStackTrace();
	}
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public Box classFile;
  FPod pod;
  FLiterals literals;

}