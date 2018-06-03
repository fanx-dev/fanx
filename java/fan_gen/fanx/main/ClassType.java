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
	private Class<?> jclass;
	
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
		if (jclass == null) {
			try {
				jclass = ftype.pod.podClassLoader.loadClass("fan."+ftype.pod.podName+"."+ftype.typeName());
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		return jclass;
	}

	@Override
	public void precompiled(Class<?> clz) {
		jclass = clz;
	}

	@Override
	public boolean isObj() {
		return ftype.base ==  0xFFFF;
	}

	@Override
	public long flags() {
		return ftype.flags;
	}
	
	@Override
	public FType ftype() { return this.ftype; }
	
}