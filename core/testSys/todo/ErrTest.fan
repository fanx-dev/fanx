//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 May 06  Brian Frank  Creation
//

**
** ErrTest
**
class ErrTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Trace
//////////////////////////////////////////////////////////////////////////

  Void a(Func f) { b(f) }
  Void b(Func f) { c(f) }
  Void c(Func f) { f() }

  Void testTrace()
  {
    Int line := #testTrace->lineNumber; line += 3 // next line
    verifyTrace(line++) |->| { throw Err.make("foo") }
    verifyTrace(line++) |->| { Obj x := 3; ((Str)x).size }
    verifyTrace(line++) |->| { Pod? x := null; x.name }
    verifyTrace(line++) |->| { try { throw Err.make("cause") } catch (Err e) { throw Err.make("foo", e) } }
  }

  Void verifyTrace(Int line, Func f)
  {
    Err? err
    try { a(f) } catch (Err e) { err = e }

    buf := Buf.make
    err.trace(buf.out)
    lines := buf.flip.readAllLines

    verifyEq(err.traceToStr, buf.seek(0).readAllStr)

    verifyEq(lines[0], err.toStr)
    verifyEq(lines[1], "  testSys::ErrTest.testTrace (ErrTest.fan:$line)")
    verifyEq(lines[2], "  testSys::ErrTest.c (ErrTest.fan:21)")
    verifyEq(lines[3], "  testSys::ErrTest.b (ErrTest.fan:20)")
    verifyEq(lines[4], "  testSys::ErrTest.a (ErrTest.fan:19)")

    if (err.cause != null)
    {
      causeStart := lines.index("Cause:")
      verifyEq(lines[causeStart+1], "  " + err.cause.toStr)
      verifyEq(lines[causeStart+2], "    testSys::ErrTest.testTrace (ErrTest.fan:$line)")
    }
  }

  Void testTraceMaxDepth()
  {
    Err? err
    try { doThrow(30) } catch (Err e) { err = e }

    // default is 25
    buf := Buf()
    err.trace(buf.out)
    lines := buf.flip.readAllLines
    verifyEq(lines.size, 25+2) // toStr + More...
    verify(lines.last.contains("More"))

    // with maxDepth
    err.trace(buf.clear.out, ["maxDepth":4])
    lines = buf.flip.readAllLines
    verifyEq(lines.size, 4+2)
    verify(lines.last.contains("More"))

    // with maxDepth
    err.trace(buf.clear.out, ["maxDepth":Int.maxVal])
    lines = buf.flip.readAllLines
    verify(lines.size > 30)
  }

  Void doThrow(Int depth)
  {
    if (depth == 0) throw Err()
    doThrow(depth-1)
  }

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  Void testType()
  {
    err := Err()
    verifySame(err.typeof, Err#)
    verifySame(err.typeof.base, Obj#)
    verifyEq(err.typeof.qname, "sys::Err")
    verify(err is Err)
    verify(err is Obj)

    err = CastErr("foo")
    verifySame(err.typeof, CastErr#)
    verifySame(err.typeof.base, Err#)
    verifySame(err.typeof.base.base, Obj#)
    verifyEq(err.typeof.qname, "sys::CastErr")

    verifyErr(CastErr#) { throw CastErr() }
    verifyErr(null) { throw CastErr() }
  }

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

  Void testObj()
  {
    a := CastErr("a")
    b := CastErr("b")
    c := TestIOErr("c")

    // sys::CastErr
    verifyEq(a.isImmutable, true)
    verifyEq(a.toStr, "sys::CastErr: a")
    verifyEq(a.typeof, CastErr#)
    verifySame(a.toImmutable, a)

    // sys::TestIOErr
    verifyEq(c.isImmutable, true)
    verifyEq(c.toStr, "testSys::TestIOErr: c")
    verifyEq(c.typeof, TestIOErr#)
    verifySame(c.toImmutable, c)

    verifyEq(a, a)
    verifyNotEq(a, b)
    verifyNotEq(a.hash, c.hash)

    verifyEq(a.compare(b), -1)
    verifyEq(a.compare(a), 0)
    verifyEq(b.compare(a), 1)
    verifyEq(a < b, true)
    verifyEq(a >= b, false)
    verifyEq(a == b, false)

    verifyEq(a->toStr, "sys::CastErr: a")
    verifyEq(c->toStr, "testSys::TestIOErr: c")
    verifyEq(a->msg, "a")
    verifyEq(a->cause, null)
    verifyEq(a->typeof, CastErr#)
    verifySame(a->toImmutable, a)
    verifyErr(UnknownSlotErr#) { a->fooBar }

    withObj := null
    a.with |x| { withObj = a }
    verifySame(a, withObj)
  }

//////////////////////////////////////////////////////////////////////////
// Consturctors
//////////////////////////////////////////////////////////////////////////

  Void testCtor()
  {
    cause := Err()

    err := Err()
    verifyEq(err.msg, "")
    verifyEq(err.cause, null)
    verifyEq(err.toStr, "sys::Err")

    err = Err.make("foo")
    verifyEq(err.msg, "foo")
    verifyEq(err.cause, null)
    verifyEq(err.toStr, "sys::Err: foo")

    err = IOErr("foo", cause)
    verifyEq(err.msg, "foo")
    verifySame(err.cause, cause)
    verifyEq(err.toStr, "sys::IOErr: foo")

    err = TestCtorErr()
    verifyEq(err.msg, "")
    verifyEq(err.cause, null)
  }

//////////////////////////////////////////////////////////////////////////
// All Sys Errs
//////////////////////////////////////////////////////////////////////////

  Void testAllSysErrs()
  {
    cause := Err("cause")
    Err? err

    // ArgErr
    err = verifyErrType(ArgErr("msg", cause), ArgErr#, "sys::ArgErr")
    verify(err is ArgErr)
    verifyEq(ArgErr().msg, "")

    // CastErr
    err = verifyErrType(CastErr("msg", cause), CastErr#, "sys::CastErr")
    verify(err is CastErr)
    verifyEq(CastErr().msg, "")

    // CancelledErr
    err = verifyErrType(CancelledErr("msg", cause), CancelledErr#, "sys::CancelledErr")
    verify(err is CancelledErr)
    verifyEq(CancelledErr().msg, "")

    // ConstErr
    err = verifyErrType(ConstErr("msg", cause), ConstErr#, "sys::ConstErr")
    verify(err is ConstErr)
    verifyEq(ConstErr().msg, "")

    // IndexErr
    err = verifyErrType(IndexErr("msg", cause), IndexErr#, "sys::IndexErr")
    verify(err is IndexErr)
    verifyEq(IndexErr().msg, "")

    // InterruptedErr
    err = verifyErrType(InterruptedErr("msg", cause), InterruptedErr#, "sys::InterruptedErr")
    verify(err is InterruptedErr)
    verifyEq(InterruptedErr().msg, "")

    // IOErr
    err = verifyErrType(IOErr("msg", cause), IOErr#, "sys::IOErr")
    verify(err is IOErr)
    verifyEq(IOErr().msg, "")

    // NotImmutableErr
    err = verifyErrType(NotImmutableErr("msg", cause), NotImmutableErr#, "sys::NotImmutableErr")
    verify(err is NotImmutableErr)
    verifyEq(NotImmutableErr().msg, "")

    // NameErr
    err = verifyErrType(NameErr("msg", cause), NameErr#, "sys::NameErr")
    verify(err is NameErr)
    verifyEq(NameErr().msg, "")

    // NullErr
    err = verifyErrType(NullErr("msg", cause), NullErr#, "sys::NullErr")
    verify(err is NullErr)
    verifyEq(NullErr().msg, "")

    // ParseErr
    err = verifyErrType(ParseErr("msg", cause), ParseErr#, "sys::ParseErr")
    verify(err is ParseErr)
    verifyEq(ParseErr().msg, "")

    // ReadonlyErr
    err = verifyErrType(ReadonlyErr("msg", cause), ReadonlyErr#, "sys::ReadonlyErr")
    verify(err is ReadonlyErr)
    verifyEq(ReadonlyErr().msg, "")

    // TimeoutErr
    err = verifyErrType(TimeoutErr("msg", cause), TimeoutErr#, "sys::TimeoutErr")
    verify(err is TimeoutErr)
    verifyEq(TimeoutErr().msg, "")

    // UnknownPodErr
    err = verifyErrType(UnknownPodErr("msg", cause), UnknownPodErr#, "sys::UnknownPodErr")
    verify(err is UnknownPodErr)
    verifyEq(UnknownPodErr().msg, "")

    // UnknownSlotErr
    err = verifyErrType(UnknownSlotErr("msg", cause), UnknownSlotErr#, "sys::UnknownSlotErr")
    verify(err is UnknownSlotErr)
    verifyEq(UnknownSlotErr().msg, "")

    // UnknownTypeErr
    err = verifyErrType(UnknownTypeErr("msg", cause), UnknownTypeErr#, "sys::UnknownTypeErr")
    verify(err is UnknownTypeErr)
    verifyEq(UnknownTypeErr().msg, "")

    // UnsupportedErr
    err = verifyErrType(UnsupportedErr("msg", cause), UnsupportedErr#, "sys::UnsupportedErr")
    verify(err is UnsupportedErr)
    verifyEq(UnsupportedErr().msg, "")
  }

  Err verifyErrType(Err err, Type t, Str qname)
  {
    verifySame(Type.of(err), t)
    verifyEq(Type.of(err).qname, qname)
    verifyEq(Type.of(err).base, Err#)
    verifyEq(Type.of(err).base.base, Obj#)
    verify(err is Err)
    verify(err is Obj)
    verifySame(err.msg, "msg")
    verifySame(err.cause.msg, "cause")
    return err
  }

//////////////////////////////////////////////////////////////////////////
// Subclassing
//////////////////////////////////////////////////////////////////////////

  Void testSubclassing()
  {
    cause := Err("cause")

    // create TestOneErr with both params
    err := TestOneErr("msg", cause)
    verifyErrType(err,TestOneErr#, "testSys::TestOneErr")
    verify(err is TestOneErr)
    verifyEq(err.r, -3f)

    // verify TestOneErr with 2 default params
    err = TestOneErr()
    verifySame(Type.of(err), TestOneErr#)
    verifyEq(err.msg, "")
    verify(err.cause === null)

    // verify TestOneErr with 1 default params
    err = TestOneErr.make("foobar")
    verifySame(Type.of(err), TestOneErr#)
    verify(err.msg === "foobar")
    verify(err.cause === null)

    // verify TestTwoErr which subclasses from TestOneErr
    err2 := TestTwoErr.make()
    verifySame(Type.of(err2), TestTwoErr#)
    verifySame(Type.of(err2).base, TestOneErr#)
    verifySame(Type.of(err2).base.base, Err#)
    verifyEq(Type.of(err2).qname, "testSys::TestTwoErr")
    verify(err2 is TestTwoErr)
    verify(err2 is TestOneErr)
    verify(err is Err)
    verify(err is Obj)
    verifyEq(err2.r, -3f)
    verifyEq(err2.i, 77)
    verifyEq(err2.s, "hello world")

    // verify TestIOErr which subclasses from IOErr
    errIO := TestIOErr.make()
    verifySame(Type.of(errIO), TestIOErr#)
    verifySame(Type.of(errIO).base, IOErr#)
    verifySame(Type.of(errIO).base.base, Err#)
    verifyEq(Type.of(errIO).qname, "testSys::TestIOErr")
    verify(errIO is TestIOErr)
    verify(errIO is IOErr)
    verify(errIO is Err)
    verify(errIO is Obj)
    verifyEq(errIO.s, "memorial day")

    // verify throws works correctly
    verifyErr(TestOneErr#) { throw TestOneErr.make }
    verifyErr(TestTwoErr#) { throw TestTwoErr.make }
    verifyErr(TestIOErr#)  { throw TestIOErr.make }
    verifyErr(TestIOErr#)  { throw TestIOErr.make }
  }

}

//////////////////////////////////////////////////////////////////////////
// Supplemental classes
//////////////////////////////////////////////////////////////////////////

const class TestOneErr : Err
{
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
  const Float r := -3f
}

const class TestTwoErr : TestOneErr
{
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {}

  const Int i := 77
  const Str s := "hello world"
}

const class TestIOErr : IOErr
{
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {}

  const Str s := "memorial day"
}

const class TestCtorErr : Err { new make() : super.make() {} }