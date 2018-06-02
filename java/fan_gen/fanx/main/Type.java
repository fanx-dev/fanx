//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

import java.util.List;
import java.util.Map;

import fanx.fcode.FConst;
import fanx.fcode.FType;

public abstract class Type {
	
	public Map<String, Object> slots = null;
	public Map<String, List<Object>> jslots = null;
	
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
	
	
	public static Type fromFType(FType ftype) {
		if (ftype.reflectType == null) {
			ClassType ct = new ClassType(ftype);
			ftype.reflectType = ct;
		}
		Type res = (Type)ftype.reflectType;
		return res;
	}

}
