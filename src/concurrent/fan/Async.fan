
abstract class Async<T>  {
	** execute step state
	protected Int state := 0

	** object to await and resolved value
	Obj? awaitObj

  ** async function final return result
	T? result { protected set }

	** err in async task
	Err? err

	** call when task done
	@NoDoc |Async<T>|? whenDone { protected set }

	abstract Bool next()
	
	Void then(|This| f) { whenDone = f }

	This run() {
		|Async s|? runner := Actor.locals["async.runner"]
		if (runner == null) {
			throw Err("Expect async.runner in Acotr.locals")
		}
		runner.call(this)
		return this
	}
}