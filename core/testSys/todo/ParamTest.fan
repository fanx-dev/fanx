//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jun 06  Brian Frank  Creation
//

**
** ParamTest
**
class ParamTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Succ Param
//////////////////////////////////////////////////////////////////////////

  Void testSuccParam()
  {
    // here we want to test that param def expressions which use the
    // value of a parameter def expression earlier in the list (the
    // compiler should generate a store instruction for these cases)

    verifyEq(succParam(),            "1 2 3 -3")
    verifyEq(succParam(2),           "2 3 5 -5")
    verifyEq(succParam(2, 0),        "2 0 2 -2")
    verifyEq(succParam(2, 0, -1),    "2 0 -1 1")
    verifyEq(succParam(2, 0, -1, 7), "2 0 -1 7")

    // TODO test error if using param defs after in list
  }

  Str succParam(Int a := 1, Int b := a+1, Int c := a+b, Int d := -c)
  {
    return "$a $b $c $d"
  }

//////////////////////////////////////////////////////////////////////////
// Abstract with Defaults
//////////////////////////////////////////////////////////////////////////

  Void testAbstractWithDefaults()
  {
    verifyEq(ParamConcrete.make.foo, "a b")
    verifyEq(ParamConcrete.make.foo("x"), "x b")
    verifyEq(ParamConcrete.make.foo("x", "y"), "x y")
    verifyEq(ParamConcrete.make.map, ["a":"b"])
  }

}

//////////////////////////////////////////////////////////////////////////
// ParamAbstract
//////////////////////////////////////////////////////////////////////////

abstract class ParamAbstract
{
  abstract Str foo(Str a := "a", Str b := "b")
  abstract Str:Str map();
}

class ParamConcrete : ParamAbstract
{
  override Str foo(Str a := "a", Str b := "b")
  {
    return "$a $b"
  }

  override Str:Str map() { return ["a":"b"] }
}