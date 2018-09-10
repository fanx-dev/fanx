//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 May 06  Brian Frank  Creation
//

**
** StmtTest tests various statements like if, else under various scenerios with
** various optimizations
**
class StmtTest : Test
{

//////////////////////////////////////////////////////////////////////////
// If
//////////////////////////////////////////////////////////////////////////

  Void testIf()
  {
    verifyEq(verifyIfEQ(3, 3), "eq")
    verifyEq(verifyIfEQ(3, 4), "ne")

    verifyEq(verifyIfNE(-3, 3), "ne")
    verifyEq(verifyIfNE(0, 0),  "eq")

    verifyEq(verifyIfLT(2, 3), "<")
    verifyEq(verifyIfLT(2, 2), "!<")

    verifyEq(verifyIfLE(2, 3), "<=")
    verifyEq(verifyIfLE(2, 2), "<=")
    verifyEq(verifyIfLE(9, 2), "!<=")

    verifyEq(verifyIfGT(3, 1), ">")
    verifyEq(verifyIfGT(2, 2), "!>")

    verifyEq(verifyIfGE(5, 3), ">=")
    verifyEq(verifyIfGE(5, 5), ">=")
    verifyEq(verifyIfGE(2, 7), "!>=")

    verifyEq(verifyIfSame(5ms, 5ms), "===")
    verifyEq(verifyIfSame(5ms, 3ms), "!==")

    verifyEq(verifyIfNotSame(5ms, 5ms), "===")
    verifyEq(verifyIfNotSame(5ms, 3ms), "!==")

    verifyEq(verifyIfNullA(5),    "false")
    verifyEq(verifyIfNullA(null), "true")
    verifyEq(verifyIfNullB(5),    "false")
    verifyEq(verifyIfNullB(null), "true")
    verifyEq(verifyIfNullC(5),    "false")
    verifyEq(verifyIfNullC(null), "true")
    verifyEq(verifyIfNullD(5),    "false")
    verifyEq(verifyIfNullD(null), "true")

    verifyEq(verifyIfNotNullA(5),     "true")
    verifyEq(verifyIfNotNullA(null),  "false")
    verifyEq(verifyIfNotNullB(5),    "true")
    verifyEq(verifyIfNotNullB(null), "false")
    verifyEq(verifyIfNotNullC(5),     "true")
    verifyEq(verifyIfNotNullC(null),  "false")
    verifyEq(verifyIfNotNullD(5),    "true")
    verifyEq(verifyIfNotNullD(null), "false")
  }

  Str verifyIfEQ(Int a, Int b) { if (a == b) return "eq"; return "ne"; }
  Str verifyIfNE(Int a, Int b) { if (a != b) return "ne"; return "eq"; }
  Str verifyIfLT(Int a, Int b) { if (a < b)  return "<"; return "!<"; }
  Str verifyIfLE(Int a, Int b) { if (a <= b) return "<="; return "!<="; }
  Str verifyIfGT(Int a, Int b) { if (a > b)  return ">"; return "!>"; }
  Str verifyIfGE(Int a, Int b) { if (a >= b) return ">="; return "!>="; }
  Str verifyIfSame(Duration a, Duration b)    { if (a == b) return "==="; return "!=="; }
  Str verifyIfNotSame(Duration a, Duration b) { if (a != b) return "!=="; return "==="; }
  Str verifyIfNullA(Obj? a)     { if (a == null) return "true"; return "false" }
  Str verifyIfNullB(Obj? a)     { if (null == a) return "true"; return "false" }
  Str verifyIfNullC(Obj? a)     { if (a === null) return "true"; return "false" }
  Str verifyIfNullD(Obj? a)     { if (null === a) return "true"; return "false" }
  Str verifyIfNotNullA(Obj? a)  { if (a != null) return "true"; return "false" }
  Str verifyIfNotNullB(Obj? a)  { if (null != a) return "true"; return "false" }
  Str verifyIfNotNullC(Obj? a)  { if (a !== null) return "true"; return "false" }
  Str verifyIfNotNullD(Obj? a)  { if (null !== a) return "true"; return "false" }

//////////////////////////////////////////////////////////////////////////
// If -> Bool
//////////////////////////////////////////////////////////////////////////

