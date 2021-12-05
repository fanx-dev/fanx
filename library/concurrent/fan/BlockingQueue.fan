//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-13 Jed Young Creation
//

@NoDoc
rtconst class BlockingQueue {
	private Lock lock = Lock()
	private ConditionVar condVar := ConditionVar(lock)
	
	private LinkedList list = LinkedList()
	private Int maxSize
	private Bool cancelled := false

	new make(Int maxSize := Int.maxVal) { this.maxSize = maxSize }

	override Bool isImmutable() { true }

	Void enqueue(Obj? obj) {
		lock.lock
		while (list.size > maxSize) {
			if (cancelled) {
				lock.unlock
				return
			}
			condVar.wait()
		}
		list.add(LinkedElem(obj))
		lock.unlock
		condVar.signalAll
	}

	Int size() {
		s := 0
		lock.lock
		s = list.size
		lock.unlock
		return s
	}

	Obj? dequeue(Duration? timeout = null) {
		Int deadline
		if (timeout != null) deadline = TimePoint.nowMillis() + timeout.toMillis();
		Obj? res
		lock.lock
		while (list.isEmpty) {
			if (cancelled) break
			Duration? left
			if (timeout != null) {
				leftMillis := deadline - TimePoint.nowMillis()
				if (leftMillis < 0) break
				left = Duration.fromMillis(leftMillis);
			}
			condVar.wait(left)
		}
		first := list.removeFirst
		lock.unlock
		if (first != null) {
			res = first.val
			condVar.signal
		}
		return res
	}

	Void stop() {
		lock.lock
		cancelled = true
		lock.unlock
		condVar.signalAll
	}

	Bool isStopped() { cancelled }
}