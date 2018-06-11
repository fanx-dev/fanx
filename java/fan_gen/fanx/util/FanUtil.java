//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Oct 08  Brian Frank  Creation
//
package fanx.util;

import java.util.*;
import fanx.emit.*;
import fanx.fcode.*;
import fanx.main.ClassType;
import fanx.main.Type;
import fanx.main.Sys;

import java.lang.reflect.Modifier;

/**
 * FanUtil defines the mappings between the Fantom and Java type systems.
 */
public class FanUtil {

	/**
	 * Convert Java class to Fantom type.
	 */
	public static Type toFanType(Class cls, boolean checked) {
		// try a predefined mapping
		String name = cls.getName();
		String rname = javaToFanNameMap.get(name);
		if (rname != null) name = rname;
		
		ClassType t = (ClassType) javaToFanTypes.get(name);
		if (t != null)
			return t;

		// if class name starts with "fan."
		if (name.startsWith("fan.")) {
			int dot = name.lastIndexOf('.');
			String podName = name.substring(4, dot);
			String typeName = name.substring(dot + 1);
			String qname = podName + "::" + typeName;
			Type type = Sys.findType(qname);
			if (type == null)
				return null;
			javaToFanTypes.put(name, type);
			return type;
		}
		
		//TODO
		return null;

		// map to a FFI Java class
		// TODO
		// return Env.cur().loadJavaType(cls);
	}

	private static Map<String, String> javaToFanNameMap = new HashMap<String, String>();
	private static Map<String, Type> javaToFanTypes = new HashMap<String, Type>();
	static {
		javaToFanNameMap.put("void", "fan.sys.Void");
		javaToFanNameMap.put("boolean", "fan.sys.Bool");
		javaToFanNameMap.put("long", "fan.sys.Int");
		javaToFanNameMap.put("double", "fan.sys.Float");
		javaToFanNameMap.put("java.lang.Object", "fan.sys.Obj");
		javaToFanNameMap.put("java.lang.Boolean", "fan.sys.Bool");
		javaToFanNameMap.put("java.lang.String", "fan.sys.Str");
		javaToFanNameMap.put("java.lang.Number", "fan.sys.Nun");
		javaToFanNameMap.put("java.lang.Long", "fan.sys.Int");
		javaToFanNameMap.put("java.lang.Double", "fan.sys.Float");
		javaToFanNameMap.put(Sys.TypeClassDotName, "fan.sys.Type");

		/*
		 * javaToFanTypes.put("byte", JavaType.ByteType);
		 * javaToFanTypes.put("short", JavaType.ShortType);
		 * javaToFanTypes.put("char", JavaType.CharType);
		 * javaToFanTypes.put("int", JavaType.IntType);
		 * javaToFanTypes.put("float", JavaType.FloatType);
		 */
	}

	/**
	 * Return if the specified Java class represents an immutable type.
	 */
	public static boolean isJavaImmutable(Class cls) {
		return javaImmutables.get(cls.getName()) != null;
	}

	// map all the basic types in the JDK which are immutable
	private static HashMap<String, Boolean> javaImmutables = new HashMap<String, Boolean>();
	static {
		// java.lang
		javaImmutables.put("java.lang.Boolean", Boolean.TRUE);
		javaImmutables.put("java.lang.Byte", Boolean.TRUE);
		javaImmutables.put("java.lang.Character", Boolean.TRUE);
		javaImmutables.put("java.lang.Class", Boolean.TRUE);
		javaImmutables.put("java.lang.Double", Boolean.TRUE);
		javaImmutables.put("java.lang.Float", Boolean.TRUE);
		javaImmutables.put("java.lang.Integer", Boolean.TRUE);
		javaImmutables.put("java.lang.Long", Boolean.TRUE);
		javaImmutables.put("java.lang.Package", Boolean.TRUE);
		javaImmutables.put("java.lang.Short", Boolean.TRUE);
		javaImmutables.put("java.lang.String", Boolean.TRUE);
		// java.lang.reflect
		javaImmutables.put("java.lang.reflect.Constructor", Boolean.TRUE);
		javaImmutables.put("java.lang.reflect.Field", Boolean.TRUE);
		javaImmutables.put("java.lang.reflect.Method", Boolean.TRUE);
		// java.math
		javaImmutables.put("java.math.BigDecimal", Boolean.TRUE);
		javaImmutables.put("java.math.BigInteger", Boolean.TRUE);
		
		javaImmutables.put("fanx.main.ClassType", Boolean.TRUE);
		javaImmutables.put("fanx.main.JavaType", Boolean.TRUE);
		javaImmutables.put("fanx.main.Type", Boolean.TRUE);
	}

