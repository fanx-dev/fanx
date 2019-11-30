package fan.std;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Modifier;
import java.util.Arrays;

import fan.sys.*;
import fanx.fcode.*;
import fanx.fcode.FAttrs.FFacet;
import fanx.main.*;
import fanx.util.FanUtil;

public class Method extends Slot {

	/**
	 * Constructor used by GenericType and we are given the generic method that
	 * is being parameterized.
	 */
	public Method(Type parent, String name, int flags, List facets, int lineNum, Type returns, Type inheritedReturns,
			List params, int mask) {
		super(parent, name, flags, facets, lineNum);

		this.params = params;
		this.inheritedReturns = inheritedReturns;
		this.mask = mask;
		this.func = new MethodFunc(returns);
		this.returns = returns;
	}
	
	public static Method fromFCode(FMethod f, Type parent) {
		FType ftype = parent.ftype();
		FTypeRef tref = ftype.pod.typeRef(f.ret);
		Type type = Sys.findType(tref.signature);
		
		FTypeRef tref2 = ftype.pod.typeRef(f.inheritedRet);
		Type type2 = Sys.findType(tref2.signature);
		
		List params = List.make(f.paramCount);
		
		FMethodVar[] vars = f.params();
		for (int i=0; i<f.paramCount; ++i) {
			FMethodVar var = vars[i];
			params.add(Param.fromFCode(var, ftype.pod));
		}
		
		List facets = List.make(1);
		if (f.attrs.facets != null) {
			facets.capacity(f.attrs.facets.length);
			for (FFacet facet : f.attrs.facets) {
				Facet fa = FanType.tryDecodeFacet(facet, ftype.pod);
				if (fa != null) {
					facets.add(fa);
				}
			}
		}
		
		int mask = 0;
		Method method = new Method(parent, f.name, f.flags, facets, 0, type, type2, params, mask);
		method.reflect = new java.lang.reflect.Method[(int)params.size()+1];
		return method;
	}
	
	/**
	   * Map a Java Method to a Fantom Method.
	   */
	  public static Method fromJava(java.lang.reflect.Method java)
	  {
	    Type parent   = FanUtil.toFanType(java.getDeclaringClass(), true);
	    String name   = java.getName();
	    int flags     = FanUtil.memberModifiersToFanFlags(java.getModifiers());
	    List facets = List.make(1);
	    Type ret      = FanUtil.toFanType(java.getReturnType(), true);

	    Class[] paramClasses = java.getParameterTypes();
	    List params = List.make(paramClasses.length);
	    for (int i=0; i<paramClasses.length; ++i)
	    {
	      Param param = new Param("p"+i, FanUtil.toFanType(java.getDeclaringClass(), true), 0);
	      params.add(param);
	    }

	    int mask = 0;
	    Method fan = new Method(parent, name, flags, facets, -1, ret, ret, params.ro(), mask);
	    fan.reflect = new java.lang.reflect.Method[] { java };
	    return fan;
	  }

	//////////////////////////////////////////////////////////////////////////
	// Methods
	//////////////////////////////////////////////////////////////////////////

	static Type typeof = Sys.findType("std::Method");

	public Type typeof() {
		return typeof;
	}

	public Type returns() {
		return returns;
	}

	public Type inheritedReturns() {
		return inheritedReturns;
	}

	public List params() {
		return params.ro();
	}
	
	public Func func() {
		return func;
	}

	public Func func(long arity) {
		return func;
	}

	public String signature() {
		StringBuilder s = new StringBuilder();
		s.append(returns()).append(' ').append(name).append('(');
		for (int i = 0; i < params.size(); ++i) {
			if (i > 0)
				s.append(", ");
			Param p = (Param) params.get(i);
			s.append(p.type).append(' ').append(p.name);
		}
		s.append(')');
		return s.toString();
	}

	public Object trap(String name, List args) {
		// private undocumented access
		if (name.equals("inheritedReturnType"))
			return inheritedReturns;
		else
			return super.trap(name, args);
	}

	//////////////////////////////////////////////////////////////////////////
	// Call Conveniences
	//////////////////////////////////////////////////////////////////////////

	public final Object callList(List args) {
		return func.callList(args);
	}

	public final Object callOn(Object target, List args) {
		return func.callOn(target, args);
	}

	public final Object call() {
		return func.call();
	}

	public final Object call(Object a) {
		return func.call(a);
	}

	public final Object call(Object a, Object b) {
		return func.call(a, b);
	}

	public final Object call(Object a, Object b, Object c) {
		return func.call(a, b, c);
	}

	public final Object call(Object a, Object b, Object c, Object d) {
		return func.call(a, b, c, d);
	}

	public final Object call(Object a, Object b, Object c, Object d, Object e) {
		return func.call(a, b, c, d, e);
	}

