package fan.std;

import fan.sys.ArgErr;
import fan.sys.FanObj;
import fan.sys.List;
import fan.sys.UnknownSlotErr;
import fan.sys.FanObj.InvokeTrapper;
import fanx.main.Type;

public class ReflectInvoker implements InvokeTrapper {
	@Override
	public Object doTrap(Object self, String name, List args, Type type) {
		
		if (self instanceof Type) {
			Object r = FanType.preTrap((Type)self, name, args);
			if (r != null) return r;
		}
		
		Slot slot = FanType.slot(type, name, false);
		if (slot == null) {
//			if (type.qname().equals("std::Type")) {
//				List nargs = List.make(4);
//				nargs.add(self);
//				if (args != null && args.size() > 0) {
//					nargs.addAll(args);
//				}
//				return doTrap(null, name, nargs, TypeExt.typeof());
//			}
			if (self != null && name.equals("typeof")) {
				return FanObj.typeof(self);
			}
			throw UnknownSlotErr.make(type.qname()+"."+name);
		}
		
		if (slot instanceof Method) {
			Method m = (Method)slot;
			if (m.isStatic() || m.isCtor()) {
				return m.callList(args);
			}
			return m.callOn(self, args);
		}
		else if (slot instanceof Field) {
			Field f = (Field)slot;
			
			// handle FFI field overloaded with a method
		     if (f.overload != null)
		        return f.overload.func().callOn(self, args);
		    
			int argc = args == null ? 0 : (int)args.size();
			if (argc == 0) {
				return f.get(self);
			}
			else if (argc == 1) {
				f.set(self, args.get(0));
				return null;
			}
		}
		
		throw ArgErr.make("Invalid number of args to get or set field '" + type.qname()+"."+name + "'("+args+")");
	}
}