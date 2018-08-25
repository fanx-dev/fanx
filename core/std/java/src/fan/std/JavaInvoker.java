package fan.std;

import fan.sys.ArgErr;
import fan.sys.Err;
import fan.sys.List;
import fanx.interop.Interop;
import fanx.util.FanUtil;

public class JavaInvoker {

	  /**
	   * Trap for Field.get against Java type.
	   */
	  static Object get(Field f, Object instance)
	    throws Exception
	  {
	    java.lang.reflect.Field j = f.reflect;
	    Class t = j.getType();
	    if (t.isPrimitive())
	    {
	      if (t == int.class)   return Long.valueOf(j.getLong(instance));
	      if (t == byte.class)  return Long.valueOf(j.getLong(instance));
	      if (t == short.class) return Long.valueOf(j.getLong(instance));
	      if (t == char.class)  return Long.valueOf(j.getLong(instance));
	      if (t == float.class) return Double.valueOf(j.getDouble(instance));
	    }
	    return coerceFromJava(j.get(instance));
	  }

	  /**
	   * Trap for Field.set against Java type.
	   */
	  static void set(Field f, Object instance, Object val)
	    throws Exception
	  {
	    java.lang.reflect.Field j = f.reflect;
	    Class t = j.getType();
	    if (t.isPrimitive())
	    {
	      if (t == int.class)   { j.setInt(instance,   ((Number)val).intValue()); return; }
	      if (t == byte.class)  { j.setByte(instance,  ((Number)val).byteValue()); return; }
	      if (t == short.class) { j.setShort(instance, ((Number)val).shortValue()); return; }
	      if (t == char.class)  { j.setChar(instance,  (char)((Number)val).intValue()); return; }
	      if (t == float.class) { j.setFloat(instance, ((Number)val).floatValue()); return; }
	    }
	    j.set(instance, coerceToJava(val, t));
	  }
	  
	  static Object call(Method m, int argc, Object a, Object b, Object c, Object d, Object e, Object f, Object g,
				Object h) {
		  Object instance = null;
		  boolean isStatic = m.isStatic() || m.isCtor();
		  if (!isStatic) {
			  instance = a;
			  argc--;
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
			}
			
		  try {
			Object res = invoke(m, instance, args);
			return res;
		} catch (Exception e1) {
			System.out.println("call: "+m.qname() + "; " + argc + "," + a + "," + b + "," + c);
			throw Err.make(e1);
		}
	  }

	  /**
	   * Trap for Method.invoke against Java type.
	   */
	  static Object invoke(Method m, Object instance, Object[] args)
	    throws Exception
	  {
	    // resolve the method to use with given arguments
	    java.lang.reflect.Method j = resolve(m, args);

	    // coerce the arguments
	    Class[] params = j.getParameterTypes();
	    for (int i=0; i<args.length; ++i)
	      args[i] = coerceToJava(args[i], params[i]);

	    // invoke the method via reflection and coerce result back to Fan
	    return coerceFromJava(j.invoke(instance, args));
	  }

	  /**
	   * Given a set of arguments try to resolve the best method to
	   * use for reflection.  The overloaded methods are stored in the
	   * Method.reflect array.
	   */
	  static java.lang.reflect.Method resolve(Method m, Object[] args)
	  {
	    // if only one method then this is easy; defer argument
	    // checking until we actually try to invoke it
	    java.lang.reflect.Method[] reflect = m.reflect;
	    if (reflect.length == 1) return reflect[0];

	    // find best match
	    java.lang.reflect.Method best = null;
	    for (int i=0; i<reflect.length; ++i)
	    {
	      java.lang.reflect.Method x = reflect[i];
	      Class[] params = x.getParameterTypes();
	      if (!argsMatchParams(args, params)) continue;
	      if (best == null) { best = x; continue; }
	      if (isMoreSpecific(best, x)) continue;
	      if (isMoreSpecific(x, best)) { best = x; continue; }
	      throw ArgErr.make("Ambiguous method call '" + m.name + "'");
	    }
	    if (best != null) return best;

	    // no matches
	    throw ArgErr.make("No matching method '" + m.name + "' for arguments");
	  }

	  /**
	   * Return if given arguments can be used against the specified
	   * parameter types.  We have to take into account that we might
	   * coercing the arguments from their Fantom represention to Java.
	   */
	  static boolean argsMatchParams(Object[] args, Class[] params)
	  {
	    if (args.length != params.length) return false;
	    for (int i=0; i<args.length; ++i)
	      if (!argMatchesParam(args[i], params[i])) return false;
	    return true;
	  }

	  /**
	   * Return if given argument can be used against the specified
	   * parameter type.  We have to take into account that we might
	   * coercing the arguments from their Fantom represention to Java.
	   */
	  static boolean argMatchesParam(Object arg, Class param)
	  {
	    // do simple instance of check
	    if (param.isInstance(arg)) return true;

	    // check implicit primitive coercions
	    if (param.isPrimitive())
	    {
	      // its either boolean, char/numeric
	      if (param == boolean.class) return arg instanceof Boolean;
	      return arg instanceof Number;
	    }

	    // check implicit array coercions
	    if (param.isArray())
	    {
	      Class ct = param.getComponentType();
	      if (ct.isPrimitive()) return false;
	      return arg instanceof List;
	    }

	    // no coersion to match
	    return false;
	  }

	  /**
	   * Given a two of overloaed methods find the most specific method
	   * according to Java Language Specification 15.11.2.2.  The "informal
	   * intuition" rule is that a method is more specific than another
	   * if the first could be could be passed onto the second one.
	   */
	  static boolean isMoreSpecific(java.lang.reflect.Method a, java.lang.reflect.Method b)
	  {
	    Class[] ap = a.getParameterTypes();
	    Class[] bp = b.getParameterTypes();
	    for (int i=0; i<ap.length; ++i)
	      if (!bp[i].isAssignableFrom(ap[i])) return false;
	    return true;
	  }

	  /**
	   * Coerce the specified Fantom representation to the Java class.
	   */
	  static Object coerceToJava(Object val, Class expected)
	  {
	    if (expected == int.class)   return Integer.valueOf(((Number)val).intValue());
	    if (expected == byte.class)  return Byte.valueOf(((Number)val).byteValue());
	    if (expected == short.class) return Short.valueOf(((Number)val).shortValue());
	    if (expected == char.class)  return Character.valueOf((char)((Number)val).intValue());
	    if (expected == float.class) return Float.valueOf(((Number)val).floatValue());
	    if (expected.isArray())
	    {
	      Class ct = expected.getComponentType();
	      if (val instanceof List) return Interop.toJavaArray((List)val,ct);
	    }
	    return val;
	  }

	  /**
	   * Coerce a Java object to its Fantom representation.
	   */
	  static Object coerceFromJava(Object val)
	  {
	    if (val == null) return null;
	    Class t = val.getClass();
	    if (t == Integer.class)   return Long.valueOf(((Integer)val).longValue());
	    if (t == Byte.class)      return Long.valueOf(((Byte)val).longValue());
	    if (t == Short.class)     return Long.valueOf(((Short)val).longValue());
	    if (t == Character.class) return Long.valueOf(((Character)val).charValue());
	    if (t == Float.class)     return Double.valueOf(((Float)val).doubleValue());
	    if (t.isArray())
	    {
	      Class ct = t.getComponentType();
	      if (ct.isPrimitive()) return val;
	      return Interop.toFanList(FanUtil.toFanType(ct, true), (Object[])val);
	    }
	    return val;
	  }
}
