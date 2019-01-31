using concurrent

class AsyncTest {

  async Void testLoop(Int n) {
    for (i:=0; i<n; ++i) {
      await i
    }
  }

  async Int testTry(Int n) {
    try {
      t := await n + 1
      throw Err(t.toStr)
      return t
    }
    catch (Err e) {
      echo(e)
      return 100
    }
  }

  async Int testValue(Int n) {
    return await n + 1
  }

  private Void init() {
    Actor.locals["async.runner"] = |Async<Obj> s| {
      if (s.next) {
        echo("pause :" + s.awaitObj)
        s.run
      }
      echo("end")
    }
  }

  Void main() {
    init

    x := testValue(10)
    assert(x is Async)
  	testLoop(10)

    f := testTry(10)
    assert(f.result == 100)
  }
}
