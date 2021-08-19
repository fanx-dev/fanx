package fan.sys;

import fanx.fcode.FConst;
import fanx.main.Sys;
import fanx.main.Type;

public class EnumPeer {
	protected static Enum doFromStr(String type, String name, boolean checked) {
		Type t = Sys.findType(type);
		if ((t.flags() & FConst.Enum) != 0) {
			try {
				Object val = FanObj.doTrap(null, name, null, t);
				if (val instanceof Enum) {
					return (Enum) val;
				}
			} catch (Exception e) {
//				e.printStackTrace();
			}
		}
		if (!checked)
			return null;
		throw ParseErr.make(name);
	}
}
