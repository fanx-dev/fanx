using concurrent

class Main {

  async Void foo(Int n) {
    for (i:=0; i<n; ++i) {
      try {
        await i
      }
      catch (Err e) {
        echo(e)
      }
    }
  }

  Void main() {
    Actor.locals["async.runner"] = |Async<Obj> s| {
      if (s.next) {
        echo("pause :" + s.awaitObj)
        s.run
      }
      echo("end")
    }
  	foo(10)
  }
}
