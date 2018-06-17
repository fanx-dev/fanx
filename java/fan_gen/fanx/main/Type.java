//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

import java.util.Map;

import fanx.fcode.FConst;
import fanx.fcode.FPod;
import fanx.fcode.FType;
import fanx.fcode.FTypeRef;

public abstract class Type {

	public Map<String, Object> slots = null;

	public Object emptyList;
	
	public abstract String podName();

	public abstract String name();

	public abstract String qname();

	public String signature() {
		return qname();
	}

	public abstract boolean isNullable();

	public abstract Class<?> getJavaImplClass();
	
	public abstract Class<?> getJavaActualClass();

	public abstract void precompiled(Class<?> clz);

	public boolean fits(Type t) {
		return is(this.toNonNullable(), t.toNonNullable());
	}

	private static boolean is(Type self, Type type) {
		// we don't take nullable into account for fits
		if (type instanceof NullableType)
			type = ((NullableType) type).root;

		if (type == self || (type.isObj()))
			return true;
		
		return type.getJavaActualClass().isAssignableFrom(self.getJavaActualClass());
		//TODO
//		List inheritance = inheritance(self);
//		for (int i = 0; i < inheritance.size(); ++i)
//			if (inheritance.get(i) == type)
//				return true;
//		return false;
	}

	public abstract boolean isObj();

	public abstract long flags();

	public Type toNonNullable() {
		return this;
	}

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

	public FType ftype() {
		return null;
	}

	public static Type fromFType(FType ftype, String signature) {
		if (ftype.reflectType == null) {
			//need new instance for every signature?
			ClassType ct = new ClassType(ftype);
			ftype.reflectType = ct;
		}
		Type res = (Type) ftype.reflectType;
		return res;
	}
	
	public static Type refToType(FPod pod, int typeRefId) {
		FTypeRef tref = pod.typeRef(typeRefId);
		FType ft = Sys.findFType(tref.podName, tref.typeName);
		Type t = Type.fromFType(ft, tref.signature);
		return t;
	}

	public Type base() {
		FType ftype = this.ftype();
		if (ftype.base == 0xFFFF) {
			return null;
		}
		return refToType(ftype.pod, ftype.base);
	}

}
