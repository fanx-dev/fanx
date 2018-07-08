//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

**
** Test is the base for Fantom unit tests.
**
** See `docTools::Fant`.
**
abstract class Test
{
  internal Int failVerifyCount := 0
  internal Int verifyCount := 0

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Protected constructor.
  **
  protected new make() {}

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the current test method being executed or throw Err if
  ** not currently running a test.  This method is available during
  ** both `setup` and `teardown` as well during the test itself.
  **
  Method? curTestMethod { internal set }

  **
  ** Setup is called before running each test method.
  **
  virtual Void setup() {}

  **
  ** Teardown is called after running every test method.
  **
  virtual Void teardown() {}

//////////////////////////////////////////////////////////////////////////
// Verify
//////////////////////////////////////////////////////////////////////////

  private static Str toS(Obj? obj) {
    if (obj == null) return "null"
    return "$obj [${obj.typeof}]"
  }

  **
  ** Verify that cond is true, otherwise throw a test
  ** failure exception.  If msg is non-null, include it
  ** in a failure exception.
  **
  Void verify(Bool cond, Str? msg := null) {
    ++verifyCount;
    if (!cond) {
      fail(msg)
    }
  }

  **
  ** Verify that cond is false, otherwise throw a test
  ** failure exception.  If msg is non-null, include it
  ** in a failure exception.
  **
  Void verifyFalse(Bool cond, Str? msg := null) {
    verify(!cond, msg)
  }

  **
  ** Verify that a is null, otherwise throw a test failure
  ** exception.  If msg is non-null, include it in a failure
  ** exception.
  **
  Void verifyNull(Obj? a, Str? msg := null) {
    if (msg == null) msg = "${toS(a)} is not null"
    verify(a == null, msg)
  }

  **
  ** Verify that a is not null, otherwise throw a test failure
  ** exception.  If msg is non-null, include it in a failure
  ** exception.
  **
  Void verifyNotNull(Obj? a, Str? msg := null) {
    if (msg == null) msg = "${toS(a)} is null"
    verify(a != null, msg)
  }

  **
  ** Verify that a == b, otherwise throw a test failure exception.
  ** If both a and b are nonnull, then this method also ensures
  ** that a.hash == b.hash, because any two objects which return
  ** true for equals() must also return the same hash code.  If
  ** msg is non-null, include it in failure exception.
  **
  Void verifyEq(Obj? a, Obj? b, Str? msg := null) {
    if (msg == null) msg = "${toS(a)} != ${toS(b)}"
    verify(a == b, msg)
  }

  **
  ** Verify that a != b, otherwise throw a test failure exception.
  ** If msg is non-null, include it in failure exception.
  **
  Void verifyNotEq(Obj? a, Obj? b, Str? msg := null) {
    if (msg == null) msg = "${toS(a)} == ${toS(b)}"
    verify(a != b, msg)
  }

  **
  ** Verify that a === b, otherwise throw a test failure exception.
  ** If msg is non-null, include it in failure exception.
  **
  Void verifySame(Obj? a, Obj? b, Str? msg := null) {
    if (msg == null) msg = "${toS(a)} !== ${toS(b)}"
    verify(a === b, msg)
  }

  **
  ** Verify that a !== b, otherwise throw a test* failure exception.
  ** If msg is non-null, include it in failure exception.
  **
  Void verifyNotSame(Obj? a, Obj? b, Str? msg := null) {
    if (msg == null) msg = "${toS(a)} === ${toS(b)}"
    verify(a !== b, msg)
  }

  @NoDoc
  Void verifyTrue(Bool cond, Str? msg := null) { verify(cond, msg) }

  **
  ** Verify that 'Type.of(obj)' equals the given type.
  **
  Void verifyType(Obj obj, Type t) {
    verify(obj.typeof == t, "$obj.typeof == $t")
  }

  **
  ** Verify that 'obj' is instance of the given type.
  **
  Void verifyIsType(Obj obj, Type t) {
    verify(obj.typeof.fits(t), "$obj.typeof not fits $t")
  }

  **
  ** Verify that the function throws an Err of the
  ** exact same type as errType (compare using === operator).
  ** If the errType parameter is null, then this method
  ** tests only that an exception is thrown, not its type.
  **
  ** Example:
  **   verifyErr(ParseErr#) { x := Int.fromStr("@#!") }
  **
  Void verifyErr(Type? errType, |Test| c) {
    try {
      c(this)
      fail("No err thrown, expected $errType")
    } catch (Err err) {
      if (errType != null) {
        if (err.typeof != errType) {
          err.trace
        }
        verifyType(err, errType)
      }
      else {
        verifyNotNull(err)
      }
    }
  }

  @NoDoc
  Void verifyErrMsg(Type errType, Str errMsg, |Test| c) {
    try {
      c(this)
      fail("No err thrown, expected $errType")
    } catch (Err err) {
      verifyType(err, errType)
      verifyEq(errMsg, err.msg)
    }
  }

  **
  ** Throw a test failure exception.  If msg is non-null, include
  ** it in the failure exception.
  **
  Void fail(Str? msg := null) {
    ++failVerifyCount
    if (msg == null) throw TestErr("Test failed")
    throw TestErr("Test failed: $msg")
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Return a temporary test directory which may used as a scratch
  ** directory.  This directory is guaranteed to be created and empty
  ** the first time this method is called for a given test run.  The
  ** test directory is "{Env.cur.tempDir}/test/".
  **
  //File tempDir()

  static Int main(Str[] args) {
    arg := args[0]
    return TestRunner(arg).run
  }

}

**************************************************************************
** TestRuner
**************************************************************************

internal class TestRunner {
  private Pod pod
  private Type[] types
  private Method? method := null

  private Int failures := 0
  private Int verifyCount := 0

  new make(Str arg) {
    pos := arg.find("::")
    if (pos != -1) {
      podName := arg[0..<pos]
      typeName := arg[pos+2..-1]
      Str? methName := null
      dot := typeName.find(".")
      if (dot != -1) {
        methName = typeName[dot+1..-1]
        typeName = typeName[0..<dot]
      }

      pod = Pod.find(podName)
      type := pod.type(typeName)
      types = [type]
      if (methName != null) method = type.method(methName)

    } else {
      podName := arg
      pod = Pod.find(podName)
      types = pod.types
    }
  }

  Int run() {
    if (method != null) {
      runTest(types.first, method)
    }
    else {
      types.each |type| {
        type.methods.each |Method m| {
          if (m.name.startsWith("test")) {
            runTest(type, m)
          }
        }
      }
    }

    if (failures == 0) {
      echo("All tests passed! totalVerifyCount:$verifyCount")
      return 0
    } else {
      echo("$failures FAILURES, totalVerifyCount:$verifyCount")
      return -1
    }
  }

  private Void runTest(Type type, Method meth) {
    Test? obj
    try {
      echo("-- Run:  ${meth}...")
      obj = type.make()
      //echo(obj)
      obj.curTestMethod = meth
      obj.setup
      meth.callOn(obj, null)

      verifyCount += obj.verifyCount
      if (obj.failVerifyCount > 0) {
        ++failures
      }
      else {
        echo("Pass $meth [$obj.failVerifyCount]")
      }

    } catch (Err e) {
      ++failures
      e.trace
    }
    finally {
      obj?.teardown
    }
  }
}

**************************************************************************
** TestErr
**************************************************************************

internal const class TestErr : Err
{
  new make(Str? msg := null, Err? cause := null) : super(msg, cause) {}
}