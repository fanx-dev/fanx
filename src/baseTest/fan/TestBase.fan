

virtual class TestBase {
  private static Str toS(Obj? obj) {
    if (obj == null) return "null"
    return "$obj"
    //return "$obj [${obj.typeof}]"
  }

  **
  ** Verify that cond is true, otherwise throw a test
  ** failure exception.  If msg is non-null, include it
  ** in a failure exception.
  **
  Void verify(Bool cond, Str? msg := null) {
    //++verifyCount;
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
  /*Void verifyType(Obj obj, Type t) {
    verify(obj.typeof == t, "$obj.typeof == $t")
  }

  **
  ** Verify that 'obj' is instance of the given type.
  **
  Void verifyIsType(Obj obj, Type t) {
    verify(obj.typeof.fits(t), "$obj.typeof not fits $t")
  }
  */

  **
  ** Verify that the function throws an Err of the
  ** exact same type as errType (compare using === operator).
  ** If the errType parameter is null, then this method
  ** tests only that an exception is thrown, not its type.
  **
  ** Example:
  **   verifyErr(ParseErr#) { x := Int.fromStr("@#!") }
  **
  Void verifyErr(Type? errType, |TestBase| c) {
    try {
      c(this)
      fail("No err thrown, expected $errType")
    } catch (Err err) {
      /*
      if (errType != null) {
        if (err.typeof != errType) {
          err.trace
        }
        verifyType(err, errType)
      }
      else {
        verifyNotNull(err)
      }
      */
    }
  }
  /*
  @NoDoc
  Void verifyErrMsg(Type errType, Str errMsg, |MyTest| c) {
    try {
      c(this)
      fail("No err thrown, expected $errType")
    } catch (Err err) {
      verifyType(err, errType)
      verifyEq(errMsg, err.msg)
    }
  }
  */

  **
  ** Throw a test failure exception.  If msg is non-null, include
  ** it in the failure exception.
  **
  Void fail(Str? msg := null) {
    //++failVerifyCount
    if (msg == null) throw Err("Test failed")
    throw Err("Test failed: $msg")
  }
}