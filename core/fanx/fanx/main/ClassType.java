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
	public boolean isGenericType() {
		return ftype.isGeneric();
	}
	
	@Override
	public Class<?> getJavaActualClass() {
		if (jActualClass == null) {
			try {
				String javaImp = FanUtil.toJavaClassName(podName(), name());
				jActualClass = ftype.pod.podClassLoader.loadClass(javaImp);
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
				jImplClass = ftype.pod.podClassLoader.loadClass(javaImp);
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
	
}