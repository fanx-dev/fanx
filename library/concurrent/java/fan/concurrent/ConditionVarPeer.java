package fan.concurrent;

import fan.std.*;

class ConditionVarPeer {
	java.util.concurrent.locks.Condition var;

	static ConditionVarPeer make(ConditionVar self) {
		return new ConditionVarPeer();
	}

	void init(ConditionVar self, Lock lock) {
		var = lock.toJava().newCondition();
	}

	boolean doWait(ConditionVar self, Lock lock, long nanos) {
		try {
			var.awaitNanos(nanos);
			return true;
		}
		catch(IllegalMonitorStateException e) {
			throw fan.sys.Err.make(e.getMessage(), e);
		}
		catch(Throwable e) {
			return false;
		}
	}
	void doSignal(ConditionVar self, Lock lock) {
		lock.lock();
		var.signal();
		lock.unlock();
	}
	void doSignalAll(ConditionVar self, Lock lock) {
		lock.lock();
		var.signalAll();
		lock.unlock();
	}

	protected void finalize(ConditionVar self) {}
}