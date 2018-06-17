//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

public class JavaType extends Type {
	private Class<?> jclass;
	private NullableType nullable;
	
	public JavaType(Class<?> jtype) {
		this.jclass = jtype;
		nullable = new NullableType(this);
	}
	
	@Override
	public Type toNullable() {
		return nullable;
	}

	@Override
	public String podName() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String name() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String qname() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean isNullable() {
		return false;
	}
	
	@Override
	public Class<?> getJavaActualClass() {
		return jclass;
	}

	@Override
	public Class<?> getJavaClass() {
		return jclass;
	}

	@Override
	public void precompiled(Class<?> clz) {
		jclass = clz;
	}

	@Override
	public boolean isObj() {
		return this.getClass().equals(Object.class);
	}

	@Override
	public long flags() {
		return 0;
	}
}