	/**
	 * Return if the Fantom Type is represented as a Java class such as sys::Int
	 * as java.lang.Long.
	 */
//	public static boolean isJavaRepresentation(Type t) {
//		if (t.podName().equals("sys") == false)
//			return false;
//		String name = t.name();
//		return name.equals("Obj") || name.equals("Bool") || name.equals("Str") || name.equals("Int")
//				|| name.equals("Float");
//	}

	/**
	 * Given a Fantom qname, get the Java class name: sys::Obj =>
	 * java.lang.Object foo::Bar => fan.foo.Bar
	 */
	public static String toJavaClassName(String podName, String typeName) {
		if (podName.equals("sys")) {
			switch (typeName.charAt(0)) {
			case 'B':
				if (typeName.equals("Bool"))
					return "java.lang.Boolean";
				break;
//			case 'D':
//				if (typeName.equals("Decimal"))
//					return "java.math.BigDecimal";
//				break;
			case 'F':
				if (typeName.equals("Float"))
					return "java.lang.Double";
				break;
			case 'I':
				if (typeName.equals("Int"))
					return "java.lang.Long";
				break;
			case 'N':
				if (typeName.equals("Num"))
					return "java.lang.Number";
				break;
			case 'O':
				if (typeName.equals("Obj"))
					return "java.lang.Object";
				break;
			case 'S':
				if (typeName.equals("Str"))
					return "java.lang.String";
			case 'T':
				if (typeName.equals("Type"))
					return Sys.TypeClassDotName;
				break;
			}
		}

		// if pod starts with [java] parse as FFI name
		if (podName.charAt(0) == '[')
			return ffiToJavaClass(podName, typeName, false);

		return "fan." + podName + "." + typeName;
	}

	/**
	 * Given a Fantom qname, get the Java implementation class name: sys::Obj =>
	 * fan.sys.FanObj sys::Float => fan.sys.FanFloat sys::Obj => fan.sys.FanObj
	 */
	public static String toJavaImplClassName(String podName, String typeName) {
		if (podName.equals("sys")) {
			switch (typeName.charAt(0)) {
			case 'B':
				if (typeName.equals("Bool"))
					return "fan.sys.FanBool";
				break;
//			case 'D':
//				if (typeName.equals("Decimal"))
//					return "fan.sys.FanDecimal";
//				break;
			case 'F':
				if (typeName.equals("Float"))
					return "fan.sys.FanFloat";
				break;
			case 'I':
				if (typeName.equals("Int"))
					return "fan.sys.FanInt";
				break;
			case 'N':
				if (typeName.equals("Num"))
					return "fan.sys.FanNum";
				break;
			case 'O':
				if (typeName.equals("Obj"))
					return "fan.sys.FanObj";
				break;
			case 'S':
				if (typeName.equals("Str"))
					return "fan.sys.FanStr";
			case 'T':
				if (typeName.equals("Type"))
					return "fan.sys.FanType";
				break;
			}
		}

		// if pod starts with [java] parse as FFI name
		if (podName.charAt(0) == '[')
			return ffiToJavaClass(podName, typeName, false);

		return "fan." + podName + "." + typeName;
	}
	
	public static boolean specialJavaImpl(String podName, String typeName) {
		if (podName.equals("sys")) {
			switch (typeName.charAt(0)) {
			case 'B':
				if (typeName.equals("Bool")) return true;
//			case 'D':
//				if (typeName.equals("Decimal"))
//					return "fan.sys.FanDecimal";
			case 'F':
				if (typeName.equals("Float")) return true;
			case 'I':
				if (typeName.equals("Int")) return true;
			case 'N':
				if (typeName.equals("Num")) return true;
			case 'O':
				if (typeName.equals("Obj")) return true;
			case 'S':
				if (typeName.equals("Str")) return true;
			case 'T':
				if (typeName.equals("Type")) return true;
			}
		}
		return false;
	}

