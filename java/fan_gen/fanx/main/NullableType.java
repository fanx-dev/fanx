//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Oct 08  Brian Frank  Creation
//
package fanx.main;

import fanx.fcode.FType;

/**
 * NullableType wraps a type as nullable with trailing "?".
 */
public class NullableType extends Type {
	public Type root;

	public NullableType(Type root) {
		this.root = root;
	}

	@Override
	public String podName() {
		return root.podName();
	}

	@Override
	public String name() {
		return root.name();
	}

	@Override
	public String qname() {
		return root.qname();
	}

	@Override
	public String signature() {
		return root.signature() + "?";
	}

	@Override
	public boolean isNullable() {
		return true;
	}

	@Override
	public Class<?> getJavaClass() {
		return root.getJavaClass();
	}

	@Override
	public void precompiled(Class<?> clz) {
		root.precompiled(clz);
	}

	@Override
	public boolean fits(Type t) {
		return root.fits(t);
	}

	@Override
	public boolean isObj() {
		return root.isObj();
	}

	@Override
	public long flags() {
		return root.flags();
	}

	@Override
	public Type toNullable() {
		return this;
	}
	
	@Override
	public Type toNonNullable() {
		return root;
	}

	@Override
	public FType ftype() {
		return root.ftype();
	}
}