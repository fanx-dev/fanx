package reflect;

import fanx.fcode.FSlot;
import fanx.main.*;
import fan.sys.*;
import fan.std.*;

public class TypeExt {
	private static Type typeof;

	public Type typeof() {
		if (typeof == null) {
			typeof = Sys.findType("reflect::TypeExt");
		}
		return typeof;
	}

	public static Pod pod(Type type) {
		return null;
	}

	public static Map params(Type type) {
		return null;
	}

	public static Type parameterize(Type type, Map params) {
		return null;
	}

	public static Field[] fields(Type type) {
		return null;
	}

	public static Method[] methods(Type type) {
		return null;
	}

	public static Slot[] slots(Type type) {
		return null;
	}

	public static Field field(Type type, String name, boolean checked) {
		return null;
	}

	public static Field field(Type type, String name) {
		return field(type, name, true);
	}

	public static Method method(Type type, String name, boolean checked) {
		return null;
	}

	public static Method method(Type type, String name) {
		return method(type, name, true);
	}

	public static Slot slot(Type type, String name, boolean checked) {
		if (type instanceof ClassType) {
			ClassType c = (ClassType) type;
			FSlot fslot = c.slot(name);
		}
		return null;
	}

	public static Slot slot(Type type, String name) {
		return slot(type, name);
	}
}
