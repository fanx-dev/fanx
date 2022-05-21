//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;

import java.util.HashMap;

import fanx.fcode.FConst;
import fanx.fcode.FType;
import fanx.util.FanUtil;
import fanx.util.StrUtil;

public class JavaType extends Type {
	private Class<?> jclass;
	private NullableType nullable;
	private String podName;
	private String typeName;

	private int flags = -1; // init()
	private Type base; // init()
	private Type[] mixins; // init()

	public JavaType(Class<?> cls) {
		this.jclass = cls;

		if (cls.isArray() && cls.getComponentType().isPrimitive()) {
			this.podName = "[java]fanx.interop";
			this.typeName = StrUtil.capitalize(cls.getComponentType().getSimpleName()) + "Array";
		} else {
			// if array, get component type x
			Class x = cls;
			int rank = 0;
			while (x.isArray()) {
				rank++;
				x = x.getComponentType();
			}

			// parse packageName and className
			String fullName = x.getName();
			String packName = "";
			String typeName = fullName;
			int dot = fullName.lastIndexOf('.');
			if (dot > 0) {
				packName = fullName.substring(0, dot);
				typeName = fullName.substring(dot + 1);
			}

			// if we have an array rank, prefix "["
			for (int i = 0; i < rank; ++i)
				typeName = "[" + typeName;

			// now we have our Fantom pod/type names
			this.podName = "[java]" + packName;
			this.typeName = typeName;
		}

		nullable = new NullableType(this);
	}

	@Override
	public Type toNullable() {
		return nullable;
	}

	@Override
	public String podName() {
		return podName;
	}

	@Override
	public String name() {
		return typeName;
	}

	@Override
	public String qname() {
		return podName + "::" + typeName;
	}

	@Override
	public boolean isNullable() {
		return false;
	}
	@Override
	public boolean isJava() {
		return true;
	}

	@Override
	public Class<?> getJavaActualClass() {
		return jclass;
	}

	@Override
	public Class<?> getJavaImplClass() {
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
		return init().flags;
	}

	@Override
	public Type base() {
		return init().base;
	}
	
	@Override
	public Type[] mixins() {
		return init().mixins;
	}
	
	/**
	 * Init is responsible for lazily initialization of type level information:
	 * flags, base, mixins, and iinheritance.
	 */
	private synchronized JavaType init() {
		if (flags != -1)
			return this;
		try {
			// find Java class
			Class cls = this.getJavaActualClass();

			// flags
			flags = FanUtil.classModifiersToFanFlags(cls.getModifiers());
			if (cls.isAnnotation())
				flags |= FConst.Const;

			// superclass is base class
			Class superclass = cls.getSuperclass();
			if (superclass != null)
				base = FanUtil.toFanType(superclass, true);
			else
				base = Sys.findType("sys::Obj");

			// interfaces are mixins
			Class[] interfaces = cls.getInterfaces();
			mixins = new Type[interfaces.length];
			for (int i = 0; i < interfaces.length; ++i)
				mixins[i] = (FanUtil.toFanType(interfaces[i], true));

			// inheritance
			// inheritance = ClassType.inheritance(this);
		} catch (Exception e) {
			System.out.println("ERROR: JavaType.init: " + this);
			e.printStackTrace();
		}
		return this;
	}

	/////////////////////////////////////////////////////////////////////////////////

	private static HashMap<String, JavaType> javaTypeCache = new HashMap(); // String
	// class
	// name
	// =>
	// JavaType

	/**
	 * Given a Java class, get its FFI JavaType mapping. This method is called
	 * by FanUtil.toFanType. JavaTypes are be cached by classname once loaded.
	 */
	public static final JavaType loadJavaType(Class cls) {
		// at this point we shouldn't have any native fan type
		String clsName = cls.getName();
		if (clsName.startsWith("fan."))
			throw new IllegalStateException(clsName);

		// cache all the java types statically
		synchronized (javaTypeCache) {
			// if cached use that one
			JavaType t = (JavaType) javaTypeCache.get(clsName);
			if (t != null)
				return t;

			// create a new one
			t = new JavaType(cls);
			javaTypeCache.put(clsName, t);
			return t;
		}
	}

	/**
	 * Given a Java FFI qname (pod and type name), get its FFI JavaType mapping.
	 * JavaTypes are cached once loaded. This method is kept as light weight as
	 * possible since it is used to stub all the FFI references at pod load time
	 * (avoid loading classes). The JavaType will delegate to `loadJavaClass`
	 * when it is time to load the Java class mapped by the FFI type.
	 */
	public final static JavaType loadJavaType(ClassLoader loader, String podName, String typeName) {
		// we shouldn't be using this method for pure Fantom types
		if (!podName.startsWith("[java]"))
			throw Sys.makeErr("sys::ArgErr", "Unsupported FFI type: " + podName + "::" + typeName);

		// ensure unnormalized "[java] package::Type" isn't used (since
		// it took me an hour to track down a bug related to this)
		if (podName.length() >= 7 && podName.charAt(6) == ' ')
			throw Sys.makeErr("sys::ArgErr", "Java FFI qname cannot contain space: " + podName + "::" + typeName);

		// cache all the java types statically
		synchronized (javaTypeCache) {
			// if cached use that one
			String clsName = FanUtil.toJavaClassName(podName, typeName);
			JavaType t = (JavaType) javaTypeCache.get(clsName);
			if (t != null)
				return t;

			// resolve class to create new JavaType for this class name
			try {
				Class cls = nameToClass(loader, clsName);
				t = new JavaType(cls);
				javaTypeCache.put(clsName, t);
				return t;
			} catch (ClassNotFoundException e) {
				throw Sys.makeErr("sys::UnknownTypeErr", clsName + ":" + e);
			}
		}
	}

	static Class nameToClass(ClassLoader loader, String name) throws ClassNotFoundException {
		// first try primitives because Class.forName doesn't work for them
		Class cls = (Class) primitiveClasses.get(name);
		if (cls != null)
			return cls;

		// array class like "[I" or "[Lfoo.Bar;"
		if (name.charAt(0) == '[') {
			// if not a array of class, then use Class.forName
			if (!name.endsWith(";"))
				return Class.forName(name);

			// resolve component class "[Lfoo.Bar;"
			String compName = name.substring(2, name.length() - 1);
			Class comp = nameToClass(loader, compName);
			return java.lang.reflect.Array.newInstance(comp, 0).getClass();
		}

		// if we have a pod class loader use it
		if (loader != null)
			 return loader.loadClass(name);

		// fallback to Class.forName
		return Class.forName(name);
	}

	// String -> Class
	private static final HashMap primitiveClasses = new HashMap();
	static {
		try {
			primitiveClasses.put("boolean", boolean.class);
			primitiveClasses.put("char", char.class);
			primitiveClasses.put("byte", byte.class);
			primitiveClasses.put("short", short.class);
			primitiveClasses.put("int", int.class);
			primitiveClasses.put("long", long.class);
			primitiveClasses.put("float", float.class);
			primitiveClasses.put("double", double.class);
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}
}