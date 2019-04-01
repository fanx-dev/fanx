

mixin Promise<T> {
  abstract Bool isDone()
  abstract T? result()

  abstract Void then(|T?| f)
  
  @NoDoc virtual Void complete(Obj? res) { throw UnsupportedErr() }

  static new make() {
    BasePromise()
  }
}

@NoDoc
virtual class BasePromise<T> : Promise<T> {
	private Lock lock := Lock()
  private |T?|? whenDone

  override Bool isDone := false { private set }
  override T? result { private set }
  
  override Void complete(Obj? res) {
  	lock.sync {
      result = res
      isDone = true
      whenDone?.call(res)
      lret null
    }
  }

  override Void then(|T?| f) {
    lock.sync {
      if (isDone) {
        f.call(result)
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
	Err? err

	** call when task done
	private |Async<T>|? whenDone

	override Void then(|This| f) {
		if (isDone) {
      f.call(err ?: result)
    }
    else whenDone = f
	}

  Bool next() {
    done := nextStep
    if (done) {
      whenDone?.call(err ?: result)
    }
    return done
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