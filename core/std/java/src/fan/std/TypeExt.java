package fan.std;

import java.lang.reflect.Modifier;

import fan.sys.ArgErr;
import fan.sys.Err;
import fan.sys.Facet;
import fan.sys.FacetMeta;
import fan.sys.FanType;
import fan.sys.IOErr;
import fan.sys.List;
import fan.sys.UnknownFacetErr;
import fan.sys.UnknownSlotErr;
import fan.sys.UnsupportedErr;
import fanx.fcode.FAttrs.FFacet;
import fanx.fcode.FConst;
import fanx.fcode.FField;
import fanx.fcode.FMethod;
import fanx.fcode.FPod;
import fanx.fcode.FType;
import fanx.fcode.FTypeRef;
import fanx.main.Sys;
import fanx.main.Type;

public class TypeExt {

	//////////////////////////////////////////////////////////////////////////
	// Make
	//////////////////////////////////////////////////////////////////////////


	public static Object make(Type self) {
		return make(self, null);
	}

	public static Object make(Type self, List args) {
		
		if (self.isJava()) {
			// right now we don't support constructors with arguments
		    if (args != null && args.sz() > 0)
		      throw UnsupportedErr.make("Cannot call make with args on Java type: " + self);
	
		    // route to Class.newInstance
		    try { return self.getJavaActualClass().newInstance(); }
		    catch (Exception e) { throw Err.make(e); }
		}
		
		Method m = method(self, "make", false);
		if (m != null && m.isPublic()) {
			try {
				return m.callList(args);
			}
			catch (ArgErr e) {
			}
		}
		
		//fallback to defVal
		if (args == null || args.size() == 0) {
			Field f = field(self, "defVal", false);
			if (f != null && f.isStatic()) {
				return f.get();
			}
		}

		throw Err.make("Type missing 'make' or 'defVal' slots: " + self);
	}

	//
	/// **
	// * Given a list of objects, compute the most specific type which they all
	// * share,or at worst return sys::Obj?. This method does not take into
	// * account interfaces, only extends class inheritance.
	// */
	// public static Type common(Object[] objs, int n)
	// {
	// if (objs.length == 0) return Sys.ObjType.toNullable();
	// boolean nullable = false;
	// Type best = null;
	// for (int i=0; i<n; ++i)
	// {
	// Object obj = objs[i];
	// if (obj == null) { nullable = true; continue; }
	// Type t = typeof(obj);
	// if (best == null) { best = t; continue; }
	// while (!t.is(best))
	// {
	// best = best.base();
	// if (best == null) return nullable ? Sys.ObjType.toNullable() :
	// Sys.ObjType;
	// }
	// }
	// if (best == null) best = Sys.ObjType;
	// return nullable ? best.toNullable() : best;
	// }

	//////////////////////////////////////////////////////////////////////////
	// Facets
	//////////////////////////////////////////////////////////////////////////

	public static List facets(Type self) {
		if (self.factesList == null) {
			
			java.util.Map<Type, Object> facets = getFacets(self);
			List list = List.make(facets.size());
			for (java.util.Map.Entry<Type, Object> e : facets.entrySet()) {
				Facet f = (Facet)e.getValue();
				list.add(f);
			}
			self.factesList = list.toImmutable();
		}
		List list = (List)self.factesList;
		return list;
	}

	public static Facet facet(Type self, Type t) {
		return facet(self, t, true);
	}
	
	private static java.util.Map<Type, Object> getFacets(Type self) {
		if (self.factesMap == null) {
			java.util.Map<Type, Object> map = new java.util.HashMap<Type, Object>();
			
			FType ftype = self.ftype();
			if (ftype != null) {
				if (ftype.attrs == null) {
					ftype.load();
				}
				if (ftype.attrs.facets != null) {
					for (FFacet facet : ftype.attrs.facets) {
						Facet f = tryDecodeFacet(facet, ftype.pod);
						if (f != null) {
							map.put(FanType.of(f), f);
						}
					}
				}
			}
			
			// get inheritance slots
			if (!self.isObj() && !FanType.isMixin(self)) {
				mergeFacets(self.base(), map);
			}
			List mixins = FanType.mixins(self);
			for (int i = 0; i < mixins.size(); ++i) {
				Type t = (Type) mixins.get(i);
				mergeFacets(t, map);
			}
			
			self.factesMap = map;
		}
		return self.factesMap;
	}

	private static void mergeFacets(Type self, java.util.Map<Type, Object> map) {
		java.util.Map<Type, Object> ps = getFacets(self);
		for (java.util.Map.Entry<Type, Object> e : ps.entrySet()) {
			Type k = e.getKey();
			if (map.containsKey(k)) continue;
			Facet f = (Facet)e.getValue();
			FacetMeta meta = (FacetMeta) TypeExt.facet(k, Sys.findType("sys::FacetMeta"), false);
			if (meta == null || !meta.inherited) {
				continue;
			}
			map.put(k, f);
		}
	}
	
