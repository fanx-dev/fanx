package fan.std;

import fan.sys.*;
import fanx.main.Sys;

public class LogPeer {

	LogLevel level = LogLevel.info;

	static java.util.Map<String, Log> map = new java.util.HashMap<String, Log>();
	static java.util.List<Func> handlers = new java.util.ArrayList<Func>();
	
	static
	{
	    try
	    {
	    	Func handler = new Func() {
//				@Override
//				public long arity() {
//					return 1;
//				}
				
				@Override
				public Object call(Object a) {
					LogRec r = (LogRec)a;
					r.print();
					return null;
				}
				@Override
				public boolean isImmutable() {
					return true;
				}
	    	};
	    	handlers.add(handler);
	    }
	    catch (Throwable e)
	    {
	      e.printStackTrace();
	    }
	}
	
	static LogPeer make(Log log) {
		LogPeer peer = new LogPeer();
		return peer;
	}

	public static synchronized List list() {
		List list = List.make(map.size());
		for (Log log : map.values()) {
			list.add(log);
		}
		return list;
	}

	public static synchronized Log find(String name, boolean checked) {
		Log log = map.get(name);
		if (log == null && checked)
			throw Err.make();
		return log;
	}

	public static Log find(String name) {
		return find(name, true);
	}

	public static synchronized void doRegister(Log log) {
		if (map.containsKey(log.name))
			throw ArgErr.make("Duplicate log name: " + log.name);
		map.put(log.name, log);
	}

	public synchronized LogLevel level(Log self) {
		return this.level;
	}

	public synchronized void level(Log self, LogLevel l) {
		this.level = l;
	}
	
	public static void slog(String name, LogRec rec) {
		synchronized(handlers) {
			for (Func handler : handlers) {
				try {
					handler.call(rec);
				} catch (Throwable e) {
					e.printStackTrace();
				}
			}
		}
	}

	public void log(Log self, LogRec rec) {
		if (!self.isEnabled(rec.level))
			return;
		synchronized(handlers) {
			for (Func handler : handlers) {
				try {
					handler.call(rec);
				} catch (Throwable e) {
					e.printStackTrace();
				}
			}
		}
	}

	public static synchronized List handlers() {
		List list = List.make(map.size());
		for (Func handler : handlers) {
			list.add(handler);
		}
		return list;
	}

	public static synchronized void addHandler(Func handler) {
		if (!handler.isImmutable())
		      throw NotImmutableErr.make("handler must be immutable");
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
