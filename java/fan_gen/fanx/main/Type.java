//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

import fanx.fcode.FConst;
import fanx.fcode.FType;

public abstract class Type {
	
	public Object emptyList;

	public abstract String podName();

	public abstract String name();

	public abstract String qname();

	public abstract String signature();

	public abstract boolean isNullable();

	public abstract Class<?> getJavaClass();

	public abstract void precompiled(Class<?> clz);

	public abstract boolean fits(Type t);

	public abstract boolean isObj();

	public abstract long flags();

	public abstract Type toNullable();

	public boolean isConst() {
		return (flags() & FConst.Const) != 0;
	}

	public boolean isGenericType() {
		return false;
	}
	
	@Override
	public String toString() {
		return signature();
	}
	
	public FType ftype() { return null; }

}
