//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

public class JavaType extends Type {
	Class<?> jtype;
	
	public JavaType(Class<?> jtype) {
		this.jtype = jtype;
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
	public String signature() {
		// TODO Auto-generated method stub
		return null;
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
		return false;
	}

	@Override
	public long flags() {
		// TODO Auto-generated method stub
		return 0;
	}
	@Override
	public Type toNullable() {
		return new NullableType(this);
	}
}