package fan.reflect;

import java.lang.reflect.InvocationTargetException;

import fan.sys.*;
import fanx.fcode.*;
import fanx.main.*;

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
	}
	
	public static Method fromFCode(FMethod f, Type parent) {
		//TODO
		List facets = List.make(Sys.findType("sys::Facet"), 1);
		FType ftype = parent.ftype();
		FTypeRef tref = ftype.pod.typeRef(f.ret);
		Type type = Sys.findType(tref.signature);
		
		FTypeRef tref2 = ftype.pod.typeRef(f.inheritedRet);
		Type type2 = Sys.findType(tref2.signature);
		
		List params = List.make(Param.typeof, f.paramCount);
		
		FMethodVar[] vars = f.params();
		for (int i=0; i<f.paramCount; ++i) {
			FMethodVar var = vars[i];
			params.add(Param.fromFCode(var, ftype.pod));
		}
		
		int mask = 0;
		Method method = new Method(parent, f.name, ftype.flags, facets, 0, type, type2, params, mask);
		method.reflect = new java.lang.reflect.Method[(int)params.size()+1];
		return method;
	}

	//////////////////////////////////////////////////////////////////////////
	// Methods
	//////////////////////////////////////////////////////////////////////////

	static Type typeof = Sys.findType("reflect::Method");

	public Type typeof() {
		return typeof;
	}

	public Type returns() {
		return func.returns();
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
			this.fparams = Method.this.params;
		}

		public Type returns() {
			return returns;
		}

		private final Type returns;
		private List fparams;

		public long arity() {
			return params().size();
		}

		public List params() {
			return fparams;
		}

		public Method method() {
			return Method.this;
		}

		public boolean isImmutable() {
			return true;
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
			boolean isStatic = isStatic() || isCtor();
			int min = minParams();
			int max = (int)fparams.size();
			if (!isStatic) {
				--argc;
			}
			
			if (argc < min) {
				throw ArgErr.make("Too few arguments: " + argc);
			}
			if (argc > max) {
				throw ArgErr.make("Too many arguments: " + argc);
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
				return invoke(null, args);
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
				return invoke(a, args);
			}
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
			minParams = min;
		}
		return minParams;
	}

	private boolean isInstance() {
		return (flags & (FConst.Static | FConst.Ctor)) == 0;
	}

	public Object invoke(Object instance, Object[] args) {

		java.lang.reflect.Method jm = null;
		try {
			// // if parent is FFI Java class, then route to JavaType for
			// handling
			// if (parent.isJava())
			// return JavaType.invoke(this, instance, args);

			// zero index is full signature up to using max defaults
//			int index = (int) params.size() - args.length;
//			if (isInstance())
//				index++;
//			if (index < 0)
//				index = 0;
			int index = args.length;

			// route to Java reflection
			jm = reflect[index];
			if (jm == null) {
				// fixReflect();
				// jm = reflect[index];
				throw Err.make("reflect methods not inited");
			}
			return jm.invoke(instance, args);
		} catch (IllegalArgumentException e) {
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

	public Object paramDef(Param param) {
		return paramDef(param, null);
	}

	public Object paramDef(Param param, Object instance) {
		if (!isStatic() && !isCtor() && instance == null)
			throw Err.make("Instance required for non-static method: " + qname());

		try {
			Class cls = parent.getJavaClass();
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

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	static final int GENERIC = 0x01; // is this a generic method
	static final Object[] noArgs = new Object[0];

	MethodFunc func;
	List params; // might be different from func.params is instance method
	Type inheritedReturns; // for covariance
	int mask;
	// Method generic;
	java.lang.reflect.Method[] reflect;
	private int minParams = -1;

}