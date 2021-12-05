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
		t := Int.maxVal
		if (timeout != null) {
			t = timeout.toNanos
			if (t < 0) throw ArgErr("wait time is negative: $timeout")
		}
		return doWait(lock, t)
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