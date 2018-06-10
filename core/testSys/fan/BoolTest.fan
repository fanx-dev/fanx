//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Jan 06  Brian Frank  Creation
//

**
** BoolTest
**
@Js
class BoolTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testIdentity()
  {
    Obj x := true
    Bool? t := true
    Bool? f := false
    verify(x.isImmutable)
    verify(Type.of(x) === Bool#)
    verify(t.isImmutable)
    verify(true.isImmutable)
    verify(true == true)
    verify(false == false)
    verify(true != false)
    verify(false != x)
    verify(t == true)
    verify(true == t)
    verifyFalse(t == false)
    verifyFalse(false == t)
    verify(t == t)
    verifyFalse(t == f)
    verify(x != "wow")
    verify(t != null)
    verify((Obj?)"wow" != t)
    verifyFalse(t == (Obj?)"wow")
    verify(null != f)
    verify(t.equals(t))
    verify(t.equals(true))
    verifyFalse(false.equals(t))
    verify(t.hash == t.hash)
    verify(f.hash == f.hash)
    verify(t.hash != f.hash)
  }

//////////////////////////////////////////////////////////////////////////
// Def Val
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifyEq(Bool.defVal, false)
    verifyEq(Bool#.make, false)
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  Void testCompare()
  {
    Bool? t := true
    Bool? f := false

    verify(null  <  false)
    verify(null  <  true)
    verify(false <  true)
    verify(f     <  true)
    verify(false <  t)

    verifyFalse(null  >  false)
    verifyFalse(null  >  true)
    verifyFalse(false >  false)
    verifyFalse(f     >  false)
    verifyFalse(false >  f)

    verify(null  <= false)
    verify(null  <= true)
    verify(false <= true)
    verify(false <= false)
    verify(true  <= true)
    verify(t     <= true)
    verify(true  <= t)

    verifyFalse(null  >= false)
    verifyFalse(null  >= true)
    verifyFalse(false >= true)
    verifyFalse(f     >= true)
    verifyFalse(false >= t)

    verify(true  >  false)
    verify(false >  null)
    verify(true  >  null)
    verify(true  >  f)
    verify(t     >  false)
    verifyFalse(true  <  false)
    verifyFalse(false <  null)
    verifyFalse(true  <  null)
    verifyFalse(true  <  f)
    verifyFalse(t     <  false)

    verify(false >= false)
    verify(true  >= true)
    verify(true  >= false)
    verify(false >= null)
    verify(true  >= null)
    verify(t     >= true)
    verify(true  >= f)
    verifyFalse(true  <= false)
    verifyFalse(false <= null)
    verifyFalse(true  <= null)
    verifyFalse(t     <= false)
    verifyFalse(true  <= f)

    verifyEq(true <=> false, 1)
    verifyEq(true <=> true, 0)
    verifyEq(true <=> f, 1)
    verifyEq(t    <=> true, 0)
    verifyEq(f    <=> t, -1)
    verifyEq(null <=> false, -1)
    verifyEq(true.compare(false), 1)
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    t := true
    f := false
    Bool? nt := true
    Bool? nf := false
    Str? s := null

    // not
    verify(!f)
    verifyFalse(!t)

    // logical and
    verifyEq(f && f, false)
    verifyEq(f && t, false)
    verifyEq(t && f, false)
    verifyEq(t && t, true)
    verifyEq(nf && f, false)
    verifyEq(f && nt, false)
    verifyEq(nt && nf, false)
    verifyEq(nt && t, true)

    // logical and - short circuit
    verifyEq(s != null && s.size == 0, false)
    verifyErr(NullErr#) { x := s == null && s.size == 0 }

    // logical or
    verifyEq(f || f, false)
    verifyEq(f || t, true)
    verifyEq(t || f, true)
    verifyEq(t || t, true)
    verifyEq(nf || f, false)
    verifyEq(f || nt, true)
    verifyEq(t || nf, true)
    verifyEq(nt || nt, true)

    // logical or - short circuit
    verifyEq(s == null || s.size == 0, true)
    verifyErr(NullErr#) { x := s != null || s.size == 0 }

    // bitwise and
/* TODO: keep bitwise methods?
    verifyEq(f & f, false)
    verifyEq(f & t, false)
    verifyEq(t & f, false)
    verifyEq(t & t, true)
    verifyEq(nf & nf, false)
    verifyEq(f & nt, false)
    verifyEq(nt & f, false)
    verifyEq(nt & nt, true)

    // bitwise and - no short circuit
    verifyErr(NullErr#) { x := (s != null) & (s.size == 0) }
    verifyErr(NullErr#) { x := (s == null) & (s.size == 0) }

    // bitwise or
    verifyEq(f | f, false)
    verifyEq(f | t, true)
    verifyEq(t | f, true)
    verifyEq(t | t, true)
    verifyEq(nf | nf, false)
    verifyEq(nf | nt, true)
    verifyEq(nt | f, true)
    verifyEq(t | nt, true)

    // bitwise or - no short circuit
    verifyErr(NullErr#) { x := (s == null) | (s.size == 0) }
    verifyErr(NullErr#) { x := (s != null) | (s.size == 0) }

    // bitwise xor
    verifyEq(f ^ f, false)
    verifyEq(f ^ t, true)
    verifyEq(t ^ f, true)
    verifyEq(t ^ t, false)
    verifyEq(nf ^ f, false)
    verifyEq(f ^ nt, true)
    verifyEq(nt ^ nf, true)
    verifyEq(nt ^ nt, false)

    // bitwise xor - no short circuit
    verifyErr(NullErr#) { x := (s == null) ^ (s.size == 0) }
    verifyErr(NullErr#) { x := (s != null) ^ (s.size == 0) }

    // bitwise and assignment
    Bool x := false
    Bool? y := false
    Bool[] q := [true]
    Bool?[] r := [true]
    x = false; x &= false; verifyEq(x, false)
    y = false; y &= true;  verifyEq(y, false)
    f = true;  f &= false; verifyEq(f, false)
    g = true;  g &= true;  verifyEq(g, true)
    q[0] = true; q[0] &= false; verifyEq(q[0], false)
    r[0] = true; r[0] &= true;  verifyEq(r[0], true)

    // bitwise or assignment
    x = false; x |= false; verifyEq(x, false)
    y = false; y |= true;  verifyEq(y, true)
    f = true;  f |= false; verifyEq(f, true)
    g = true;  g |= true;  verifyEq(g, true)
    q[0] = false; q[0] |= false; verifyEq(q[0], false)
    r[0] = false; r[0] |= true;  verifyEq(r[0], true)

    // bitwise xor assignment
    x = false; x ^= false; verifyEq(x, false)
    y = false; y ^= true;  verifyEq(y, true)
    f = true;  f ^= false; verifyEq(f, true)
    g = true;  g ^= true;  verifyEq(g, false)
    q[0] = false; q[0] ^= true;  verifyEq(q[0], true)
    r[0] = true;  r[0] ^= false; verifyEq(r[0], true)
*/
  }

  Bool f := true
  Bool? g := false

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  Void testParse()
  {
    verifyEq(true.toStr, "true")
    verifyEq(false.toStr, "false")
    verifyEq(Bool.fromStr("true"), true)
    verifyEq(Bool.fromStr("false"), false)
    //verifyEq(Bool.fromStr("F", false), null)
    verifyErr(ParseErr#) { x := Bool.fromStr("True") }
    verifyErr(ParseErr#) { x := Bool.fromStr("") }
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq(true.toCode, "true")
    verifyEq(false.toCode, "false")
  }

//////////////////////////////////////////////////////////////////////////
// To Locale
//////////////////////////////////////////////////////////////////////////
/*
  Void testToLocale()
  {
    Locale("en-US").use
    {
      verifyEq(true.toLocale, "True")
      verifyEq(false.toLocale, "False")
    }
  }
*/
}