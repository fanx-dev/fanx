//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Oct 06  Brian Frank  Creation
//

**
** ConstantFoldingTest
**
class ConstantFoldingTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// Int
//////////////////////////////////////////////////////////////////////////

  Void testInt()
  {
    compile(
     "class Foo
      {
        static Int star()    { return 2 * 3 }
        static Int slash()   { return 8 / 3 }
        static Int percent() { return 8 % 5 }
        static Int plus()    { return 4 + 3 }
        static Int minus()   { return 10 - 7 }
        static Int negate()  { return -1 }
        static Str toString(){ return 5.toStr }
        static Str toHex()   { return 0xabcd.toHex }
        static Str toChar()  { return 'w'.toChar }
        static Int mix()     { return 2+10/5-4 }
      }")
     verifyMethodReturns("star",    6)
     verifyMethodReturns("slash",   2)
     verifyMethodReturns("percent", 3)
     verifyMethodReturns("plus",    7)
     verifyMethodReturns("minus",   3)
     verifyMethodReturns("negate",  -1)
     verifyMethodReturns("toString", "5")
     verifyMethodReturns("toHex",   "abcd")
     verifyMethodReturns("toChar",  "w")
     verifyMethodReturns("mix",     0)
  }

//////////////////////////////////////////////////////////////////////////
// Float
//////////////////////////////////////////////////////////////////////////

  Void testFloat()
  {
    compile(
     "class Foo
      {
        static Float star()    { return 2.0f * 3.0f }
        static Float slash()   { return 8.0f / 4.0f }
        static Float percent() { return 8.0f % 5.0f }
        static Float plus()    { return 4.0f + 3.0f }
        static Float minus()   { return 10.0f - 7.0f }
        static Float negate()  { return -100.0f }
        static Float max()     { return 6f.max(7f) }
        static Float min()     { return 6f.min(7f) }
        static Float mix()     { return 2f+10f/5f-4f }
      }")
     verifyMethodReturns("star",    6.0f)
     verifyMethodReturns("slash",   2.0f)
     verifyMethodReturns("percent", 3.0f)
     verifyMethodReturns("plus",    7.0f)
     verifyMethodReturns("minus",   3.0f)
     verifyMethodReturns("negate",  -100.0f)
     //verifyMethodReturns("max",     7.0f)
     //verifyMethodReturns("min",     6.0f)
     verifyMethodReturns("mix",     0.0f)
  }

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

  Void testStr()
  {
    compile(
     "class Foo
      {
        static Str plus2() { return \"a\" + \"b\" }
        static Str plus3() { return \"a\" + \"b\" + \"c\" }
        static Str trim()  { return \" abc \".trim }
      }")
     verifyMethodReturns("plus2", "ab")
     verifyMethodReturns("plus3", "abc")
     verifyMethodReturns("trim",  "abc")
  }

//////////////////////////////////////////////////////////////////////////
// Duration
//////////////////////////////////////////////////////////////////////////

  Void testDuration()
  {
    compile(
     "class Foo
      {
        static Duration plus() { return 1sec + 0.5sec }
        static Int ticks()     { return 1sec.toNanos }
        static Str toString()  { return 5ms.toStr }
      }")
     verifyMethodReturns("plus", 1.5sec)
     verifyMethodReturns("ticks", 1_000_000_000)
     verifyMethodReturns("toString", "5ms")
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void verifyMethodReturns(Str methodName, Obj val)
  {
    m := compiler.types.first.methodDef(methodName)
    verifyEq(m.code.stmts.first->expr->val, val)
  }

}