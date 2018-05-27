//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

import java.util.HashMap;
import java.util.Map;

import fanx.fcode.FField;
import fanx.fcode.FMethod;
import fanx.fcode.FSlot;
import fanx.fcode.FType;

public class ClassType extends Type
{
	FType ftype;
	Class<?> jtype;
	Map<String, FSlot> slots = null;
	
	public ClassType(FType t) {
		ftype = t;
	}

	@Override
	public String podName() {
		return ftype.podName();
	}

	@Override
	public String name() {
		return ftype.typeName();
	}

	@Override
	public String qname() {
		return ftype.qname();
	}

	@Override
	public String signature() {
		return ftype.signature();
	}

	@Override
	public boolean isNullable() {
		return false;
	}

	@Override
	public Class<?> getJavaClass() {
		return jtype;
	}

	@Override
	public void precompiled(Class<?> clz) {
		jtype = clz;
	}

	@Override
	public boolean fits(Type t) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean isObj() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public long flags() {
		return ftype.flags;
	}

	@Override
	public Type toNullable() {
		return new NullableType(this);
	}
	
	@Override
	public FType ftype() { return this.ftype; }
	
	public FSlot slot(String name) {
		initSlots();
		FSlot s = slots.get(name);
		return s;
	}
	
	private void initSlots() {
		if (slots != null) return;
		slots = new HashMap<String, FSlot>();
		
		for (FField f : ftype.fields) {
			slots.put(f.name, f);
		}
		for (FMethod f : ftype.methods) {
			slots.put(f.name, f);
		}
	}
}