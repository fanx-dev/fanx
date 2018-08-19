package fan.std;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

import fan.sys.FanObj;
import fan.sys.Func;
import fanx.main.Sys;
import fanx.main.Type;

public class Lock extends FanObj {
	java.util.concurrent.locks.Lock lock;
	
	public static Lock make() {
		Lock l = new Lock();
		l.lock = new ReentrantLock();
		return l;
	}
	
	private static Type type = null;
	public Type typeof() { if (type == null) { type = Sys.findType("std::Lock"); } return type;  }
	
	public boolean tryLock(long nanoTime) {
		try {
			return lock.tryLock(nanoTime, TimeUnit.NANOSECONDS);
		} catch (InterruptedException e) {
			return false;
		}
	}
	
	public void lock() {
		lock.lock();
	}
	
	public void unlock() {
		lock.unlock();
	}
	
	public Object sync(Func c) {
		try {
			lock.lock();
			return c.call();
		}
		finally {
			lock.unlock();
		}
	}
}
