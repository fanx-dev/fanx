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
  private Int failVerifyCount := 0
  private Int verifyCount := 0

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
  Method? curTestMethod { private set }

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

  static Void main(Str[] arg) {
    podName := arg[0]
    typeName := arg[1]
    pod := Pod.find(podName)
    type := pod.type(typeName)

    methodCount := 0
    failMethodCount := 0
    obj := type.make()

    TypeExt.methods(type).each |Method m| {
      if (m.name.startsWith("test")) {
        try {
          runTest(obj, m)
        } catch (Err err) {
          ++failMethodCount
          err.trace
        }
        ++methodCount
      }
    }
    if (failMethodCount == 0) {
      echo("SUCCESS, $methodCount methods")
    } else {
      echo("$failMethodCount FAILURES, $methodCount methods")
    }
  }

  private static Void runTest(Obj obj, Method meth) {
    //obj.curTestMethod = meth
    obj->setup
    meth.callOn(obj, null)
    obj->teardown
  }

}

**************************************************************************
** TestErr
**************************************************************************

internal const class TestErr : Err
{
  new make(Str? msg := null, Err? cause := null) : super(msg, cause) {}
}