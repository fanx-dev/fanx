package fan.std;

import fan.sys.FanObj;
import fan.sys.Func;
import fanx.main.Sys;
import fanx.main.Type;

public class Lazy extends FanObj {
	private Object val;
	private Func initial;
	
	private static Type type = null;

	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::Lazy");
		}
		return type;
	}
	
	public static Lazy make(Func init) {
		Lazy self = new Lazy();
		self.initial = (Func)init.toImmutable();
		return self;
	}
	
	public Object get() {
		if (val == null) {
			synchronized(this) {
				if (val == null) {
					Object v = initial.call();
					val = FanObj.toImmutable(v);
				}
			}
		}
		return val;
	}
}
