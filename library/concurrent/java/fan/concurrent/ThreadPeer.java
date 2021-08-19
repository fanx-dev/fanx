
package fan.concurrent;


class ThreadPeer {
	java.lang.Thread jthread;

	static ThreadPeer make(Thread self) {
		return new ThreadPeer();
	}

	void _start(Thread self, String name) {
		java.lang.Runnable r = new java.lang.Runnable() {
			public void run() {
				self.run();
			}
		};
		jthread = new java.lang.Thread(r, name);
		jthread.start();
	}

	boolean detach(Thread self) { return false; }
	boolean join(Thread self) {
		try {
			jthread.join();
			return true;
		}
		catch(Throwable e) {
			return false;
		}
	}

	long id(Thread self) {
		return jthread.getId();
	}

	static long curId() {
		return java.lang.Thread.currentThread().getId();
	}
	static boolean sleepNanos(long nanos) {
		try {
			long ms = nanos/1000000;
			int ns = (int)(nanos % 1000000);
			//java.lang.System.out.println("sleep:"+ms+","+ns);
			java.lang.Thread.sleep(ms, ns);
			return true;
		}
		catch(Throwable e) {
			return false;
		}
	}

	protected void finalize(Thread self) {}
}