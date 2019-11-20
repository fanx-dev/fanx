//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

import fanx.fcode.FType;
import fanx.util.FanUtil;

public class ClassType extends Type
{
	FType ftype;
	private Class<?> jImplClass;
	private Class<?> jActualClass;
	private NullableType nullable;
	
	private Type base;
	private Type[] mixins;
	
	public ClassType(FType t) {
		ftype = t;
		nullable = new NullableType(this);
	}
	
	@Override
	public Type toNullable() {
		return nullable;
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
	public boolean isNullable() {
		return false;
	}
	
	@Override
	public boolean isJava() {
		return false;
	}
	
	@Override
	public boolean isGeneric() {
		return ftype.isGeneric();
	}
	
	@Override
	public Class<?> getJavaActualClass() {
		if (jActualClass == null) {
			try {
				String javaImp = FanUtil.toJavaClassName(podName(), name());
				jActualClass = JavaType.nameToClass(ftype.pod.podClassLoader, javaImp);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		return jActualClass;
	}

	@Override
	public Class<?> getJavaImplClass() {
		if (jImplClass == null) {
			try {
				String javaImp = FanUtil.toJavaImplClassName(podName(), name());
				jImplClass = JavaType.nameToClass(ftype.pod.podClassLoader, javaImp);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		return jImplClass;
	}

	@Override
	public void precompiled(Class<?> clz) {
		jActualClass = clz;
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
	
	@Override
	public Type base() {
		if (base != null) return base;
		FType ftype = this.ftype();
		if (ftype.base == 0xFFFF) {
			return null;
		}
		base = Sys.getTypeByRefId(ftype.pod, ftype.base);
		return base;
	}
	
	@Override
	public Type[] mixins() {
		if (mixins != null) return mixins;
		Type[] ms = new Type[ftype.mixins.length];
		for (int i=0; i<ftype.mixins.length; ++i) {
			int mixin = ftype.mixins[i];
			Type t = Sys.getTypeByRefId(ftype.pod, mixin);
			ms[i] = t;
		}
		mixins = ms;
		return ms;
	}
	
}