	/**
	 * Given a Fantom qname, get the Java type signature: sys::Obj =>
	 * java/lang/Object foo::Bar => fan/foo/Bar
	 */
	public static String toJavaTypeSig(String podName, String typeName, boolean nullable) {
		if (podName.equals("sys")) {
			switch (typeName.charAt(0)) {
			case 'B':
				if (typeName.equals("Bool"))
					return nullable ? "java/lang/Boolean" : "Z";
				break;
//			case 'D':
//				if (typeName.equals("Decimal"))
//					return "java/math/BigDecimal";
//				break;
			case 'F':
				if (typeName.equals("Float"))
					return nullable ? "java/lang/Double" : "D";
				break;
			case 'I':
				if (typeName.equals("Int"))
					return nullable ? "java/lang/Long" : "J";
				break;
			case 'N':
				if (typeName.equals("Num"))
					return "java/lang/Number";
				break;
			case 'O':
				if (typeName.equals("Obj"))
					return "java/lang/Object";
				break;
			case 'S':
				if (typeName.equals("Str"))
					return "java/lang/String";
				break;
			case 'V':
				if (typeName.equals("Void"))
					return "V";
			case 'T':
				if (typeName.equals("Type"))
					return Sys.TypeClassName;
				break;
			}

			// generic parameters V, etc
//			if (typeName.length() == 1)
//				return "java/lang/Object";
		}

		// if pod starts with [java] parse as FFI name
		if (podName.charAt(0) == '[')
			return ffiToJavaClass(podName, typeName, true);

		return "fan/" + podName + "/" + typeName;
	}

	/**
	 * Given a FFI fan signatures such as [java]foo.bar::Baz get the Java
	 * classname. If sig is true then get as a signature otherwise as a
	 * classname: qname sig=true sig=false -------------- -------- ---------
	 * [java]::int I int [java]foo::Bar foo/Bar foo.Bar [java]foo::[Bar
	 * [Lfoo/Bar; [Lfoo/Bar; [java]fanx.interop::IntArray [I [int
	 */
	private static String ffiToJavaClass(String podName, String typeName, boolean sig) {
		// sanity check
		if (!podName.startsWith("[java]"))
			throw new UnsupportedOperationException("Invalid FFI: " + podName);

		// primitives: [java]::int
		if (podName.length() == 6) // "[java]"
		{
			if (typeName.equals("int"))
				return sig ? "I" : "int";
			if (typeName.equals("char"))
				return sig ? "C" : "char";
			if (typeName.equals("byte"))
				return sig ? "B" : "byte";
			if (typeName.equals("short"))
				return sig ? "S" : "short";
			if (typeName.equals("float"))
				return sig ? "F" : "float";
		}

		// primitives: [java]fanx.interop
		if (podName.equals("[java]fanx.interop")) {
			if (typeName.equals("BooleanArray"))
				return "[Z";
			if (typeName.equals("ByteArray"))
				return "[B";
			if (typeName.equals("ShortArray"))
				return "[S";
			if (typeName.equals("CharArray"))
				return "[C";
			if (typeName.equals("IntArray"))
				return "[I";
			if (typeName.equals("LongArray"))
				return "[J";
			if (typeName.equals("FloatArray"))
				return "[F";
			if (typeName.equals("DoubleArray"))
				return "[D";
		}

		// buffer for signature
		StringBuilder s = new StringBuilder(podName.length() + typeName.length());

		// arrays: [java]foo.bar::[Baz -> [Lfoo/bar/Baz;
		boolean isArray = typeName.charAt(0) == '[';
		if (isArray) {
			while (typeName.charAt(0) == '[') {
				s.append('[');
				typeName = typeName.substring(1);
			}
			s.append('L');
		}

		// build Java class name signature
		for (int i = 6; i < podName.length(); ++i) {
			char ch = podName.charAt(i);
			if (ch == '.')
				s.append(sig ? '/' : '.');
			else
				s.append(ch);
		}
		s.append(sig ? '/' : '.').append(typeName);
		if (isArray)
			s.append(';');
		return s.toString();
	}

	/**
	 * Given a Fantom type, get the Java type signature: fan/sys/Duration
	 */
	public static String toJavaTypeSig(FTypeRef t) {
		return toJavaTypeSig(t.podName, t.typeName, t.isNullable());
	}

	/**
	 * Given a Fantom type, get the Java member signature. Lfan/sys/Duration;
	 */
	public static String toJavaMemberSig(FTypeRef t) {
		String sig = toJavaTypeSig(t);

		// java type sig for primitives and array is member signature
		if (sig.length() == 1)
			return sig;
		if (sig.charAt(0) == '[')
			return sig;

		// Lfan/foo/Bar;
		return "L" + sig + ";";
	}

