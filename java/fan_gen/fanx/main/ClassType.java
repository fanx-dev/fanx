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
	private Class<?> jclass;
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
	public Class<?> getJavaClass() {
		if (jclass == null) {
			try {
				String javaImp = FanUtil.toJavaImplClassName(podName(), name());
				jclass = ftype.pod.podClassLoader.loadClass(javaImp);
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