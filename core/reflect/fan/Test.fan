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

  **
  ** Verify that cond is true, otherwise throw a test
  ** failure exception.  If msg is non-null, include it
  ** in a failure exception.
  **
  Void verify(Bool cond, Str? msg := null) {
    ++verifyCount;
    if (!cond) {
      ++failVerifyCount
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
    verify(a == null, msg)
  }

  **
  ** Verify that a is not null, otherwise throw a test failure
  ** exception.  If msg is non-null, include it in a failure
  ** exception.
  **
  Void verifyNotNull(Obj? a, Str? msg := null) {
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
    verify(a == b, msg)
  }

  **
  ** Verify that a != b, otherwise throw a test failure exception.
  ** If msg is non-null, include it in failure exception.
  **
  Void verifyNotEq(Obj? a, Obj? b, Str? msg := null) {
    verify(a != b, msg)
  }

  **
  ** Verify that a === b, otherwise throw a test failure exception.
  ** If msg is non-null, include it in failure exception.
  **
  Void verifySame(Obj? a, Obj? b, Str? msg := null) {
    verify(a === b, msg)
  }

  **
  ** Verify that a !== b, otherwise throw a test* failure exception.
  ** If msg is non-null, include it in failure exception.
  **
  Void verifyNotSame(Obj? a, Obj? b, Str? msg := null) {
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
  ** Verify that the function throws an Err of the
  ** exact same type as err (compare using === operator).
  **
  ** Examples:
  **   verifyErr(ParseErr#) { x := Int.fromStr("@#!") }
  **
  Void verifyErr(Type errType, |Test| c) {
    try {
      c(this)
      verify(false, "no err")
    } catch (Err err) {
      verifyType(err, errType)
    }
  }

  @NoDoc
  Void verifyErrMsg(Type errType, Str errMsg, |Test| c) {
    try {
      c(this)
      verify(false, "no err")
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
    throw TestErr(msg)
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

  private Int failures := 0
  private Int verifyCount := 0

  new make(Str arg) {
    pos := arg.find("::")
    if (pos != -1) {
      podName := arg[0..<pos]
      typeName := arg[pos+2..-1]
      pod = Pod.find(podName)
      type := pod.type(typeName)
      types = [type]
    } else {
      podName := arg
      pod = Pod.find(podName)
      types = pod.types
    }
  }

  Int run() {
    types.each |type| {
      TypeExt.methods(type).each |Method m| {
        if (m.name.startsWith("test")) {
          runTest(type, m)
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
      //echo("call $meth")
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