	/**
	 * Given a Fantom type, get its stack type: 'A', 'I', 'J', etc
	 */
	public static int toJavaStackType(FTypeRef t) {
		if (!t.isNullable()) {
			// TODO fix this
			if (t.podName.equals("sys")) {
				if (t.typeName.equals("Void"))
					return 'V';
				if (t.typeName.equals("Bool"))
					return 'I';
				if (t.typeName.equals("Int"))
					return 'J';
				if (t.typeName.equals("Float"))
					return 'D';
			}
			if (t.podName.startsWith("[java]")) {
				// FFI primitives
				if (t.typeName.equals("byte"))
					return 'I';
				if (t.typeName.equals("char"))
					return 'I';
				if (t.typeName.equals("short"))
					return 'I';
				if (t.typeName.equals("int"))
					return 'I';
				if (t.typeName.equals("float"))
					return 'F';

				// fail-safe
				if (t.typeName.equals("long"))
					return 'L';
				if (t.typeName.equals("boolean"))
					return 'F';
				if (t.typeName.equals("double"))
					return 'D';
			}
		}
		return 'A';
	}

	/**
	 * Given a Java type signature, return the implementation class signature
	 * for methods and fields: java/lang/Object => fan/sys/FanObj java/lang/Long
	 * => fan/sys/FanInt Anything returns itself.
	 */
	public static String toJavaImplSig(String jsig) {
		if (jsig.length() == 1) {
			switch (jsig.charAt(0)) {
			case 'Z':
				return "fan/sys/FanBool";
			case 'J':
				return "fan/sys/FanInt";
			case 'D':
				return "fan/sys/FanFloat";
			default:
				throw new IllegalStateException(jsig);
			}
		}

		if (jsig.charAt(0) == 'j') {
			if (jsig.equals("java/lang/Object"))
				return "fan/sys/FanObj";
			if (jsig.equals("java/lang/Boolean"))
				return "fan/sys/FanBool";
			if (jsig.equals("java/lang/String"))
				return "fan/sys/FanStr";
			if (jsig.equals("java/lang/Long"))
				return "fan/sys/FanInt";
			if (jsig.equals("java/lang/Double"))
				return "fan/sys/FanFloat";
			if (jsig.equals("java/lang/Number"))
				return "fan/sys/FanNum";
		}
		if (jsig.length() > 4 &&  jsig.charAt(3) == 'x') {
			if (jsig.equals(Sys.TypeClassName))
				return "fan/sys/FanType";
//			if (jsig.equals("java/math/BigDecimal"))
//				return "fan/sys/FanDecimal";
		}
		return jsig;
	}

	/**
	 * Map Java class modifiers to Fantom flags.
	 */
	public static int classModifiersToFanFlags(int m) {
		int flags = 0;

		if (Modifier.isAbstract(m))
			flags |= FConst.Abstract;
		if (Modifier.isFinal(m))
			flags |= FConst.Final;
		if (Modifier.isInterface(m))
			flags |= FConst.Mixin;

		if (Modifier.isPublic(m))
			flags |= FConst.Public;
		else
			flags |= FConst.Internal;

		return flags;
	}

	/**
	 * Map Java field/method modifiers to Fantom flags.
	 */
	public static int memberModifiersToFanFlags(int m) {
		int flags = 0;

		if (Modifier.isAbstract(m))
			flags |= FConst.Abstract;
		if (Modifier.isStatic(m))
			flags |= FConst.Static;

		if (Modifier.isFinal(m))
			flags |= FConst.Final;
		else
			flags |= FConst.Virtual;

		if (Modifier.isPublic(m))
			flags |= FConst.Public;
		else if (Modifier.isPrivate(m))
			flags |= FConst.Private;
		else if (Modifier.isProtected(m))
			flags |= FConst.Protected;
		else
			flags |= FConst.Internal;

		// reflection API doesn't have method for ACC_ENUM
		if ((m & EmitConst.ENUM) != 0)
			flags |= FConst.Enum;

		return flags;
	}

	public static String errfanToJava(String jtype) {
		if (jtype.equals("fan/sys/NullErr"))
			return "java/lang/NullPointerException";
		if (jtype.equals("fan/sys/CastErr"))
			return "java/lang/ClassCastException";
		if (jtype.equals("fan/sys/IndexErr"))
			return "java/lang/IndexOutOfBoundsException";
		if (jtype.equals("fan/sys/ArgErr"))
			return "java/lang/IllegalArgumentException";
		if (jtype.equals("fan/sys/IOErr"))
			return "java/io/IOException";
		if (jtype.equals("fan/sys/InterruptedErr"))
			return "java/lang/InterruptedException";
		if (jtype.equals("fan/sys/UnsupportedErr"))
			return "java/lang/UnsupportedOperationException";
		return null;
	}

}