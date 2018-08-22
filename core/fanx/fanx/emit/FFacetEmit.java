//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Sep 10  Brian Frank  Creation
//
package fanx.emit;

import java.lang.reflect.Constructor;

import fanx.fcode.FAttrs;
import fanx.fcode.FConst;
import fanx.fcode.FPod;
import fanx.fcode.FTypeRef;
import fanx.main.Sys;
import fanx.util.Box;
import fanx.util.Reflection;

/**
 * FFacetEmit is used to emit Fantom facets as Java annotations.
 */
class FFacetEmit
  implements FConst
{

//////////////////////////////////////////////////////////////////////////
// Factories for Type, Field, and Methods
//////////////////////////////////////////////////////////////////////////

  static void emitType(Emitter emit, FPod pod, FAttrs attrs)
  {
    FFacetEmit x = new FFacetEmit(emit, pod, attrs);
    if (x.num == 0) return;

    AttrEmit attr = emit.emitAttr("RuntimeVisibleAnnotations");
    x.doEmit(attr.info);
  }

  static void emitField(FieldEmit fe, FPod pod, FAttrs attrs)
  {
    FFacetEmit x = new FFacetEmit(fe.emit, pod, attrs);
    if (x.num == 0) return;

    AttrEmit attr = fe.emitAttr("RuntimeVisibleAnnotations");
    x.doEmit(attr.info);
  }

  static void emitMethod(MethodEmit me, FPod pod, FAttrs attrs)
  {
    FFacetEmit x = new FFacetEmit(me.emit, pod, attrs);
    if (x.num == 0) return;

    AttrEmit attr = me.emitAttr("RuntimeVisibleAnnotations");
    x.doEmit(attr.info);
  }

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  private FFacetEmit(Emitter emit, FPod pod, FAttrs attrs)
  {
    this.emit   = emit;
    this.pod    = pod;
    this.facets = attrs.facets;
    this.num    = computeNumJavaFacets();
  }

  private int computeNumJavaFacets()
  {
    if (facets == null) return 0;
    int num = 0;
    for (int i=0; i <facets.length; ++i)
      if (pod.typeRef(facets[i].type).isFFI()) num++;
    return num;
  }

//////////////////////////////////////////////////////////////////////////
// RuntimeVisibleAnnotation Generation
//////////////////////////////////////////////////////////////////////////

  private void doEmit(Box info)
  {
    info.u2(num);
    try
    {
      for (int i=0; i <facets.length; ++i)
      {
        FAttrs.FFacet facet = facets[i];
        FTypeRef type = pod.typeRef(facet.type);
        if (type.isFFI()) encode(info, type, facet.val);
      }
    }
    catch (Exception e)
    {
      System.out.println("ERROR: Cannot emit annotations for " + emit.className);
//      System.out.println("  Facet type: " + curType);
      e.printStackTrace();
      info.len = 0;
      info.u2(0);
    }
  }

  private void encode(Box info, FTypeRef type, String val)
    throws Exception
  {
	 Class clz = Sys.findPod("std").podClassLoader.loadClass("fanx.interop.FacetEncoder");
	 Constructor ctor = clz.getConstructor(Emitter.class);
	 Object facetEncoder = ctor.newInstance(emit);
	 Reflection.callMethod(facetEncoder, "encode", type, val);
  }
  
////////////////////////////////////////////////////////////////////////////
//// Fields
////////////////////////////////////////////////////////////////////////////
  
  private final Emitter emit;       // class emitter
  private final FPod pod;           // pod being emitted
  private final FAttrs.FFacet[] facets; // all the facets (java and non-java)
  private final int num;            // num of Java annotations in facets
}