  Void testIfBool()
  {
    verifyEq(verifyIfEQBool(3, 3), true)
    verifyEq(verifyIfEQBool(3, 4), false)

    verifyEq(verifyIfNEBool(-3, 3), true)
    verifyEq(verifyIfNEBool(0, 0),  false)

    verifyEq(verifyIfLTBool(2, 3), true)
    verifyEq(verifyIfLTBool(2, 2), false)

    verifyEq(verifyIfLEBool(2, 3), true)
    verifyEq(verifyIfLEBool(2, 2), true)
    verifyEq(verifyIfLEBool(9, 2), false)

    verifyEq(verifyIfGTBool(3, 1), true)
    verifyEq(verifyIfGTBool(2, 2), false)

    verifyEq(verifyIfGEBool(5, 3), true)
    verifyEq(verifyIfGEBool(5, 5), true)
    verifyEq(verifyIfGEBool(2, 7), false)

    verifyEq(verifyIfSameBool(2ms, 2ms), true)
    verifyEq(verifyIfSameBool(2ms, 6ms), false)

    verifyEq(verifyIfNotSameBool(2ms, 0ms), true)
    verifyEq(verifyIfNotSameBool(6ms, 6ms), false)

    verifyEq(verifyIfNullBoolA(null), true)
    verifyEq(verifyIfNullBoolA(2),    false)
    verifyEq(verifyIfNullBoolB(null), true)
    verifyEq(verifyIfNullBoolB(2),    false)
    verifyEq(verifyIfNullBoolC(null), true)
    verifyEq(verifyIfNullBoolC(2),    false)
    verifyEq(verifyIfNullBoolD(null), true)
    verifyEq(verifyIfNullBoolD(2),    false)

    verifyEq(verifyIfNotNullBoolA(null), false)
    verifyEq(verifyIfNotNullBoolA(2),    true)
    verifyEq(verifyIfNotNullBoolB(null), false)
    verifyEq(verifyIfNotNullBoolB(2),    true)
    verifyEq(verifyIfNotNullBoolC(null), false)
    verifyEq(verifyIfNotNullBoolC(2),    true)
    verifyEq(verifyIfNotNullBoolD(null), false)
    verifyEq(verifyIfNotNullBoolD(2),    true)
  }

  Bool verifyIfEQBool(Int a, Int b) { return (a == b) }
  Bool verifyIfNEBool(Int a, Int b) { return (a != b) }
  Bool verifyIfLTBool(Int a, Int b) { return (a < b)  }
  Bool verifyIfLEBool(Int a, Int b) { return (a <= b) }
  Bool verifyIfGTBool(Int a, Int b) { return (a > b)  }
  Bool verifyIfGEBool(Int a, Int b) { return (a >= b) }
  Bool verifyIfSameBool(Duration a, Duration b)    { return (a == b) }
  Bool verifyIfNotSameBool(Duration a, Duration b) { return (a != b) }
  Bool verifyIfNullBoolA(Obj? a)    { return (a == null) }
  Bool verifyIfNullBoolB(Obj? a)    { return (null == a) }
  Bool verifyIfNullBoolC(Obj? a)    { return (a === null) }
  Bool verifyIfNullBoolD(Obj? a)    { return (null === a) }
  Bool verifyIfNotNullBoolA(Obj? a)  { return (a != null) }
  Bool verifyIfNotNullBoolB(Obj? a)  { return (null != a) }
  Bool verifyIfNotNullBoolC(Obj? a)  { return (a !== null) }
  Bool verifyIfNotNullBoolD(Obj? a)  { return (null !== a) }

//////////////////////////////////////////////////////////////////////////
// While
//////////////////////////////////////////////////////////////////////////

  Void testWhile()
  {
    x := ""
    while (x.size < 3) x += "x"
    verifyEq(x, "xxx")

    counter := 0
    while (++counter<7) {}
    verifyEq(counter, 7)
  }

//////////////////////////////////////////////////////////////////////////
// For
//////////////////////////////////////////////////////////////////////////

