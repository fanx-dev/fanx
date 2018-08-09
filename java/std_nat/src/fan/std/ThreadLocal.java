package fan.std;

import fan.sys.FanObj;
import fan.sys.Func;
import fanx.main.Sys;
import fanx.main.Type;

public class ThreadLocal extends FanObj {
	private final java.lang.ThreadLocal local;

	private static Type type = null;

	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::ThreadLocal");
		}
		return type;
	}

	public ThreadLocal(final Func init) {
		if (init == null) {
			local = new java.lang.ThreadLocal();
		} else {
			local = new java.lang.ThreadLocal() {
				@Override
				protected Object initialValue() {
					return init.call();
				}
			};
		}
	}

	public static ThreadLocal make(Func initail) {
		ThreadLocal self = new ThreadLocal(initail);
		return self;
	}

	public Object get() {
		return local.get();
	}

	public ThreadLocal set(Object val) {
		local.set(val);
		return this;
	}

	public void remove() {
		local.remove();
	}
}
