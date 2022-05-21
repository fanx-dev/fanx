package fan.std;

import java.lang.reflect.Modifier;

import fan.sys.Err;
import fan.sys.Facet;
import fan.sys.FacetMeta;
import fan.sys.FanObj;
import fan.sys.IOErr;
import fan.sys.List;
import fan.sys.UnknownFacetErr;
import fan.sys.UnknownSlotErr;
import fan.sys.UnsupportedErr;
import fanx.fcode.FConst;
import fanx.fcode.FField;
import fanx.fcode.FMethod;
import fanx.fcode.FPod;
import fanx.fcode.FType;
import fanx.fcode.FTypeRef;
import fanx.fcode.FAttrs.FFacet;
import fanx.main.JavaType;
import fanx.main.NullableType;
import fanx.main.ParameterizedType;
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
		  int numArgs = args == null ? 0 : (int)args.size();
	      List params = m.params();
	      if ((numArgs == params.sz()) ||
	          (numArgs < params.sz() && ((Param)params.get(numArgs)).hasDefault())) {
	    	  return m.callList(args);
	      }
		}
		
		//fallback to defVal
		if (args == null || args.size() == 0) {
			Slot f = slot(self, "defVal", false);
			if (f != null && f.isStatic()) {
				if (f instanceof Field) return ((Field)f).get();
				return ((Method)f).call();
			}
		}

		throw Err.make("Type missing 'make' or 'defVal' slots: " + self + ", method:" + m);
	}

	//////////////////////////////////////////////////////////////////////////
	// Naming
	//////////////////////////////////////////////////////////////////////////

	public final static Type type = Sys.findType("std::Type");

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
	
	static Object preTrap(Type self, String name, List args) {
		// private undocumented access
		if (name.equals("flags"))
			return Long.valueOf(flags(self));
		if (name.equals("toClass"))
			return toClass(self);
		if (name.equals("lineNumber")) { return Long.valueOf(self.lineNumber()); }
		if (name.equals("sourceFile")) { return self.sourceFile(); }
		return null;
	}

	public static Object trap(Type self, String name, List args) {
		Object r = preTrap(self, name, args);
		if (r != null) return r;
		
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
		return self.isGeneric();
	}
	
	public static boolean isParameterized(Type self) {
		return self.isParameterized();
	}

	////////////////////////////////////////////////////////////////////////////
	//// Inheritance
	////////////////////////////////////////////////////////////////////////////

	public static Type base(Type self) {
		return self.base();
	}

	public static List mixins(Type self) {
		List acc = List.make(4);
		for (Type t : self.mixins()) {
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
		return self.doc(null);
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

	public static List emptyList(Type type) {
		if (type.emptyList == null) {
			type.emptyList = List.make(0).toImmutable();
		}
		return (List)type.emptyList;
	}

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
		synchronized(self) {
			if (self instanceof NullableType) {
				return getFacets(((NullableType)self).root);
			}
			if (self instanceof ParameterizedType) {
				return getFacets(((ParameterizedType)self).root);
			}
			
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
	}

	private static void mergeFacets(Type self, java.util.Map<Type, Object> map) {
		//这里会引起递归循环，所以不再继承Obj的facets
		if (self.isObj()) return;
		
		java.util.Map<Type, Object> ps = getFacets(self);
		for (java.util.Map.Entry<Type, Object> e : ps.entrySet()) {
			Type k = e.getKey();
			if (map.containsKey(k)) continue;
			Facet f = (Facet)e.getValue();
			FacetMeta meta = (FacetMeta) FanType.facet(k, Sys.findType("sys::FacetMeta"), false);
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
				return (Facet)FanType.make(type);
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
			typeof = Sys.findType("std::Type");
		}
		return typeof;
	}
	
	public static Type typeof(Object obj) {
		return FanObj.typeof(obj);
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

			if ((slot.flags & FConst.Overload) != 0) {
				continue;
			}
			out.put(name, slot);
		}
	}

	private static java.util.Map<String, Object> getSlots(Type type) {
		synchronized(type) {
			if (type instanceof NullableType) {
				return getSlots(((NullableType)type).root);
			}
			if (type instanceof ParameterizedType) {
				return getSlots(((ParameterizedType)type).root);
			}
			
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
					if (ftype.isNative() && (f.flags & FConst.Private) != 0) {
						continue;
					}
					slots.put(f.name, Field.fromFCode(f, type));
				}

				for (FMethod f : ftype.methods) {
					if (ftype.isNative() && (f.flags & FConst.Private) != 0) {
						continue;
					}
					
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
					if ((f.flags & FConst.Overload) != 0) {
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
			    java.lang.reflect.Field[] jfields = type.getJavaActualClass().getDeclaredFields();
			    java.lang.reflect.Method[] jmethods = type.getJavaActualClass().getDeclaredMethods();
			    
			    // map the fields
			    for (int i=0; i<jfields.length; ++i)
			    {
			      if ((jfields[i].getModifiers() & Modifier.PRIVATE) != 0) continue;
			      Field f = Field.fromJava(jfields[i]);
			      slots.put(f.name, f);
			    }
			    
			    // map the methods
			    for (int i=0; i<jmethods.length; ++i)
			    {
			      // check if we already have a slot by this name
			      java.lang.reflect.Method j = jmethods[i];
			      if ((j.getModifiers() & Modifier.PRIVATE) != 0) continue;
			      
			      try {
				    	j.setAccessible(true);
				    } catch (Throwable e) {
				    }
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

	public static boolean isImmutable(Type type) {
    return true;
  }

  public static Object toImmutable(Type type) {
    return type;
  }
	
}