	static Facet tryDecodeFacet(FFacet facet, FPod pod) {
		try
	    {
			Type type = Sys.getTypeByRefId(pod, facet.type);
			if (type.isJava()) return null;
			
			// if no string use make/defVal
			if (facet.val.length() == 0) {
				return (Facet)TypeExt.make(type);
			}
			
			// decode using normal Fantom serialization
		    return (Facet)ObjDecoder.decode(facet.val);
	    }
		catch (Throwable e)
	    {
		  FTypeRef tr = pod.typeRef(facet.type);
		  String typeName = tr.podName + "::" + tr.typeName;
	      String msg = "ERROR: Cannot decode facet " + typeName + ": " + facet.val;
	      System.err.println(msg);
	      e.printStackTrace();
	      throw IOErr.make(msg);
	    }
	}

	public static Facet facet(Type self, Type t, boolean checked) {
		java.util.Map<Type, Object> facets = getFacets(self);
		Facet f = (Facet) facets.get(t);
		if (f == null && checked)
			throw UnknownFacetErr.make(t.qname());
		return f;
	}

	public static boolean hasFacet(Type self, Type t) {
		return facet(self, t, false) != null;
	}

	////////////////////////////////////////////////////////////////////////////
	//// Documentation
	////////////////////////////////////////////////////////////////////////////

	public static String doc(Type self) {
		return self.doc(null);
	}

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	// static final boolean Debug = false;
	// static Object noParams;

	// Type listOf; // cached value of toListOf()
	// List emptyList; // cached value of emptyList()

	private static Type typeof;

	public static Type typeof() {
		if (typeof == null) {
			typeof = Sys.findType("std::TypeExt");
		}
		return typeof;
	}

	public static Pod pod(Type type) {
		if (type.ftype() == null) return null;
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
		List list = List.make(slots.size());
		for (java.util.Map.Entry<String, Object> entry : slots.entrySet()) {
			if (entry.getValue() instanceof Field) {
				Slot slot = (Slot)entry.getValue();
				if (slot.isPrivate() || slot.isInternal() || slot.isSynthetic()) {
					continue;
				}
				list.add(entry.getValue());
			}
		}
		list = (List)list.ro();
		return list;
	}

	public static List methods(Type type) {
		java.util.Map<String, Object> slots = getSlots(type);
		List list = List.make(slots.size());
		for (java.util.Map.Entry<String, Object> entry : slots.entrySet()) {
			if (entry.getValue() instanceof Method) {
				Slot slot = (Slot)entry.getValue();
				if (slot.isPrivate() || slot.isInternal() || slot.isSynthetic()) {
					continue;
				}
				list.add(entry.getValue());
			}
		}
		list = (List)list.ro();
		return list;
	}

	public static List slots(Type type) {
		java.util.Map<String, Object> slots = getSlots(type);
		List list = List.make(slots.size());
		for (java.util.Map.Entry<String, Object> entry : slots.entrySet()) {
			Slot slot = (Slot)entry.getValue();
			if (slot.isPrivate() || slot.isInternal() || slot.isSynthetic()) {
				continue;
			}
			list.add(slot);
		}
		list = (List)list.ro();
		return list;
	}

	public static Field field(Type type, String name, boolean checked) {
		return (Field) slot(type, name, checked);
	}

	public static Field field(Type type, String name) {
		return field(type, name, true);
	}

	public static Method method(Type type, String name, boolean checked) {
		Slot s = slot(type, name, checked);
		if (s instanceof Field)
	    {
	      Field f = (Field)s;
	      if (f.overload != null) return f.overload;
	    }
		return (Method) s;
	}

	public static Method method(Type type, String name) {
		return method(type, name, true);
	}

	private static void mergeSlots(java.util.Map<String, Object> out, Type base) {
		java.util.Map<String, Object> add = getSlots(base);
		for (java.util.Map.Entry<String, Object> entry : add.entrySet()) {
			Slot slot = (Slot)entry.getValue();
			
			if (slot.isStatic() || slot.isCtor()) continue;
			
			String name = entry.getKey();
			Slot oldSlot = (Slot)out.get(name);
			if (oldSlot == null) {
				out.put(name, entry.getValue());
				continue;
			}
			
			if (base.isObj()) continue;
			if (slot.isAbstract() && !oldSlot.isAbstract()) {
				continue;
			}
			
			if ((slot.flags & (FConst.Getter|FConst.Setter)) != 0) {
				if (oldSlot instanceof Field) {
					Field field = (Field)oldSlot;
					if ((slot.flags & FConst.Getter) != 0)
			          field.getter = (Method)slot;
			        else
			          field.setter = (Method)slot; 
					continue;
				}
			}
			out.put(name, slot);
		}
	}

