//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//
package fan.std;

import java.util.concurrent.atomic.AtomicBoolean;

import fan.sys.FanObj;
import fanx.main.Sys;
import fanx.main.Type;

public final class AtomicBool extends FanObj {
	private static Type type = null;

	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::AtomicBool");
		}
		return type;
	}
	
	public AtomicBool(boolean v) {
		this.val = new AtomicBoolean(v);
	}
	
	public static AtomicBool make() {
		return new AtomicBool(false);
	}

	public static AtomicBool make(boolean v) {
		return new AtomicBool(v);
	}
	
	public final boolean get() {
		return val.get();
	}

	public final boolean val() {
		return val.get();
	}

	public final void val(boolean v) {
		val.set(v);
	}
	
	public final void get(boolean v) {
		val.set(v);
	}

	public final boolean getAndSet(boolean v) {
		return val.getAndSet(v);
	}

	public final boolean compareAndSet(boolean expect, boolean update) {
		return val.compareAndSet(expect, update);
	}
	
	public String toStr() {
		return val.toString();
	}
	
	private final AtomicBoolean val;
}