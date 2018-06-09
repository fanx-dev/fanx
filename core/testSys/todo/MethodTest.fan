//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Feb 06  Brian Frank  Creation
//

**
** MethodTest
**
@Js
class MethodTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Play
//////////////////////////////////////////////////////////////////////////

  Void testPlay()
  {
    m := |->Str| { return "hello" }
  }

//////////////////////////////////////////////////////////////////////////
// Is Operator
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    Func m := |->| {}
    verifyEq(Type.of(m).signature, "|->sys::Void|");
    verifyIsFunc(m)
    verify(m is |->|)
    verify(m is |->Void|)
    verify(m is |Int a|)
    verify(m is |Int a, Int b|)
    verifyFalse(m is |->Int|)

    m = |->Int| { return 0 }
    verifyIsFunc(m)
    verifyEq(Type.of(m).signature, "|->sys::Int|");
    verify(m is |->Int|)
    verify(m is |Str a->Int|)
    verify(m is |Str a, Int b->Int|)
    verify(m is |->Obj|)
    verifyFalse(m is |->Bool|)

    m = |Slot a| { }
    verifyIsFunc(m)
    verifyEq(Type.of(m).signature, "|sys::Slot->sys::Void|");
    verify(m is |Slot x|)
    verify(m is |Field x|)
    verify(m is |Method x|)
    verifyFalse(m is |Slot x->Str|)
    verifyFalse(m is |Obj x|)
    verifyFalse(m is |Str x|)

    m = |Slot s, Str x, Obj o->Str| { return x }
    verifyIsFunc(m)
    verifyEq(Type.of(m).signature, "|sys::Slot,sys::Str,sys::Obj->sys::Str|")
    verify(m is |Slot a, Str b, Obj c->Str|)
    verify(m is |Slot a, Str b, Obj c->Obj|)
    verify(m is |Slot a, Str b, Int c->Obj|)
    verify(m is |Field a, Str b, Obj c->Str|)
    verifyFalse(m is |Obj a, Obj b, Obj c->Int|)
    verifyFalse(m is |Slot a, Str b->Str|)
    verifyFalse(m is |Obj a, Str b, Obj c->Str|)
    verifyFalse(m is |Obj a, Obj b, Obj c->Str|)
    verifyFalse(m is |Obj a, Obj b, Obj c->Obj|)
  }

  Void verifyIsFunc(Func f)
  {
    obj := f as Obj
    verify(obj is Obj)
    verify(obj is Func)
    verifyFalse(obj is Method)
    verifyFalse(obj is Str)
  }

