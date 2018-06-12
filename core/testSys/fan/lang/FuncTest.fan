//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Mar 08  Brian Frank  Creation
//

**
** FuncTest
**
@Js
class FuncTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  Void testTypeFits()
  {
    verifyFits(Num#, Int#, false)
    verifyFits(Int#, Num#, true)

    verifyFits(|Int a|#, |Int a|#,  true)
    verifyFits(|Num a|#, |Int a|#,  true)
    verifyFits(|Int a|#, |Num a|#,  false)

    verifyFits(|Int a|#,        |Int a, Int b|#, true)
    verifyFits(|Int a, Int b|#, |Int a|#, false)

    verifyFits(|->Void|#, |->Int|#,  false)
    verifyFits(|->Int|#,  |->Void|#, true)
    verifyFits(|->Int|#,  |->Num|#,  true)
    verifyFits(|->Num|#,  |->Int|#,  false)

    verifyFits(|Obj, Num, Str|#, |Obj, Num, Str|#, true)
    verifyFits(|Obj, Num, Str|#, |Str, Num, Str|#, true)
    verifyFits(|Obj, Num, Str|#, |Obj, Int, Str|#, true)
    verifyFits(|Str, Num, Str|#, |Obj, Num, Str|#, false)
    verifyFits(|Obj, Int, Str|#, |Obj, Num, Str|#, false)
    verifyFits(|Obj, Num|#,      |Str, Num, Str|#, true)
    verifyFits(|Obj, Num, Str|#, |Obj, Int|#, false)

    verifyFits(|Obj, Num, Str->Int|#, |Obj, Num, Str->Int|#,  true)
    verifyFits(|Obj, Num, Str->Int|#, |Obj, Int, Str->Num|#,  true)
    verifyFits(|Obj, Num, Str->Num|#, |Obj, Num, Str->Int|#,  false)
    verifyFits(|Obj, Num, Str->Int|#, |Str, Num, Str->Void|#, true)
    verifyFits(|Obj, Num, Str->Void|#, |Obj, Num, Str->Int|#, false)
  }

  Void verifyFits(Type a, Type b, Bool fits)
  {
    if (a.fits(b) != fits) echo("  FAILURE: $a fits $b  != $fits")
    verifyEq(a.fits(b), fits)
  }

//////////////////////////////////////////////////////////////////////////
// Callbacks
//////////////////////////////////////////////////////////////////////////

  Void testCallbacks()
  {
    x := 0

    invoke |->| { x++ }; verifyEq(x, 1)
    invoke |->Int| { return x++ }; verifyEq(x, 2)
    invoke |Int a| { x+=a }; verifyEq(x, 5)
    invoke |Int a->Int| { return x+=a }; verifyEq(x, 8)
  }

  Void invoke(|Int a, Int b| cb) { cb(3, 4) }

//////////////////////////////////////////////////////////////////////////
// Retype
//////////////////////////////////////////////////////////////////////////
/*
  Void testRetype()
  {
    x := |x,y->Obj?| { "$x, $y" }
    verifyEq(Type.of(x).signature, "|sys::Obj?,sys::Obj?->sys::Obj?|")
    verifyEq(x(3, 4), "3, 4")

    x = x.retype(|Int,Int?->Str|#)
    verifyEq(Type.of(x).signature, "|sys::Int,sys::Int?->sys::Str|")
    verifyEq(x(3, 4), "3, 4")

    y := Str#plus.func
    verifyEq(y.method, Str#plus)
    y = y.retype(|Str,Int->Str|#)
    verifyEq(Type.of(y).signature, "|sys::Str,sys::Int->sys::Str|")
    verifyEq(y.method, Str#plus)
    verifyEq(y("x", 5), "x5")
    verifyEq(y.callOn("x", [5]), "x5")
    verifyEq(y.callList(["x", 5]), "x5")
    verifyEq(y.call("x", 5), "x5")
    verifyEq(((Func)y).call("x", 5, "foo"), "x5")

    z := |a,b,c,d,e,f,g,h->Str| { "$a$b$c$d$e$f$g$h" }
    verifyEq(z.isImmutable, true)
    zSig := |Str a,Str b,Str c,Str d,Str e,Str f,Str g,Str h->Str|#
    verifyNotEq(Type.of(z), zSig)
    z = z.retype(zSig)
    verifyEq(z.isImmutable, true)
    verifyEq(Type.of(z), zSig)
    verifyEq(z("a", "b", "c", "d", "e", "f", "g", "h"), "abcdefgh")
    verifyEq(z.callOn("a", ["b", "c", "d", "e", "f", "g", "h"]), "abcdefgh")
    verifyEq(z.callList(["a", "b", "c", "d", "e", "f", "g", "h"]), "abcdefgh")

    verifyErr(ArgErr#) { z.retype(Str#) }
  }
*/
//////////////////////////////////////////////////////////////////////////
// Bind Calls
//////////////////////////////////////////////////////////////////////////
/*TODO
  Void testBindCalls()
  {
    // verify binding/calling
    verifyBind |->Str| { return "" }
    verifyBind |Str a->Str| { return a }
    verifyBind |Str a, Str b->Str| { return a + b  }
    verifyBind |Str a, Str b, Str c->Str| { return a + b + c }
    verifyBind |Str a, Str b, Str c, Str d->Str| { return a + b + c + d }
    verifyBind |Str a, Str b, Str c, Str d, Str e->Str| { return a + b + c + d + e }
    verifyBind |Str a, Str b, Str c, Str d, Str e, Str f->Str| { return a + b + c + d + e + f }
    verifyBind |Str a, Str b, Str c, Str d, Str e, Str f, Str g->Str| { return a + b + c + d + e + f + g }
    verifyBind |Str a, Str b, Str c, Str d, Str e, Str f, Str g, Str h->Str| { return a + b + c + d + e + f + g + h }
    verifyBind |Str a, Str b, Str c, Str d, Str e, Str f, Str g, Str h, Str i->Str| { return a + b + c + d + e + f + g + h + i }
    verifyBind |Str a, Str b, Str c, Str d, Str e, Str f, Str g, Str h, Str i, Str j->Str| { return a + b + c + d + e + f + g + h + i + j }
  }

  Void verifyBind(Func f)
  {
    args := Str[,]
    expected := ""
    verifyEq(f.params.size, f.arity)
    f.params.size.times |Int i|
    {
      ch := ('a' + i).toChar
      args.add(ch)
      expected += ch
    }

    verifyEq(f.callList(args), expected)

    args.size.times |Int i|
    {
      g := f.bind(args[0..<i])
      if (i == 0) verifySame(f, g)

      // call(List)
      a := args[i..-1]
      verifyEq(g.callList(a), expected)

      // callX
      switch (a.size)
      {
        case 0: verifyEq(g.call(), expected)
        case 1: verifyEq(g.call(a[0]), expected)
        case 2: verifyEq(g.call(a[0], a[1]), expected)
        case 3: verifyEq(g.call(a[0], a[1], a[2]), expected)
        case 4: verifyEq(g.call(a[0], a[1], a[2], a[3]), expected)
        case 5: verifyEq(g.call(a[0], a[1], a[2], a[3], a[4]), expected)
        case 6: verifyEq(g.call(a[0], a[1], a[2], a[3], a[4], a[5]), expected)
        case 7: verifyEq(g.call(a[0], a[1], a[2], a[3], a[4], a[5], a[6]), expected)
        case 8: verifyEq(g.call(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]), expected)
      }

      // callOn
      if (a.size >= 1) verifyEq(g.callOn(a[0], a[1..-1]), expected)
    }

    x := f.bind(args)
    verifyEq(x.callList([,]), expected)
    verifyEq(x.callList(["x", "y"]), expected)
    verifyEq(x.call, expected)
    verifyEq(x.call("x"), expected)
    verifyEq(x.call("x", "y"), expected)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Bind.isImmutable
//////////////////////////////////////////////////////////////////////////

  Void testBindIsImmutable()
  {
    // start off with immutable function
    f0 := |Obj? a, Obj b| {}
    verifyEq(f0.isImmutable, true)
    verifyEq(f0.bind([null]).isImmutable, true)
    verifyEq(f0.bind(["hi"]).isImmutable, true)
    verifyEq(f0.bind(["hi", 4]).isImmutable, true)
    verifyEq(f0.bind([this]).isImmutable, false)
    verifyEq(f0.bind(["hi", this]).isImmutable, false)

    // start off with mutable function
    f1 := |Obj? a| { echo(this) }
    verifyEq(f1.isImmutable, false)
    verifyEq(f1.bind([null]).isImmutable, false)
    verifyEq(f1.bind(["x"]).isImmutable, false)
    verifyEq(f1.bind([this]).isImmutable, false)

    // method with const class
    f2 := Int#toHex.func
    verifyEq(f2.isImmutable, true)
    verifyEq(f2.bind([33]).isImmutable, true)

    // method with non-const class
    f3 := #testBindIsImmutable.func
    verifyEq(f3.isImmutable, true)
    verifyEq(f3.bind([this]).isImmutable, false)
  }

//////////////////////////////////////////////////////////////////////////
// Bind Signatures
//////////////////////////////////////////////////////////////////////////
/*TODO
  Void testBindSig()
  {
    Func f := |Bool b, Int i, Float f, Str s->Str| { return "$b $i $f $s" }
    verifyEq(Type.of(f).signature, "|sys::Bool,sys::Int,sys::Float,sys::Str->sys::Str|")
    verifyEq(f.params.isRO, true)
    verifyParam(f.params[0], "b", Bool#)
    verifyParam(f.params[1], "i", Int#)
    verifyParam(f.params[2], "f", Float#)
    verifyParam(f.params[3], "s", Str#)
    verifyEq(f.returns, Str#)

    g := f.bind([true])
    verifyEq(Type.of(g).signature, "|sys::Int,sys::Float,sys::Str->sys::Str|")
    verifyEq(g.params.isRO, true)
    verifyParam(g.params[0], "i", Int#)
    verifyParam(g.params[1], "f", Float#)
    verifyParam(g.params[2], "s", Str#)
    verifyEq(g.returns, Str#)

    h := f.bind([true, 9, 4f])
    verifyEq(Type.of(h).signature, "|sys::Str->sys::Str|")
    verifyEq(h.params.isRO, true)
    verifyParam(h.params[0], "s", Str#)
    verifyEq(h.returns, Str#)

    i := g.bind([7])
    verifyEq(Type.of(i).signature, "|sys::Float,sys::Str->sys::Str|")
    verifyEq(h.params.isRO, true)
    verifyParam(i.params[0], "f", Float#)
    verifyParam(i.params[1], "s", Str#)
    verifyEq(i.returns, Str#)

    verifyEq(f.call(false, 8, 3f, "x"), "false 8 3.0 x")
    verifyEq(g.call(33, 6f, "y"), "true 33 6.0 y")
    verifyEq(i.callList([2f, "q"]), "true 7 2.0 q")
    verifyEq(i.call(2f, "q"), "true 7 2.0 q")
    verifyEq(i.bind([2f, "q"]).call, "true 7 2.0 q")
    verifyEq(i.bind([2f, "q"]).call('x'), "true 7 2.0 q")

    verifyErr(ArgErr#) { f.bind([true, 8, 8f, "x", "y"]) }
    verifyErr(ArgErr#) { i.bind([8f, "x", null]) }
  }

  Void verifyParam(Param p, Str n, Type t)
  {
    verifyEq(p.name, n)
    verifyEq(p.type, t)
  }

//////////////////////////////////////////////////////////////////////////
// Bind Def Params
//////////////////////////////////////////////////////////////////////////

  Void testBindDefParams()
  {
    o := BindDef()
    // instance methods
    verifyEq(BindDef#i.func.bind([o]).call, [1, 2, 3])
    verifyEq(BindDef#i.func.bind([o]).call(7), [7, 2, 3])
    verifyEq(BindDef#i.func.bind([o]).callList([7,8]), [7, 8, 3])
    verifyEq(BindDef#i.func.bind([o]).callList([7,8,9]), [7, 8, 9])
    verifyEq(BindDef#i.func.bind([o]).call(7,8,9), [7, 8, 9])

    verifyEq(BindDef#i.func.bind([o, 7]).call, [7, 2, 3])
    verifyEq(BindDef#i.func.bind([o, 7]).call(8), [7, 8, 3])
    verifyEq(BindDef#i.func.bind([o, 7]).callList([8,9]), [7, 8, 9])
    verifyEq(BindDef#i.func.bind([o, 7]).call(8,9), [7, 8, 9])

    verifyEq(BindDef#i.func.bind([o, 7, 8]).call, [7, 8, 3])
    verifyEq(BindDef#i.func.bind([o, 7, 8]).call(9), [7, 8, 9])
    verifyEq(BindDef#i.func.bind([o, 7, 8]).callList([9]), [7, 8, 9])

    verifyEq(BindDef#i.func.bind([o, 7, 8, 9]).call, [7, 8, 9])
    verifyEq(BindDef#i.func.bind([o, 7, 8, 9]).call(10), [7, 8, 9])

    // static methods
    verifyEq(BindDef#s.func.bind([7]).call, [7, 2, 3])
    verifyEq(BindDef#s.func.bind([7]).call(8), [7, 8, 3])
    verifyEq(BindDef#s.func.bind([7]).callList([8,9]), [7, 8, 9])
    verifyEq(BindDef#s.func.bind([7]).call(8,9), [7, 8, 9])

    verifyEq(BindDef#s.func.bind([7, 8]).call, [7, 8, 3])
    verifyEq(BindDef#s.func.bind([7, 8]).call(9), [7, 8, 9])
    verifyEq(BindDef#s.func.bind([7, 8]).callList([9]), [7, 8, 9])

    verifyEq(BindDef#s.func.bind([7, 8, 9]).call, [7, 8, 9])
    verifyEq(BindDef#s.func.bind([7, 8, 9]).call(10), [7, 8, 9])


    // ctor methods
    verifyEq(BindDef#make.func.bind([7]).call->list, [7, 2, 3])
    verifyEq(BindDef#make.func.bind([7]).call(8)->list, [7, 8, 3])
    verifyEq(BindDef#make.func.bind([7]).callList([8,9])->list, [7, 8, 9])
    verifyEq(BindDef#make.func.bind([7]).call(8,9)->list, [7, 8, 9])

    verifyEq(BindDef#make.func.bind([7, 8]).call->list, [7, 8, 3])
    verifyEq(BindDef#make.func.bind([7, 8]).call(9)->list, [7, 8, 9])
    verifyEq(BindDef#make.func.bind([7, 8]).callList([9])->list, [7, 8, 9])

    verifyEq(BindDef#make.func.bind([7, 8, 9]).call->list, [7, 8, 9])
    verifyEq(BindDef#make.func.bind([7, 8, 9]).callList([,])->list, [7, 8, 9])
    verifyEq(BindDef#make.func.bind([7, 8, 9]).call(10)->list, [7, 8, 9])
  }

//////////////////////////////////////////////////////////////////////////
// Method Func
//////////////////////////////////////////////////////////////////////////

  Void testMethodFunc()
  {
    func := #staticJudge.func
    verifyEq(func.call("Dredd"), "Dredd")
    verifyEq(func.callOn(null, ["Hershey"]), "Hershey")
    verifyEq(func.callList(["Anderson"]), "Anderson")
    verifyEq(func.arity, 1)

    func = #judge.func
    verifyEq(func.call(this, "Dredd"), "Dredd")
    verifyEq(func.callOn(this, ["Hershey"]), "Hershey")
    verifyEq(func.callList([this, "Anderson"]), "Anderson")
    verifyEq(func.arity, 2)

    echo("params -> ${func.params}")
    echo("typeof -> ${func.typeof}")
    echo("toStr  -> ${func}")
  }
  */

  Str judge(Str who) { who }
  static Str staticJudge(Str who) { who }
}

@Js internal class BindDef
{
  Int[] list := Int[,]
  new make(Int a := 1, Int b := 2, Int c := 3) { list = [a, b, c] }
  Int[] i(Int a := 1, Int b := 2, Int c := 3) { [a, b, c] }
  static Int[] s(Int a := 1, Int b := 2, Int c := 3) { [a, b, c] }
}