//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-13 Jed Young Creation
//

@NoDoc
class ConditionVar {
	private Int handle
	private Lock lock

	new make(Lock lock) { this.lock = lock; init(lock) }
	private native Void init(Lock lock)

	Bool wait(Duration? timeout := null) {
		doWait(lock, timeout != null ? timeout.toNanos : Int.maxVal)
	}

	private native Bool doWait(Lock lock, Int nanos)
	
	** notify
	Void signal() { doSignal(lock) }
	
	** notifyAll
	Void signalAll() { doSignalAll(lock) }

	private native Void doSignal(Lock lock)
	private native Void doSignalAll(Lock lock)

	protected native override Void finalize()
}