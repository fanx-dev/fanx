package fan.reflect;

import java.io.IOException;

import fan.sys.FanType;
import fan.sys.List;
import fan.sys.UnknownSlotErr;
import fanx.fcode.FConst;
import fanx.fcode.FField;
import fanx.fcode.FMethod;
import fanx.fcode.FType;
import fanx.main.Sys;
import fanx.main.Type;

public class TypeExt {
	private static Type typeof;

	public Type typeof() {
		if (typeof == null) {
			typeof = Sys.findType("reflect::TypeExt");
		}
		return typeof;
	}

	public static Pod pod(Type type) {
		return Pod.fromFPod(type.ftype().pod);
	}

	// public static Map params(Type type) {
	// return null;
	// }
	//
	// public static Type parameterize(Type type, Map params) {
	// return null;
	// }

	public static List fields(Type type) {
		java.util.Map<String, Object> slots = getSlots(type);
		List list = List.make(Slot.typeof, slots.size());
		for (java.util.Map.Entry<String, Object> entry : slots.entrySet()) {
			if (entry.getValue() instanceof Field) {
				list.add(entry.getValue());
			}
		}
		return list;
	}

	public static List methods(Type type) {
		java.util.Map<String, Object> slots = getSlots(type);
		List list = List.make(Slot.typeof, slots.size());
		for (java.util.Map.Entry<String, Object> entry : slots.entrySet()) {
			if (entry.getValue() instanceof Method) {
				list.add(entry.getValue());
			}
		}
		return list;
	}

	public static List slots(Type type) {
		java.util.Map<String, Object> slots = getSlots(type);
		List list = List.make(Slot.typeof, slots.size());
		for (java.util.Map.Entry<String, Object> entry : slots.entrySet()) {
			list.add(entry.getValue());
		}
		return list;
	}

	public static Field field(Type type, String name, boolean checked) {
		return (Field) slot(type, name, checked);
	}

	public static Field field(Type type, String name) {
		return field(type, name, true);
	}

	public static Method method(Type type, String name, boolean checked) {
		return (Method) slot(type, name, checked);
	}

	public static Method method(Type type, String name) {
		return method(type, name, true);
	}
	
	private static void mergeSlots(java.util.Map<String, Object> out, Type base) {
		java.util.Map<String, Object> add = getSlots(base);
		for (java.util.Map.Entry<String, Object> entry : add.entrySet()) {
			out.put(entry.getKey(), entry.getValue());
		}
	}

	private static java.util.Map<String, Object> getSlots(Type type) {
		if (type.slots != null)
			return type.slots;
		java.util.Map<String, Object> slots = new java.util.HashMap<String, Object>();
		
		//get inheritance slots
		if (!type.isObj() && !FanType.isMixin(type)) {
			mergeSlots(slots, type.base());
		}
		List mixins = FanType.mixins(type);
		for (int i=0; i<mixins.size(); ++i) {
			Type t = (Type)mixins.get(i);
			mergeSlots(slots, t);
		}

		//get self type slots
		FType ftype = type.ftype();
		if (ftype != null) {
			ftype.load();
			for (FField f : ftype.fields) {
				if (f.isSynthetic()) continue;
				slots.put(f.name, Field.fromFCode(f, type));
			}
			
			for (FMethod f : ftype.methods) {
				if ((f.flags & FConst.Getter) != 0) {
					Field field = (Field)slots.get(f.name);
					field.getter = Method.fromFCode(f, type);
					continue;
				}
				if ((f.flags & FConst.Setter) != 0) {
					Field field = (Field)slots.get(f.name);
					field.setter = Method.fromFCode(f, type);
					continue;
				}
				
				if (f.isSynthetic()) continue;
				slots.put(f.name, Method.fromFCode(f, type));
			}
		}
		
		//link java reflect
		java.lang.reflect.Method[] jmths = type.getJavaClass().getMethods();
		for (java.lang.reflect.Method jmth : jmths) {
			Slot s = (Slot)slots.get(jmth.getName());
			if (s == null) continue;
			if (s instanceof Method) {
				Method mth = (Method)s;
				if (jmth.getParameterCount() < mth.reflect.length) {
					mth.reflect[jmth.getParameterCount()] = jmth;
				}
			}
			else if (s instanceof Field) {
				Field field = (Field)s;
				if (jmth.getReturnType() == void.class)
			        field.setter.reflect = new java.lang.reflect.Method[] { jmth };
			    else
			        field.getter.reflect = new java.lang.reflect.Method[] { jmth };
			}
			jmth.setAccessible(true);
		}
		
		type.slots = slots;
		return type.slots;
	}

	public static Slot slot(Type type, String name, boolean checked) {
		Slot s = (Slot) getSlots(type).get(name);
		if (s == null) {
			if (checked) {
				throw UnknownSlotErr.make(name);
			}
		}
		return s;
	}

	public static Slot slot(Type type, String name) {
		return slot(type, name, true);
	}
}
