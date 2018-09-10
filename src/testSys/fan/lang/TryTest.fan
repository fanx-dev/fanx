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
class TryTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Catch All
//////////////////////////////////////////////////////////////////////////

  Void testCatchAll()
  {
    s := "start"
    try
    {
      s += " before "
      throw Err.make
      s += " wrong "
    }
    catch
    {
      s += "caught"
    }
    verifyEq(s, "start before caught");
  }

//////////////////////////////////////////////////////////////////////////
// Catch Same Type
//////////////////////////////////////////////////////////////////////////

  Void testCatchSameType()
  {
    s := "start"
    try
    {
      s += " before "
      throw IndexErr.make
      s += " wrong "
    }
    catch (IndexErr err)
    {
      s += "caught(${Type.of(err).name})"
    }
    verifyEq(s, "start before caught(IndexErr)");
  }

//////////////////////////////////////////////////////////////////////////
// Catch Super Type
//////////////////////////////////////////////////////////////////////////

  Void testCatchSuperType()
  {
    s := "start"
    try
    {
      s += " before "
      throw CatchTestIOErr.make("foo")
      s += " wrong "
    }
    catch (IOErr err)
    {
      s += "caught(${Type.of(err).name})"
    }
    verifyEq(s, "start before caught(CatchTestIOErr)");
  }

//////////////////////////////////////////////////////////////////////////
// Catch Wrong Type
//////////////////////////////////////////////////////////////////////////

  Void testCatchWrongType()
  {
    verifyErr(IndexErr#) |->|
    {
      try
      {
        throw IndexErr.make("foo")
      }
      catch (IOErr err)
      {
        fail()
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Catch Multiple
//////////////////////////////////////////////////////////////////////////

  Void testCatchMultiple()
  {
    verifyEq(catchMultiple(IOErr.make), IOErr#)
    verifyEq(catchMultiple(IndexErr.make), IndexErr#)
    verifyEq(catchMultiple(ArgErr.make), ArgErr#)
    verifyErr(ReadonlyErr#) { catchMultiple(ReadonlyErr.make) }
  }

  Type catchMultiple(Err err)
  {
    try
    {
      throw err
    }
    catch (IOErr e)
    {
      return IOErr#
    }
    catch (IndexErr e)
    {
      return IndexErr#
    }
    catch (ArgErr e)
    {
      return ArgErr#
    }
  }

//////////////////////////////////////////////////////////////////////////
// Catch Nested
//////////////////////////////////////////////////////////////////////////

  Void testNested()
  {
    s := "";
    try
    {
      s += "a";
      try
      {
        s += " b";
        throw IndexErr.make
        s += " c";
      }
      catch (IndexErr e)
      {
        s += " IndexErr";
      }
      s += " d"
    }
    catch (NullErr e)
    {
      s += " NullErr";
    }

    verifyEq(s, "a b IndexErr d");

    s = "";
    try
    {
      s += "a";
      try
      {
        s += " b";
        throw NullErr.make
        s += " c";
      }
      catch (IndexErr e)
      {
        s += " IndexErr";
      }
      s += " d"
    }
    catch (NullErr e)
    {
      s += " NullErr";
    }

    verifyEq(s, "a b NullErr");
    s = "";
    try
    {
      s += "a";
      try
      {
        s += " b";
        throw NullErr.make
        s += " c";
      }
      catch (NullErr e)
      {
        s += " NullErrA";
      }
      s += " d"
    }
    catch (NullErr e)
    {
      s += " NullErrB";
    }
    verifyEq(s, "a b NullErrA d");
  }

//////////////////////////////////////////////////////////////////////////
// Runtime Mapping Test
//////////////////////////////////////////////////////////////////////////

  **
  ** The goal here is to cause exceptions which are raised by the
  ** runtime rather than our system code - we want to ensure that
  ** they are mapped to their Fantom counterparts correctly.  We try
  ** one in three scenerios: Test.verifyErr, catch, and reflection
  **
  Void testRuntimeMapping()
  {
    try { throwCastErr } catch (CastErr e) { } catch { fail }
    verifyErr(CastErr#) { throwCastErr }
    verifyErr(CastErr#) { TryTest#throwCastErr.call }

    try { throwNullErr } catch (NullErr e) { } catch { fail }
    verifyErr(NullErr#) { throwNullErr }
    verifyErr(NullErr#) { TryTest#throwNullErr.call }

    try { throwIndexErr } catch (IndexErr e) { } catch { fail }
    verifyErr(IndexErr#) { throwIndexErr }
    verifyErr(IndexErr#) { TryTest#throwIndexErr.call }

    try { throwIOErr } catch (IOErr e) { } catch { fail }
    verifyErr(IOErr#) { throwIOErr }
    verifyErr(IOErr#) { TryTest#throwIOErr.call }

    try { throwInterruptedErr } catch (InterruptedErr e) { } catch { fail }
    verifyErr(InterruptedErr#) { throwInterruptedErr }
    verifyErr(InterruptedErr#) { TryTest#throwInterruptedErr.call }
  }

  static Str throwCastErr() { Obj four := 4; return (Str)four }
  static Void throwNullErr() { Str? a := null; a.size }
  static Void throwIndexErr() { x := "foo"[100] }
  static Void throwIOErr() { throw IOErr.make /* not really a good test */ }
  static Void throwInterruptedErr() { throw InterruptedErr.make /* not really a good test */ }
}

//////////////////////////////////////////////////////////////////////////
// CatchTestIOErr
//////////////////////////////////////////////////////////////////////////

const class CatchTestIOErr : IOErr
{
  new make(Str msg, Err? cause := null) : super(msg, cause) {}
}