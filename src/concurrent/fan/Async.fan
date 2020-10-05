

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


@NoPeer
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
    if (isDone) throw Err("state err, already done. $this")
    //echo("step: $state  in $this")
    try {
      nextStep
    } catch (Err e) {
      this.err = e
      state = -1
      //e.trace
    }
    //echo("end step: $state in $this")
    
    if (isDone) {
      //echo("done this:$this, parent:$parent, result:$result")
      whenDone?.call(result, err)
      if (parent != null) {
        parent.awaitRes = this.result
        parent.err = this.err
        if (parent.runner == null) parent.runner = this.runner
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
    //first time run in current thread
    this.step
    //this.getRunner.run(this)
		return this
	}

  private AsyncRunner getRunner() {
    if (this.runner == null) {
      this.runner = Actor.locals["async.runner"]
      if (this.runner == null) {
        throw Err("Expect async.runner in Acotr.locals")
      }
    }
    return this.runner
  }

  ** call on await expr
  ** return false if done
  @NoDoc
  Bool waitFor(Obj? p) {
    if (p is Async) {
      a := (Async)p
      //already done
      if (a.isDone) {
        //echo("already isDone $a")
        this.awaitRes = a.result
        this.err = a.err
        return false
      }
      else {
        //call me later
        a.parent = this
      }
    }
    else if (p is Promise) {
      a := (Promise)p
      //init runner in current thread
      r := getRunner
      a.then |res, err| {
        this.awaitRes = res
        this.err = err
        //calback maybe in other thread
        r.run(this)
      }
    }
    else if (p is ActorFuture) {
      a := (ActorFuture)p
      r := getRunner
      a._then |res, err| {
        this.awaitRes = res
        this.err = err
        //calback maybe in other thread
        r.run(this)
      }
    }
    else {
      ok := getRunner.awaitOther(this, p)
      if (!ok) {
        this.awaitRes = p
        getRunner.run(this)
      }
    }
    return true
  }

  static native Promise sleep(Duration d)
}

mixin AsyncRunner {
  ** return false if not unknow 
  protected virtual Bool awaitOther(Async s, Obj? awaitObj) { false }

  ** run in custem thread
  virtual Void run(Async s) {
    s.step
  }
}