//////////////////////////////////////////////////////////////////////////
// As Operator
//////////////////////////////////////////////////////////////////////////

  // TODO

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  Void dummy0(|->| x) {}
  Void dummy1(|->Str| x) {}
  Void dummy2(|Float x| x) {}
  Void dummy3(|Float x, Int y->Str| x) {}
  Void dummy4(|Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h->Str| x) {}
  Void dummy5(|Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h, Type i->Str| x) {}
  Void dummy6(|Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h, Type i, Slot j| x) {}

  Void x0() {}
  Str? x1() { return null }
  Void x2(Float x) {}
  Str? x3(Float x, Int y) { return null }
  Str? x4(Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h) { return null }
  Str? x5(Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h, Type i) { return null }
  Void x6(Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h, Type i, Slot j) {}

  Void testFuncTypeof()
  {
    verifyFuncTypeof(#x0, |->|#)
    verifyFuncTypeof(#x1, |->Str?|#)
    verifyFuncTypeof(#x2, |Float|#)
    verifyFuncTypeof(#x3, |Float,Int->Str?|#)
    verifyFuncTypeof(#x4, |Float,Int,Bool,Str,Float,Int,Bool,Str->Str?|#)
  }

  Void verifyFuncTypeof(Method m, Type expected)
  {
    verifyEq(m.func.typeof, expected)
    verifySame(m.func, m.func)
    verifySame(m.func.typeof, m.func.typeof)
  }

  Void testReflectMethodParam()
  {
    t := Type.of(this)

    verifySig( t.method("dummy0").params[0].type,
      "|->sys::Void|", Type[,], Void#);

    verifySig( t.method("dummy1").params[0].type,
      "|->sys::Str|", Type[,], Str#);

    verifySig( t.method("dummy2").params[0].type,
      "|sys::Float->sys::Void|", [Float#], Void#);

    verifySig( t.method("dummy3").params[0].type,
      "|sys::Float,sys::Int->sys::Str|", [Float#, Int#], Str#);

    verifySig( t.method("dummy4").params[0].type,
      "|sys::Float,sys::Int,sys::Bool,sys::Str,sys::Float,sys::Int,sys::Bool,sys::Str->sys::Str|",
      [Float#, Int#, Bool#, Str#, Float#, Int#, Bool#, Str#], Str#);

    verifySig( t.method("dummy5").params[0].type,
      "|sys::Float,sys::Int,sys::Bool,sys::Str,sys::Float,sys::Int,sys::Bool,sys::Str,sys::Type->sys::Str|",
      [Float#, Int#, Bool#, Str#, Float#, Int#, Bool#, Str#, Type#], Str#);

    verifySig( t.method("dummy6").params[0].type,
      "|sys::Float,sys::Int,sys::Bool,sys::Str,sys::Float,sys::Int,sys::Bool,sys::Str,sys::Type,sys::Slot->sys::Void|",
      [Float#, Int#, Bool#, Str#, Float#, Int#, Bool#, Str#, Type#, Slot#], Void#);
  }

  Void testReflectClosures()
  {
    verifyFunc( |->|{},
      "|->sys::Void|", Type[,], Void#);

    verifyFunc( |->Str?| { return null},
      "|->sys::Str?|", Type[,], Str?#);

    verifyFunc( |Float x| {},
      "|sys::Float->sys::Void|", [Float#], Void#);

    verifyFunc( |Float x, Int y->Str| {return ""},
      "|sys::Float,sys::Int->sys::Str|", [Float#, Int#], Str#);

    verifyFunc( |Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h->Str| { return ""},
      "|sys::Float,sys::Int,sys::Bool,sys::Str,sys::Float,sys::Int,sys::Bool,sys::Str->sys::Str|",
      [Float#, Int#, Bool#, Str#, Float#, Int#, Bool#, Str#], Str#);

    verifyFunc( |Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h, Type i->Str| { return ""},
      "|sys::Float,sys::Int,sys::Bool,sys::Str,sys::Float,sys::Int,sys::Bool,sys::Str,sys::Type->sys::Str|",
      [Float#, Int#, Bool#, Str#, Float#, Int#, Bool#, Str#, Type#], Str#);

    verifyFunc( |Float a, Int b, Bool c, Str d, Float e, Int f, Bool g, Str h, Type i, Slot j| {},
      "|sys::Float,sys::Int,sys::Bool,sys::Str,sys::Float,sys::Int,sys::Bool,sys::Str,sys::Type,sys::Slot->sys::Void|",
      [Float#, Int#, Bool#, Str#, Float#, Int#, Bool#, Str#, Type#, Slot#], Void#);
  }

  Void verifyFunc(Func f, Str sig, Type[] params, Type ret)
  {
    fp := f.params
    verifyEq(f.returns, ret)
    for (Int i:=0; i<params.size; ++i)
    {
      verifyEq(params[i], fp[i].type)
    }

    verifySig(Type.of(f), sig, params, ret);
  }

  Void verifySig(Type t, Str sig, Type[] params, Type ret)
  {
    // echo("-- testReflectWith '" + t.qname + "' ?= " + sig + "; " + params + " ret=" + ret);

    // verify reflected identity
    verifyEq(t.pod, Obj#.pod)
    verifyEq(t.name, "Func")
    verifyEq(t.qname, "sys::Func")
    verifyEq(t.base, Func#)
    verifyEq(t.base.base, Obj#)
    verifyEq(t.signature, sig)
    verifyEq(t.toStr, sig)

    // verify callX parameterization
    for (Int i:=0; i<=8; ++i)
    {
      Method c := t.method("call")

      // verify return
      verifyEq(c.returns, ret)

      // verify p0..pn params
      for (Int j:=0; j<params.size && j<i; ++j)
      {
        verifyEq(c.params[j].type, params[j])
      }

      // verify rest left at Obj
      for (Int k:=params.size; k<8 && k<i; ++k)
      {
        verifyEq(c.params[k].type, Obj#)
      }
    }
  }

  Void testGenericStack() { foo(null) }
  Void foo(|Obj x|? m)
  {
    // this tests stack invariance when parameterized
    // is void, but generic is not
    if (m != null) m.call(9);
  }
}