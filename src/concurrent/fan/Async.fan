
abstract class Async<T>  {
	protected Int state := 0
	Obj? awaitObj

	T? result { protected set }
	Err? err
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