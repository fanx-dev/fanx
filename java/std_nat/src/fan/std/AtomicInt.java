//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//
package fan.std;

import java.util.concurrent.atomic.AtomicLong;

import fan.sys.FanObj;
import fanx.main.Sys;
import fanx.main.Type;

public final class AtomicInt extends FanObj {
	private static Type type = null;

	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::AtomicInt");
		}
		return type;
	}
	
	public AtomicInt(long val) {
		this.val = new AtomicLong(val);
	}

	public static AtomicInt make(long val) {
		return new AtomicInt(val);
	}

	public final long val() {
		return val.get();
	}
	
	public final long get() {
		return val.get();
	}

	public final void val(long v) {
		val.set(v);
	}
	
	public final void set(long v) {
		val.set(v);
	}

	public final long getAndSet(long v) {
		return val.getAndSet(v);
	}

	public final boolean compareAndSet(long expect, long update) {
		return val.compareAndSet(expect, update);
	}

	public final long getAndIncrement() {
		return val.getAndIncrement();
	}

	public final long getAndDecrement() {
		return val.getAndDecrement();
	}

	public final long getAndAdd(long delta) {
		return val.getAndAdd(delta);
	}

	public final long incrementAndGet() {
		return val.incrementAndGet();
	}

	public final long decrementAndGet() {
		return val.decrementAndGet();
	}

	public final long addAndGet(long delta) {
		return val.addAndGet(delta);
	}

	public final void increment() {
		val.incrementAndGet();
	}

	public final void decrement() {
		val.decrementAndGet();
	}

	public final void add(long delta) {
		val.addAndGet(delta);
	}
	
	public String toStr() {
		return val.toString();
	}

	private final AtomicLong val;
}