	public final Object call(Object a, Object b, Object c, Object d, Object e, Object f) {
		return func.call(a, b, c, d, e, f);
	}

	public final Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g) {
		return func.call(a, b, c, d, e, f, g);
	}

	public final Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g, Object h) {
		return func.call(a, b, c, d, e, f, g, h);
	}

	//////////////////////////////////////////////////////////////////////////
	// MethodFunc
	//////////////////////////////////////////////////////////////////////////

	class MethodFunc extends Func {
		MethodFunc(Type returns) {
			this.returns = returns;
		}

//		public Type returns() {
//			return returns;
//		}

		private final Type returns;

//		@Override
//		public long arity() {
//			if (isInstance()) return params.size()+1;
//			return params.size();
//		}

		public Method method() {
			return Method.this;
		}

		public boolean isImmutable() {
			return true;
		}
		
		public final Object callOn(Object target, List args) {
			if (isInstance()) return super.callOn(target, args);
			return callList(args);
		}

		public Object call() {
			return callWith(0, null, null, null, null, null, null, null, null);
		}

		public Object call(Object a) {
			return callWith(1, a, null, null, null, null, null, null, null);
		}

		public Object call(Object a, Object b) {
			return callWith(2, a, b, null, null, null, null, null, null);
		}

		public Object call(Object a, Object b, Object c) {
			return callWith(3, a, b, c, null, null, null, null, null);
		}

		public Object call(Object a, Object b, Object c, Object d) {
			return callWith(4, a, b, c, d, null, null, null, null);
		}

		public Object call(Object a, Object b, Object c, Object d, Object e) {
			return callWith(5, a, b, c, d, e, null, null, null);
		}

		public Object call(Object a, Object b, Object c, Object d, Object e, Object f) {
			return callWith(6, a, b, c, d, e, f, null, null);
		}

		public Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g) {
			return callWith(7, a, b, c, d, e, f, g, null);
		}

		public Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g, Object h) {
			return callWith(8, a, b, c, d, e, f, g, h);
		}
		
		private Object callWith(int argc, Object a, Object b, Object c, Object d, Object e, Object f, Object g,
				Object h) {
			
			// if parent is FFI Java class, then route to JavaType for handling
		    if (parent.isJava()) return JavaInvoker.call(Method.this, argc, a, b, c, d, e, f, g, h);
		      
			boolean isStatic = !isInstance();
			int min = minParams();
			int max = isStatic ? (int)params.size() : (int)params.size()+1;
			
			if (argc < min) {
				throw ArgErr.make("Too few arguments: " + argc);
			}
			if (argc > max) {
				//throw ArgErr.make("Too many arguments: " + argc);
				//ignore more args
				argc = max;
			}
			
			if (!isStatic) --argc;
			
			java.lang.reflect.Method jm = reflect[argc];
			if (jm == null) {
				throw ArgErr.make("arguments num err:" + argc);
			}
			//specialImpl: FanInt.abs(i)
			if (jm.getParameterCount() > argc) {
				isStatic = true;
				++argc;
			}
			
			int p = argc;
			Object[] args = new Object[p];
			
			if (isStatic) {
				switch (p) {
				case 8:
					args[7] = h;
				case 7:
					args[6] = g;
				case 6:
					args[5] = f;
				case 5:
					args[4] = e;
				case 4:
					args[3] = d;
				case 3:
					args[2] = c;
				case 2:
					args[1] = b;
				case 1:
					args[0] = a;
				}
				return invoke(null, args, jm);
			} else {
				switch (p) {
				case 7:
					args[6] = h;
				case 6:
					args[5] = g;
				case 5:
					args[4] = f;
				case 4:
					args[3] = e;
				case 3:
					args[2] = d;
				case 2:
					args[1] = c;
				case 1:
					args[0] = b;
				}
				return invoke(a, args, jm);
			}
		}
		
		public Object callList(List args) {
			boolean isStatic = !isInstance();
			if (parent.isJava()) {
				int argc = (int)args.size();
				if (!isStatic) --argc;
				Object[] jargs = new Object[argc];
				int i = 0;
				if (!isStatic) i = 1;
				for (int j=0; j<argc; ++i, ++j) {
					jargs[j] = args.get(i);
				}
				Object obj = isStatic ? null : args.get(0);
				Object res;
				try {
					res = JavaInvoker.invoke(Method.this, obj, jargs);
					return res;
				} catch (Exception e) {
					e.printStackTrace();
					throw Err.make("Cannot call '" + this + "': " + e);
				}
			}
			
			
			int min = minParams();
			int max = isStatic ? (int)params.size() : (int)params.size()+1;
			
			int argc = args == null ? 0 : (int)args.size();
			if (argc < min) {
				throw ArgErr.make("Too few arguments: " + argc);
			}
			if (argc > max) {
				//throw ArgErr.make("Too many arguments: " + argc);
				//ignore more args
				argc = max;
			}
			
			if (!isStatic) --argc;
			java.lang.reflect.Method jm = reflect[argc];
			if (jm == null) {
				throw ArgErr.make("arguments num err:" + argc);
			}
			//specialImpl: FanInt.abs(i)
			if (jm.getParameterCount() > argc) {
				isStatic = true;
				++argc;
			}
			
			Object[] jargs = new Object[argc];
			int i = 0;
			if (!isStatic) i = 1;
			for (int j=0; j<argc; ++i, ++j) {
				jargs[j] = args.get(i);
			}
			Object obj = isStatic ? null : args.get(0);
			Object res = invoke(obj, jargs, jm);
			return res;
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Reflection
	//////////////////////////////////////////////////////////////////////////

	public int minParams() {
		if (minParams < 0) {
			int min = 0;
			for (; min < params.size(); ++min)
				if (((Param) params.get(min)).hasDefault())
					break;
			if (isInstance()) ++min;
			minParams = min;
		}
		return minParams;
	}

	private boolean isInstance() {
		return (flags & (FConst.Static | FConst.Ctor)) == 0;
	}
	
	Object invoke(Object instance, Object[] args) {
		return invoke(instance, args, null);
	}

	Object invoke(Object instance, Object[] args, java.lang.reflect.Method jm) {
		try {
			if (jm == null) jm = reflect[args.length];
			if (jm == null) {
				throw Err.make("reflect methods not inited");
			}
			
			return jm.invoke(instance, args);
		} catch (IllegalArgumentException e) {
			System.err.println("call "+jm + ",("+Arrays.toString(args) +"),on:"+instance);
			throw ArgErr.make(e);
		} catch (InvocationTargetException e) {
			if (e.getCause() instanceof Err)
				throw (Err) e.getCause();
			else
				throw Err.make(e.getCause());
		} catch (Exception e) {
			if (instance == null && jm != null && !java.lang.reflect.Modifier.isStatic(jm.getModifiers()))
				throw Err.make("Cannot call method '" + this + "' with null instance");

			if (reflect == null)
				throw Err.make("Method not mapped to java.lang.reflect correctly " + qname());

			/*
			 * System.out.println("ERROR:      " + signature());
			 * System.out.println("  instance: " + instance);
			 * System.out.println("  args:     " + (args == null ? "null" :
			 * ""+args.length)); for (int i=0; args != null && i<args.length;
			 * ++i) System.out.println("    args[" + i + "] = " + args[i]); for
			 * (int i=0; i<reflect.length; ++i)
			 * System.out.println("    reflect[" + i + "] = " + reflect[i]);
			 * e.printStackTrace();
			 */

			throw Err.make("Cannot call '" + this + "': " + e);
		}
	}

	// private void fixReflect() {
	// // this code is used to fix up our reflect table which maps
	// // parameter arity to java.lang.reflect.Methods; in sys code we
	// // don't necessarily override every version of a method with default
	// // parameters in subclasses; so if a reflection table is incomplete
	// // then we fill in missing entries from the base type's method
	// try {
	//// parent.base().finish();
	// Method inherit = TypeExt.method(parent, name);
	// for (int i = 0; i < reflect.length; ++i) {
	// if (reflect[i] == null)
	// reflect[i] = inherit.reflect[i];
	// }
	// } catch (Exception e) {
	// System.out.println("ERROR Method.fixReflect " + qname);
	// e.printStackTrace();
	// }
	// }
/*
	public Object paramDef(Param param) {
		return paramDef(param, null);
	}

	public Object paramDef(Param param, Object instance) {
		if (!isStatic() && !isCtor() && instance == null)
			throw Err.make("Instance required for non-static method: " + qname());

		try {
			Class cls = parent.getJavaImplClass();
			String methodName = paramDefMethodName(this.name, param.name);
			java.lang.reflect.Method m = cls.getMethod(methodName);
			return m.invoke(instance);
		} catch (InvocationTargetException e) {
			if (e.getCause() instanceof Err)
				throw (Err) e.getCause();
			else
				throw Err.make(e.getCause());
		} catch (Exception e) {
			throw Err.make(e);
		}
	}

	public static Err makeParamDefErr() {
		return Err.make("Method param may not be reflected");
	}

	public static String paramDefMethodName(String methodName, String paramName) {
		return "pdef$" + methodName + "$" + paramName;
	}
*/
	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	private static final int GENERIC = 0x01; // is this a generic method
	static final Object[] noArgs = new Object[0];

	private MethodFunc func;
	private Type returns;
	
	private List params; // might be different from func.params is instance method
	private Type inheritedReturns; // for covariance
	private int mask;
	// Method generic;
	java.lang.reflect.Method[] reflect;
	private int minParams = -1;
	
//	boolean specialImpl = false;
}