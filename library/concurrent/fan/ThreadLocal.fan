//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-13 Jed Young Creation
//

internal rtconst class ThreadLocal<T> {
	private [Int:T] vals := [:]
	private Lock lock := Lock()

	new make() {
	}

	** Returns the value in the current thread's copy of this thread-local variable.
	T get() {
		tid := Thread.curId
		lock.lock
		v := vals.get(tid)
		lock.unlock
		return v
	}

	** Sets the current thread's copy of this thread-local variable to the specified value.
	This set(T val) {
		tid := Thread.curId
		lock.lock
		vals[tid] = val
		lock.unlock
		return this
	}

	** Removes the current thread's value for this thread-local variable
	Void remove() {
		tid := Thread.curId
		lock.lock
		vals.remove(tid)
		lock.unlock
	}

	override Bool isImmutable() { true }
}