package fan.std;

import java.util.concurrent.ConcurrentHashMap;

import fan.sys.FanObj;
import fanx.main.Sys;
import fanx.main.Type;

public class ConcMap {
	private static Type type = null;
	public Type typeof() { if (type == null) { type = Sys.findType("std::ConcMap"); } return type;  }
	
	ConcurrentHashMap map;
	
	public static ConcMap make(long cp) {
		ConcMap self = new ConcMap();
		self.map = new ConcurrentHashMap((int)cp);
		return self;
	}
	
	public long size() {
		return map.size();
	}
	
	public ConcMap set(Object k, Object v) {
		k = FanObj.toImmutable(k);
		v = FanObj.toImmutable(v);
		map.put(k, v);
		return this;
	}
	
	public Object get(Object k) {
		return get(k, null);
	}
	
	public Object get(Object k, Object defV) {
		return map.getOrDefault(k, defV);
	}
	
	public ConcMap clear() {
		map.clear();
		return this;
	}
}
