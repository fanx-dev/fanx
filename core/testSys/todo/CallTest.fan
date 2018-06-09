//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 06  Brian Frank  Creation
//

**
** CallTest
**
class CallTest : Test
{

//////////////////////////////////////////////////////////////////////////
// NonVirtual
//////////////////////////////////////////////////////////////////////////

  Void testNonVirtual()
  {
    a := CallA.make
    b := CallB.make

    // super must be non-virtual
    a.callSuper("brian"); verifyEq(a.val, "brian")
    b.callSuper("brian"); verifyEq(b.val, "[brian]")

    // private should be non-virtual
    a.callSecret("andy"); verifyEq(a.val, "andy")
    b.callSecret("andy"); verifyEq(b.val, "andy")

    // non-virtuals calls on this should be non-virtual
    a.callPub("john"); verifyEq(a.val, "public: john")
    b.callPub("john"); verifyEq(b.val, "public: john")
  }

//////////////////////////////////////////////////////////////////////////
// Dynamic Call
//////////////////////////////////////////////////////////////////////////

  Void testDynamicCall()
  {
    c := CallDynamic.make
    Obj obj := c

    // Obj.toStr
    verifyEq(obj->toStr, c.toStr)
    verifyEq(c.name,  "toStr")
    verifyEq(c.args,  null)

    // Obj.toStr
    verifyEq(obj.trap("toStr"), c.toStr)
    verifyEq(c.name,  "toStr")
    verifyEq(c.args,  null)

    // no arg
    verifyEq(obj->m0, "m0()")
    verifyEq(c.name,  "m0")
    verifyEq(c.args,  null)

    // no arg
    verifyEq(obj.trap("m0"), "m0()")
    verifyEq(c.name,  "m0")
    verifyEq(c.args,  null)

    // no arg
    verifyEq(obj->m0(), "m0()")
    verifyEq(c.name,  "m0")
    verifyEq(c.args,  null)

    // one arg
    verifyEq(obj->m1("x"), "m1(x)")
    verifyEq(c.name,  "m1")
    verifyEq(c.args,  Obj?["x"])

    // one arg
    verifyEq(obj.trap("m1", ["x"]), "m1(x)")
    verifyEq(c.name,  "m1")
    verifyEq(c.args,  ["x"])

    // two arg
    verifyEq(obj->m2("x", "y"), "m2(x, y)")
    verifyEq(c.name,  "m2")
    verifyEq(c.args,  Obj?["x", "y"])

    // static
    verifyEq(obj->s0(), "s0()")
    verifyEq(c.name,  "s0")
    verifyEq(c.args,  null)

    // field get
    verifyEq(obj->f, "f")
    verifyEq(c.name,  "f")
    verifyEq(c.args,  null)

    // field set
    verifyEq(obj->f = "foo", "foo")
    verifyEq(c.f, "foo")
    verifyEq(c.name,  "f")
    verifyEq(c.args,  Obj?["foo"])

    // static field get
    verifyEq(obj->sf, "sf")
    verifyEq(c.name,  "sf")
    verifyEq(c.args,  null)

    // closure arg
    verifyEq([0, 1, 2]->find |Int x->Bool| { return x == 2 }, 2)
    verifyEq([0, 1, 2]->find(|Int x->Bool| { return x == 2 }), 2)

    // errors
    verifyErr(UnknownSlotErr#) { obj->blah }
  }

}

//////////////////////////////////////////////////////////////////////////
// CallA
//////////////////////////////////////////////////////////////////////////

class CallA
{
  virtual Void callSuper(Str s) { val = s; }

  Void callPub(Str s) { pub(s); }
  Void pub(Str s) { val = "public: " + s; }

  Void callSecret(Str s) { secret(s); }
  private Int? secret(Str s) { val = s; return null }

  Str? val;
}

class CallB : CallA
{
  override Void callSuper(Str s) { super.callSuper(s);  val = "[" + val + "]" }

  private Int? secret(Str s) { val = "wrong!";  return null  }
}

class CallDynamic
{
  override Obj? trap(Str name, Obj?[]? args := null)
  {
    this.name = name
    this.args = args
    return super.trap(name, args)
  }

  Str m0() { return "m0()" }
  Str m1(Str a) { return "m1($a)" }
  Str m2(Str a, Str b) { return "m2($a, $b)" }

  static Str s0() { return "s0()" }

  Str f := "f"
  const static Str sf := "sf"

  Str? name
  Obj[]? args
}