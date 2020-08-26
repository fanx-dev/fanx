

mixin Promise<T> {
  abstract Bool isDone()
  abstract T? result()
  abstract Err? err()

  abstract Void then(|T?, Err?| f)
  
  @NoDoc virtual Void complete(Obj? res, Bool success) { throw UnsupportedErr() }

  static new make() {
    BasePromise()
  }
}

@NoDoc
virtual class BasePromise<T> : Promise<T> {
	private Lock lock := Lock()
  private |T?, Err?|? whenDone

  override Bool isDone := false { private set }
  override T? result { private set }
  override Err? err { private set }
  
  override Void complete(Obj? res, Bool success) {
  	lock.sync {
      if (success) result = res
      else err = res

      isDone = true
      whenDone?.call(result, err)
      lret null
    }
  }

  override Void then(|T?, Err?| f) {
    lock.sync {
      if (isDone) {
        f.call(result, err)
      }
      else whenDone = f
      lret null
    }
  }
}

abstract class Async<T> : Promise<T>  {
	** execute step state
	protected Int state := 0

	override Bool isDone() { state == -1 }

	** resolved value
	Obj? awaitRes

  ** async function final return result
	override T? result { protected set }

	** err in async task
	override Err? err

	** call when task done
	private |T?, Err?|? whenDone

  private AsyncRunner? runner

  ** await by parent
  private Async? parent

	override Void then(|T?, Err?| f) {
		if (isDone) {
      f.call(result, err)
    }
    else whenDone = f
	}

  ** run next step
  ** call by AsyncRunner
  Bool step() {
    //echo("step: $state  in $this")
    try {
      nextStep
    } catch (Err e) {
      this.err = e
      state = -1
    }
    //echo("end step: $state in $this")
    
    if (isDone) {
      //echo("done this:$this, parent:$parent, result:$result")
      whenDone?.call(result, err)
      if (parent != null) {
        parent.awaitRes = this.result
        parent.err = this.err
        parent.step
      }
      //dump exception
      if (parent == null && whenDone == null && err != null) {
        err.trace
      }
      return false
    }
    return true
  }

	protected abstract Bool nextStep()

  ** auto start when no await keyword
  @NoDoc
	This start() {
    //echo("start $this")
		AsyncRunner? runner := Actor.locals["async.runner"]
		if (runner == null) {
			throw Err("Expect async.runner in Acotr.locals")
		}
    this.runner = runner
		runner.run(this)
		return this
	}

  ** call on await expr
  @NoDoc
  Void waitFor(Obj? p) {
    //echo("await $p, runner:$runner")
    if (runner == null) {
      echo("state error")
    }

    if (p is Async) {
      a := (Async)p
      if (a.isDone) echo("state error")
      a.parent = this
      a.runner = this.runner

      // not call start() on Async
      // avoid finding in Actor.locals
      runner.run(a)
    }
    else if (p is Promise) {
      a := (Promise)p
      a.then |res, err| {
        this.awaitRes = res
        this.err = err
        runner.run(this)
      }
    }
    else {
      ok := runner.awaitOther(this, p)
      if (!ok) {
        this.awaitRes = p
        runner.run(this)
      }
    }
  }
}

mixin AsyncRunner {
  ** return false if not unknow 
  protected virtual Bool awaitOther(Async s, Obj? awaitObj) { false }

  ** run in custem thread
  virtual Void run(Async s) {
    s.step
  }
}

