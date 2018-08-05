package fan.std;

import java.lang.ref.SoftReference;

import fanx.main.Sys;
import fanx.main.Type;

public class SoftRef {

	private static Type type = null;
	public Type typeof() { if (type == null) { type = Sys.findType("std::SoftRef"); } return type;  }
	
	SoftReference sref;
	
	public static SoftRef make(Object val) {
		SoftRef self = new SoftRef();
		self.sref = new SoftReference(val);
		return self;
	}
	
	public Object get() {
		return sref.get();
	}
}
