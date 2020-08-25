//using concurrent

class AsyncTest : Test {

  private static Int inc(|Int->Int| f) { return f(1) }

  async Int runClosure() {
    a := 1
    x := inc |Int t->Int|{ a + t }
    return x
  }

  async Void doLoop(Int n) {
    for (i:=0; i<n; ++i) {
      await i
    }
  }

  async Int doTry(Int n) {
    try {
      t := await n + 1
      throw Err(t.toStr)
      return t
    }
    catch (Err e) {
      echo("Err: "+e)
      return 100
    }
  }

  async Int doValue(Int n) {
    return await n + 1
  }


  private Void init() {
    Actor.locals["async.runner"] = |Async<Obj> s| {
      if (s.next) {
        echo("pause :" + s.awaitObj)
        if (s.awaitObj is Promise) {
          s.awaitObj = (s.awaitObj as Promise).result
        }
        s.run
      }
      echo("end")
    }
  }

  Void test() {
    init

    x := doValue(10)
    verify(x is Async)

  	doLoop(10)
  }

  Void testException() {
    init

    f := doTry(10)
    verifyEq(f.result, 100)
  }

  Void testClosure() {
    init
    res := runClosure
    verifyEq(res.result, 2)
  }


  Int fieldValue := 0
  async Void doSetField(Int n) {
    fieldValue = await doValue(n)
    //echo("fieldValue:$fieldValue")
  }

  
  Void testSetField() {
    init
    doSetField(2)
    verifyEq(fieldValue, 3)
  }
  

  ////////////////////////////////////////////////

  private Promise<Str> doPromise() {
    return Promise.make()
  }

  async Void doWaitPromise() {
    p := await doPromise
    echo(p?.size)
  }

  Void testPromise() {
    init

    doWaitPromise
  }
}