	private static java.util.Map<String, Object> getSlots(Type type) {
		if (type.slots != null)
			return type.slots;
		java.util.Map<String, Object> slots = new java.util.LinkedHashMap<String, Object>();

		// get inheritance slots
		if (!type.isObj() && !FanType.isMixin(type)) {
			mergeSlots(slots, type.base());
		}
		List mixins = FanType.mixins(type);
		for (int i = 0; i < mixins.size(); ++i) {
			Type t = (Type) mixins.get(i);
			mergeSlots(slots, t);
		}

		// get self type slots
		FType ftype = type.ftype();
		if (ftype != null) {
			ftype.load();
			for (FField f : ftype.fields) {
				slots.put(f.name, Field.fromFCode(f, type));
			}

			for (FMethod f : ftype.methods) {
				if ((f.flags & FConst.Getter) != 0) {
					Field field = (Field) slots.get(f.name);
					field.getter = Method.fromFCode(f, type);
					continue;
				}
				if ((f.flags & FConst.Setter) != 0) {
					Field field = (Field) slots.get(f.name);
					field.setter = Method.fromFCode(f, type);
					continue;
				}

				slots.put(f.name, Method.fromFCode(f, type));
			}
		
			// link java reflect
			Class<?> jclz = type.getJavaImplClass();
			Class<?> aclz = type.getJavaActualClass();
			boolean specialImpl = jclz != aclz;
			
			java.lang.reflect.Method[] jmths = jclz.getDeclaredMethods();
			for (java.lang.reflect.Method jmth : jmths) {
				linkMethod(type, slots, specialImpl, jmth, false);
			}
			
			//bind mixin imple
			if (jclz.isInterface()) {
				try {
					Class<?> clz = Class.forName(jclz.getName()+"$");
					java.lang.reflect.Method[] jmths2 = clz.getDeclaredMethods();
					for (java.lang.reflect.Method jmth : jmths2) {
						linkMethod(type, slots, true, jmth, true);
					}
				} catch (ClassNotFoundException e) {
					e.printStackTrace();
				}
			}
		}
		else {
			// reflect Java members
		    java.lang.reflect.Field[] jfields = type.getJavaActualClass().getFields();
		    java.lang.reflect.Method[] jmethods = type.getJavaActualClass().getMethods();
		    // set all the Java members accessible for reflection
		    try
		    {
		      for (int i=0; i<jfields.length; ++i) jfields[i].setAccessible(true);
		      for (int i=0; i<jmethods.length; ++i) jmethods[i].setAccessible(true);
		    }
		    catch (Exception e)
		    {
		      System.out.println("ERROR: " + type + ".initSlots setAccessible: " + e);
		    }
		    
		    // map the fields
		    for (int i=0; i<jfields.length; ++i)
		    {
		      Field f = Field.fromJava(jfields[i]);
		      slots.put(f.name, f);
		    }
		    
		    // map the methods
		    for (int i=0; i<jmethods.length; ++i)
		    {
		      // check if we already have a slot by this name
		      java.lang.reflect.Method j = jmethods[i];
		      Method m = Method.fromJava(j);
		      
		      Slot existing = (Slot)slots.get(j.getName());

		      // if this method overloads a field
		      if (existing instanceof Field)
		      {
		        // if this is the first method overload over
		        // the field then create a link via Field.overload
		        Field x = (Field)existing;
		        if (x.overload == null)
		        {
		          x.overload = m;
		          continue;
		        }

		        // otherwise set existing to first method and fall-thru to next check
		        existing = x.overload;
		      }

		      // if this method overloads another method then all
		      // we do is add this version to our Method.reflect
		      if (existing instanceof Method)
		      {
		        Method x = (Method)existing;
		        java.lang.reflect.Method [] temp = new java.lang.reflect.Method[x.reflect.length+1];
		        System.arraycopy(x.reflect, 0, temp, 0, x.reflect.length);
		        temp[x.reflect.length] = j;
		        x.reflect = temp;
		        continue;
		      }
		      
		      slots.put(m.name, m);
		    }
		}

		type.slots = slots;
		return type.slots;
	}

	private static void linkMethod(Type type, java.util.Map<String, Object> slots, boolean specialImpl,
			java.lang.reflect.Method jmth, boolean onlyStatic) {
		Slot s = (Slot) slots.get(jmth.getName());
		if (s == null)
			return;
		
		//already inited in parent class
		if (s.parent != type) {
			return;
		}
		
		if (onlyStatic) {
			if (!s.isStatic()) {
				return;
			}
		}
		
		jmth.setAccessible(true);
		
		if (s instanceof Method) {
			Method mth = (Method) s;
			int paramCount = jmth.getParameterCount();
			boolean isStatic = s.isStatic() || s.isCtor();
			if (specialImpl && !isStatic) {
				//specialImpl always is static
				if ((jmth.getModifiers() & (Modifier.STATIC)) == 0)
					return;
				--paramCount;
			}
			
			if (paramCount < mth.reflect.length) {
				mth.reflect[paramCount] = jmth;
			}
		} else if (s instanceof Field) {
			Field field = (Field) s;
			if (jmth.getReturnType() == void.class && jmth.getParameterCount() == 1) {
				if (field.setter != null)
					field.setter.reflect[1] = jmth;
			}
			else if (jmth.getParameterCount() == 0) {
				if (field.getter != null)
					field.getter.reflect[0] = jmth;
			}
		}
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
