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

import fanx.fcode.FConst;
import fanx.fcode.FDoc;
import fanx.fcode.FPod;
import fanx.fcode.FType;
import fanx.fcode.FTypeRef;

public abstract class Type {

	public Map<String, Object> slots = null;
	public java.util.Map<Type, Object> factesMap = null;
	public Object factesList = null;
	
	private Map<String, ParameterizedType> paramType;

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

	public boolean isGeneric() {
		return false;
	}
	
	public boolean isParameterized() {
		return false;
	}

	@Override
	public String toString() {
		return signature();
	}

	public FType ftype() {
		return null;
	}
	
	public abstract boolean isJava();
	
	public int lineNumber() {
		FType ft = ftype();
		if (ft == null) return -1;
		return ft.attrs.lineNum;
	}
	
	public String sourceFile() {
		FType ft = ftype();
		if (ft == null) return null;
		return ft.attrs.sourceFile;
	}
	
	public String doc(String slot) {
		FType ft = ftype();
		if (ft == null) return null;
		if (slot == null) return ft.doc().tyeDoc();
		return ft.doc().slotDoc(slot);
	}
	
	public static Type fromFType(FType ftype, String signature) {
		if (ftype.reflectType == null) {
			//need new instance for every signature?
			ClassType ct = new ClassType(ftype);
			ftype.reflectType = ct;
		}
		Type baseType = (Type) ftype.reflectType;
		
		if (signature == null) return baseType;
		if (baseType.signature().equals(signature)) return baseType;
		
		if (baseType.paramType == null) {
			baseType.paramType = new HashMap<String, ParameterizedType>();
		}
		else {
			Type t = baseType.paramType.get(signature);
			if (t != null) return t;
		}
		
		ParameterizedType t = new ParameterizedType(baseType, signature);
		baseType.paramType.put(signature, t);
		return t;
	}
	
//	public static Type refToType(FPod pod, int typeRefId) {
//		return Sys.getTypeByRefId(pod, typeRefId);
//	}
	
	public abstract Type[] mixins();

	public abstract Type base();
	
	public static Type find(String signature) {
		return Sys.findType(signature);
	}

	@Override
	public boolean equals(Object obj) {
		if (!(obj instanceof Type)) {
			return false;
		}
		return qname().equals(((Type)obj).qname());
	}

	public boolean isImmutable() {
    return true;
  }

  public Object toImmutable() {
    return this;
  }
}
