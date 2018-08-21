//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Sep 10  Brian Frank  Creation
//
package fanx.emit;

import fanx.fcode.FAttrs;
import fanx.fcode.FConst;
import fanx.fcode.FPod;
import fanx.main.Sys;
import fanx.util.Reflection;

/**
 * FFacetEmit is used to emit Fantom facets as Java annotations.
 */
class FFacetEmit implements FConst {
	static Class clz = null;

	static void init() {
		if (clz != null) return;
		try {
			clz = Sys.findPod("std").podClassLoader.loadClass("fanx.interop.FFacetEmit");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}

	public static void emitFacet(Emitter emit, FPod pod, FAttrs attrs, AttrEmit attr) {
//		init();
//		Reflection.callStaticMethod(clz, "emitFacet", emit, pod, attrs, attr);
	}
	
	//////////////////////////////////////////////////////////////////////////
	// Factories for Type, Field, and Methods
	//////////////////////////////////////////////////////////////////////////

	static void emitType(Emitter emit, FPod pod, FAttrs attrs) {
		AttrEmit attr = emit.emitAttr("RuntimeVisibleAnnotations");
		emitFacet(emit, pod, attrs, attr);
	}

	static void emitField(FieldEmit fe, FPod pod, FAttrs attrs) {
		AttrEmit attr = fe.emitAttr("RuntimeVisibleAnnotations");
		emitFacet(fe.emit, pod, attrs, attr);
	}

	static void emitMethod(MethodEmit me, FPod pod, FAttrs attrs) {
		AttrEmit attr = me.emitAttr("RuntimeVisibleAnnotations");
		emitFacet(me.emit, pod, attrs, attr);
	}
}