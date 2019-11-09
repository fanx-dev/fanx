package fanx.main;

import fanx.fcode.FType;

public class ParameterizedType extends Type {
	public Type root;
	private String signature;

	public ParameterizedType(Type root, String signature) {
		this.root = root;
		this.signature = signature;
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
		return signature;
	}

	@Override
	public boolean isNullable() {
		return root.isNullable();
	}
	
	@Override
	public boolean isJava() {
		return root.isJava();
	}
	
	@Override
	public Class<?> getJavaActualClass() {
		return root.getJavaActualClass();
	}

	@Override
	public Class<?> getJavaImplClass() {
		return root.getJavaImplClass();
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
	
	@Override
	public Type[] mixins() {
		return root.mixins();
	}
	
	@Override
	public Type base() {
		return root.base();
	}
	
	@Override
	public boolean isParameterized() {
		return false;
	}
}
