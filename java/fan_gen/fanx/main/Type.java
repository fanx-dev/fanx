package fanx.main;

import fanx.fcode.FConst;

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

}
