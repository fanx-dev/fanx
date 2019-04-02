

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
      whenDone?.call(res, err)
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

	** object to await and resolved value
	Obj? awaitObj

  ** async function final return result
	override T? result { protected set }

	** err in async task
	override Err? err

	** call when task done
	private |T?, Err?|? whenDone

	override Void then(|T?, Err?| f) {
		if (isDone) {
      f.call(result, err)
    }
    else whenDone = f
	}

  Bool next() {
    try {
      nextStep
    } catch (Err e) {
      this.err = e
      state = -1
    }
    
    if (isDone) {
      whenDone?.call(result, err)
      return false
    }
    return true
  }

	protected abstract Bool nextStep()

	This run() {
		|Async s|? runner := Actor.locals["async.runner"]
		if (runner == null) {
			throw Err("Expect async.runner in Acotr.locals")
		}
		runner.call(this)
		return this
	}
}