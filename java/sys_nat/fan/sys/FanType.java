package fan.sys;

import fanx.fcode.FConst;
import fanx.fcode.FType;
import fanx.main.JavaType;
import fanx.main.Sys;
import fanx.main.Type;
import fanx.util.FanUtil;

public class FanType {

	//////////////////////////////////////////////////////////////////////////
	// Management
	//////////////////////////////////////////////////////////////////////////

	public static Type of(Object obj) {
		if (obj instanceof FanObj)
			return ((FanObj) obj).typeof();
		else
			return FanUtil.toFanType(obj.getClass(), true);
	}

	public static Type find(String sig) {
		return find(sig, true);
	}

	public static Type find(String sig, boolean checked) {
		return Sys.findType(sig, checked);
	}
	
//	public static Object make(Type self) {
//		return make(self, null);
//	}
//
//	public static Object make(Type self, List args) {
//		try {
//			Object res = FanObj.doTrap(null, "make", args, self);
//			return res;
//		} catch(Exception e) {
//			try {
//				if (args == null || args.size() == 0) {
//					Object res = FanObj.doTrap(null, "defVal", args, self);
//					return res;
//				}
//			}
//			catch(Exception e2) {
//			}
//		}
//
//		throw Err.make("Type missing 'make' or 'defVal' slots: " + self);
//	}

	//////////////////////////////////////////////////////////////////////////
	// Naming
	//////////////////////////////////////////////////////////////////////////

	public static Type type = Sys.findType("sys::Type");

	public static Type typeof(Type self) {
		return type;
	}

	public static String podName(Type self) {
		return self.podName();
	}

	// public static Pod pod();
	public static String name(Type self) {
		return self.name();
	}

	public static String qname(Type self) {
		return self.qname();
	}

	public static String signature(Type self) {
		return self.signature();
	}

	//////////////////////////////////////////////////////////////////////////
	// Flags
	//////////////////////////////////////////////////////////////////////////

	public static boolean isAbstract(Type self) {
		return (self.flags() & FConst.Abstract) != 0;
	}

	public static boolean isClass(Type self) {
		return (self.flags() & (FConst.Enum | FConst.Mixin)) == 0;
	}

	public static boolean isConst(Type self) {
		return (self.flags() & FConst.Const) != 0;
	}

	public static boolean isEnum(Type self) {
		return (self.flags() & FConst.Enum) != 0;
	}

	public static boolean isFacet(Type self) {
		return (self.flags() & FConst.Facet) != 0;
	}

	public static boolean isFinal(Type self) {
		return (self.flags() & FConst.Final) != 0;
	}

	public static boolean isInternal(Type self) {
		return (self.flags() & FConst.Internal) != 0;
	}

	public static boolean isMixin(Type self) {
		return (self.flags() & FConst.Mixin) != 0;
	}

	public static boolean isNative(Type self) {
		return (self.flags() & FConst.Native) != 0;
	}

	public static boolean isPublic(Type self) {
		return (self.flags() & FConst.Public) != 0;
	}

	public static boolean isSynthetic(Type self) {
		return (self.flags() & FConst.Synthetic) != 0;
	}

	public static long flags(Type self) {
		return self.flags();
	}

	public static Object trap(Type self, String name, List args) {
		// private undocumented access
		if (name.equals("flags"))
			return Long.valueOf(flags(self));
		if (name.equals("toClass"))
			return toClass(self);
		if (name.equals("lineNumber")) { return Long.valueOf(self.ftype().attrs.lineNum); }
		if (name.equals("sourceFile")) { return self.ftype().attrs.sourceFile; }
		
		// if (name.equals("finish")) { finish(); return self; }
		return FanObj.doTrap(self, name, args, typeof(self));//(self, name, args);
	}

	//////////////////////////////////////////////////////////////////////////
	// Value Types
	//////////////////////////////////////////////////////////////////////////

	public static boolean isVal(Type self) {
		return (self.flags() & FConst.Struct) != 0;
	}

	//////////////////////////////////////////////////////////////////////////
	// Nullable
	//////////////////////////////////////////////////////////////////////////

	public static boolean isNullable(Type self) {
		return self.isNullable();
	}

	public static Type toNonNullable(Type self) {
		return self.toNonNullable();
	}

	public static Type toNullable(Type self) {
		return self.toNullable();
	}

	//////////////////////////////////////////////////////////////////////////
	// Generics
	//////////////////////////////////////////////////////////////////////////

	/// **
	// * A generic type means that one or more of my slots contain signatures
	// * using a generic parameter (such as V or K). Fantom supports three
	/// built-in
	// * generic types: List, Map, and Func. A generic instance (such as Str[])
	// * is NOT a generic type (all of its generic parameters have been filled
	/// in).
	// * User defined generic types are not supported in Fan.
	// */
	public static boolean isGeneric(Type self) {
		return self.isGenericType();
	}

	////////////////////////////////////////////////////////////////////////////
	//// Inheritance
	////////////////////////////////////////////////////////////////////////////

	public static Type base(Type self) {
		return self.base();
	}

	public static List mixins(Type self) {
		List acc = List.make(4);
		FType ftype = self.ftype();
		for (int mixin : ftype.mixins) {
			Type t = Type.refToType(ftype.pod, mixin);
			acc.add(t);
		}
		return acc.trim().ro();
	}

	public static List inheritance(Type self) {
		java.util.HashMap<String, Type> map = new java.util.HashMap<String, Type>();
		List acc = List.make(8);

		// add myself
		map.put(self.qname(), self);
		acc.add(self);

		// add my direct inheritance inheritance
		addInheritance(self, acc, map);

		return acc.trim().ro();
	}

	private static void addInheritance(Type t, List acc, java.util.HashMap<String, Type> map) {
		if (t == null)
			return;
		Type b = base(t);
		if (b != null) {
			map.put(b.qname(), b);
			acc.add(b);
			addInheritance(b, acc, map);
		}

		List ti = mixins(t);
		for (int i = 0; i < ti.size(); ++i) {
			Type x = (Type) ti.get(i);
			if (map.get(x.qname()) == null) {
				map.put(x.qname(), x);
				acc.add(x);
			}
		}
	}

	public static boolean fits(Type self, Type type) {
		return self.fits(type);
	}

	////////////////////////////////////////////////////////////////////////////
	//// Documentation
	////////////////////////////////////////////////////////////////////////////

	public static String doc(Type self) {
		FType ftype = self.ftype();
		if (ftype == null)
			return null;
		return ftype.doc().tyeDoc();
	}

	//////////////////////////////////////////////////////////////////////////
	// Conversion
	//////////////////////////////////////////////////////////////////////////

	public static String toStr(Type self) {
		return self.signature();
	}

	// public String toLocale() { return signature(); }

	// public void encode(ObjEncoder out)
	// {
	// out.w(signature()).w("#");
	// }

	//////////////////////////////////////////////////////////////////////////
	// Reflection
	//////////////////////////////////////////////////////////////////////////

	// protected Type reflect() { return this; }

	// public void finish() {}

	/**
	 * Return if this is a JavaType which represents a Java class imported into
	 * the Fantom type system via the Java FFI.
	 */
	public static boolean isJava(Type self) {
		return self instanceof JavaType;
	}

	/**
	 * Return if the Fantom Type is represented as a Java class such as sys::Int
	 * as java.lang.Long.
	 */
	// public abstract boolean javaRepr();

	/**
	 * Get the Java class which represents this type.
	 */
	public static Class toClass(Type self) {
		return self.getJavaActualClass();
	}

}
