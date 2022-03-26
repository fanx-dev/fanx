//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-13 Jed Young Creation
//

internal class Thread {
	private Int handle
	private Str? _name
	private |->|? _runable
	private Bool _isStarted := false

	new make(Str? name, |->|? runable) {
		_name = name
		_runable = runable
	}

	This start() {
		if (_isStarted) return this
		_isStarted = true
		_start(_name)
		return this
	}

	virtual Void run() { if (_runable != null) _runable() }

	private native Void _start(Str name)
	//private native Bool detach()
	native Bool join()

	native Int id()
	native static Int curId()
	static Bool sleep(Duration timeout) { sleepNanos(timeout.toNanos) }
	native static Bool sleepNanos(Int nanos)

	//protected native override Void finalize()

	override Str toStr() { "Thread:$_name" }
}