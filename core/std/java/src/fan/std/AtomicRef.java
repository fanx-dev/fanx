//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//
package fan.std;

import java.util.concurrent.atomic.AtomicReference;

import fan.sys.*;
import fanx.main.Sys;
import fanx.main.Type;

public final class AtomicRef extends FanObj {
	private static Type type = null;

	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::AtomicRef");
		}
		return type;
	}
	
	public AtomicRef(Object val) {
		if (!FanObj.isImmutable(val)) throw NotImmutableErr.make();
		this.val = new AtomicReference(val);
	}
	
	public static AtomicRef make() {
		AtomicRef self = new AtomicRef(null);
		return self;
	}

	public static AtomicRef make(Object val) {
		AtomicRef self = new AtomicRef(val);
		return self;
	}

	public final Object val() {
		return val.get();
	}
	
	public final Object get() {
		return val.get();
	}

	public final void val(Object v) {
		if (!FanObj.isImmutable(v))
			throw NotImmutableErr.make();
		val.set(v);
	}
	
	public final void set(Object v) {
		if (!FanObj.isImmutable(v))
			throw NotImmutableErr.make();
		val.set(v);
	}

	public final Object getAndSet(Object v) {
		if (!FanObj.isImmutable(v))
			throw NotImmutableErr.make();
		return val.getAndSet(v);
	}

	public final boolean compareAndSet(Object expect, Object update) {
		if (!FanObj.isImmutable(update))
			throw NotImmutableErr.make();
		return val.compareAndSet(expect, update);
	}
	
	public String toStr() {
		return val.toString();
	}

	private final AtomicReference val;
}