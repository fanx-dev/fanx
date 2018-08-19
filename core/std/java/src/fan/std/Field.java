package fan.std;

import fan.std.Map;
import fan.sys.*;
import fanx.fcode.*;
import fanx.fcode.FAttrs.FFacet;
import fanx.main.*;

/**
 * Field is a slot which "stores" a value.
 */
public class Field extends Slot {

	//////////////////////////////////////////////////////////////////////////
	// Factories
	//////////////////////////////////////////////////////////////////////////

	public static Func makeSetFunc(final Map map) {
		return new Func() {
			public Object call(Object obj) {
				List keys = map.keys();
				for (int i = 0; i < keys.size(); ++i) {
					Field field = (Field) keys.get(i);
					Object val = map.get(field);
					field._set(obj, val, obj != inCtor);
				}
				return null;
			}

			@Override
			public boolean isImmutable() {
				return true;
			}

//			@Override
//			public Type returns() {
//				return null;
//			}

			@Override
			public long arity() {
				return 1;
			}
		};
	}

	//////////////////////////////////////////////////////////////////////////
	// Java Constructor
	//////////////////////////////////////////////////////////////////////////

	public Field(Type parent, String name, int flags, List facets, int lineNum, Type type) {
		super(parent, name, flags, facets, lineNum);
		this.type = type;
	}
	
	public static Field fromFCode(FField f, Type parent) {
		FType ftype = parent.ftype();
		FTypeRef tref = ftype.pod.typeRef(f.type);
		Type type = Sys.findType(tref.signature);
		
		List facets = List.make(1);
		if (f.attrs.facets != null) {
			facets.capacity(f.attrs.facets.length);
			for (FFacet facet : f.attrs.facets) {
				Facet fa = TypeExt.decode(facet, ftype.pod);
				facets.add(fa);
			}
		}
		Field field = new Field(parent, f.name, f.flags, facets, 0, type);
		
		if ((f.flags & FConst.Storage) != 0) {
			try {
				Class<?> clz = parent.getJavaImplClass();
				if (clz.isInterface()) {
					clz = Class.forName(clz.getName()+"$");
				}
				field.reflect = clz.getDeclaredField(f.name);
				field.reflect.setAccessible(true);
			} catch (NoSuchFieldException e) {
				e.printStackTrace();
			} catch (SecurityException e) {
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		
		return field;
	}

	//////////////////////////////////////////////////////////////////////////
	// Signature
	//////////////////////////////////////////////////////////////////////////

	private static Type typeof = Sys.findType("std::Field");

	public Type typeof() {
		return typeof;
	}

	public Type type() {
		return type;
	}

	public String signature() {
		return type.signature() + " " + name;
	}

	public Object trap(String name, List args) {
		// private undocumented access
		if (name.equals("getter"))
			return getter;
		if (name.equals("setter"))
			return setter;
		return super.trap(name, args);
	}

	//////////////////////////////////////////////////////////////////////////
	// Reflection
	//////////////////////////////////////////////////////////////////////////

	public Object get() {
		return get(null);
	}

	public Object get(Object instance) {
		// parent.finish();

		if (getter != null) {
			return getter.invoke(instance, Method.noArgs);
		}

		try {
			// if JavaType handle slot resolution
			// if (parent.isJava()) return JavaType.get(this, instance);
			return reflect.get(instance);
		} catch (Exception e) {
			if (reflect == null)
				throw Err.make("Field not mapped to java.lang.reflect correctly " + qname());

			throw Err.make(e);
		}
	}

	public void set(Object instance, Object value) {
		_set(instance, value, true);
	}

	public void _set(Object instance, Object value, boolean checkConst) {
		// parent.finish();
		// check const
		if ((flags & FConst.Const) != 0) {
			if (checkConst)
				throw ReadonlyErr.make("Cannot set const field " + qname());
			else if (value != null && !isImmutable(value))
				throw ReadonlyErr.make("Cannot set const field " + qname() + " with mutable value");
		}

		// check static
		if ((flags & FConst.Static) != 0)
			throw ReadonlyErr.make("Cannot set static field " + qname());

		// // check generic type (the Java runtime will check non-generics)
		// if (type.isGenericInstance() && value != null)
		// {
		// if (!typeof(value).is(type.toNonNullable()))
		// throw ArgErr.make("Wrong type for field " + qname() + ": " + type + "
		// != " + typeof(value));
		// }

		// use the setter by default, however if we have a storage field and
		// the setter was auto-generated then falldown to set the actual field
		// to avoid private setter implicit overrides
		if ((setter != null && !setter.isSynthetic()) || reflect == null) {
			setter.invoke(instance, new Object[] { value });
			return;
		}

		try {
			// if JavaType handle slot resolution
			// if (parent.isJava()) { JavaType.set(this, instance, value);
			// return; }
			reflect.set(instance, value);
		} catch (IllegalArgumentException e) {
			throw ArgErr.make(e);
		} catch (Exception e) {
			if (reflect == null)
				throw Err.make("Field not mapped to java.lang.reflect correctly");

			throw Err.make(e);
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	Type type;
	Method getter;
	Method setter;
	java.lang.reflect.Field reflect;
	Method overload; // if overloaded by method in JavaType

}