  Void testFor()
  {
    x := ""
    for (i := 0; i<5; ++i) x += i.toStr
    verifyEq(x, "01234")

    x = ""
    for (i := 0; i<=5; ++i) x += i.toStr
    verifyEq(x, "012345")

    x = ""
    for (i := 0; i<=5; ++i) { x += i.toStr; if (i==3) break; x += "." }
    verifyEq(x, "0.1.2.3")

    x = ""
    for (i := 0; i<5; ++i) { x += i.toStr; if (i==3) continue; x += "." }
    verifyEq(x, "0.1.2.34.")

    x = ""
    for (i := 0; i<3; ++i)
    {
      x += "{"
      for (j := 0; j<3; ++j) x += j.toStr
      x += "}"
    }
    verifyEq(x, "{012}{012}{012}")

    x = ""
    for (i := 0; i<3; ++i)
    {
      x += "{"
      for (j := 0; j<3; ++j) { x += j.toStr; if (i==1) continue; x += "." }
      x += "}"
    }
    verifyEq(x, "{0.1.2.}{012}{0.1.2.}")

    x = ""
    for (i := 0; i<3; ++i)
    {
      x += "{"
      for (j := 0; j<3; ++j) { x += j.toStr; if (i==1) continue; if (i == 2) break; x += "." }
      x += "}"
    }
    verifyEq(x, "{0.1.2.}{012}{0}")

    counter := 0
    for (; counter<4; ++counter) {}
    verifyEq(counter, 4)
  }

//////////////////////////////////////////////////////////////////////////
// For No Condition Expr
//////////////////////////////////////////////////////////////////////////

  Void testForNoCond()
  {
    x := ""
    for (i := 0; ; ++i) { if (i==5) break; x += i.toStr }
    verifyEq(x, "01234")

    x = ""
    for (i := 0; ; ++i) { if (i==5) break; x += i.toStr; if (i==3) continue; x += "." }
    verifyEq(x, "0.1.2.34.")
  }

//////////////////////////////////////////////////////////////////////////
// For No Update Expr
//////////////////////////////////////////////////////////////////////////

  Void testForNoUpdate()
  {
    x := ""
    for (i := 0; i<5; ) { x += i.toStr; ++i }
    verifyEq(x, "01234")

    x = ""
    for (i := 0; i<=5; ) { x += i.toStr; ++i }
    verifyEq(x, "012345")

    x = ""
    for (i := 0; i<=5; ) { x += i.toStr; if (i==3) break; x += "."; ++i; }
    verifyEq(x, "0.1.2.3")

    x = ""
    for (i := 0; i<5; ) { x += i.toStr; if (i==3) {i++; continue} x += "."; ++i; }
    verifyEq(x, "0.1.2.34.")
  }

//////////////////////////////////////////////////////////////////////////
// Try/Catch/Finally
//////////////////////////////////////////////////////////////////////////

  Void testTry()
  {
    verifyEq(verifyTry1("abc"), 3)
    verifyEq(verifyTry1(null), -1)
    verifyEq(verifyTry2("abc"), 3)
    verifyEq(verifyTry2(null), -1)
    verifyEq(verifyTry3("ab"), 2)
    verifyEq(verifyTry3(null), -1)
    verifyEq(verifyTry3(5),    -2)
    verifyEq(verifyTry4("xyz"), "try 3 finally")
    verifyEq(verifyTry4(null),  "try catch (NullErr) finally")
    verifyEq(verifyTry4(6),     "try catch-all finally")
  }

  Int verifyTry1(Str? x)
  {
    try { return x.size } catch (NullErr e) { return -1 }
  }

  Int verifyTry2(Str? x)
  {
    try
      return x.size
    catch (NullErr e)
      return -1
  }

  Int verifyTry3(Obj? x)
  {
    try return ((Str)x).size
    catch (NullErr e) { return -1 }
    catch (CastErr e) return -2
  }

  Str verifyTry4(Obj? x)
  {
    s := ""
    try
    {
      s += "try "
      s += ((Str)x).size.toStr
    }
    catch (NullErr e)
      s += "catch (NullErr)"
    catch
      s += "catch-all"
    finally
      s += " finally"
    return s
  }
}