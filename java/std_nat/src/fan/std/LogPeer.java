package fan.std;

import fan.sys.*;
import fanx.main.Sys;

public class LogPeer {

	LogLevel level;

	static java.util.Map<String, Log> map = new java.util.HashMap<String, Log>();
	static java.util.List<Func> handlers = new java.util.ArrayList<Func>();

	public static synchronized List list() {
		List list = List.make(Sys.findType("std::Log"), map.size());
		for (Log log : map.values()) {
			list.add(log);
		}
		return list;
	}

	public static synchronized Log find(String name, boolean checked) {
		Log log = map.get(name);
		if (log == null && checked)
			throw ArgErr.make();
		return log;
	}

	public static Log find(String name) {
		return find(name, true);
	}

	public static synchronized void doRegister(Log log) {
		map.put(log.name, log);
	}

	public static synchronized LogLevel level(Log self) {
		LogPeer peer = (LogPeer) self.peer;
		return peer.level;
	}

	public static synchronized void setLevel(Log self, LogLevel l) {
		LogPeer peer = (LogPeer) self.peer;
		peer.level = l;
	}

	public static synchronized void log(Log self, LogRec rec) {
		if (!self.isEnabled(rec.level))
			return;
		for (Func handler : handlers) {
			try {
				handler.call(rec);
			} catch (Throwable e) {
				e.printStackTrace();
			}
		}
	}

	public static synchronized List handlers() {
		List list = List.make(Sys.findType("std::Log"), map.size());
		for (Func handler : handlers) {
			list.add(handler);
		}
		return list;
	}

	public static synchronized void addHandler(Func handler) {
		handlers.add(handler);
	}

	public static synchronized void removeHandler(Func handler) {
		handlers.remove(handler);
	}
	
	public static void printLogRec(LogRec rec, OutStream out) {
		synchronized (out)
	    {
	      out.printLine(rec.toStr());
	      //TODO
	      if (rec.err != null) rec.err.printStackTrace();
	    }
	}
}
