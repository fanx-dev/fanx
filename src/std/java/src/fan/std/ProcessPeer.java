package fan.std;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Iterator;
import java.util.Map.Entry;

import fan.sys.Err;
import fan.sys.Func;
import fanx.interop.Interop;

public class ProcessPeer {
	private volatile java.lang.Process proc;
	private Map env;

	public static ProcessPeer make(fan.std.Process self) {
		return new ProcessPeer();
	}

	public Map env(fan.std.Process self) {
		if (env == null) {
			env = Map.make(32);
			Iterator it = new ProcessBuilder().environment().entrySet().iterator();
			while (it.hasNext()) {
				Entry entry = (Entry) it.next();
				String key = (String) entry.getKey();
				String val = (String) entry.getValue();
				env.set(key, val);
			}
		}
		return env;
	}

	public final Process run(fan.std.Process self) {
		checkRun();
		try {
			// commands
			String[] strings = new String[(int) self.command.size()];
			for (int i = 0; i < self.command.size(); ++i)
				strings[i] = (String) self.command.get(i);
			final ProcessBuilder builder = new ProcessBuilder(strings);

			// environment
			if (env != null) {
				env.each(new Func() {
					@Override
					public long arity() {
						return 2;
					}

					@Override
					public Object call(Object v, Object k) {
						String key = (String) k;
						String val = (String) v;
						builder.environment().put(key, val);
						return null;
					}
				});
				// while (it.hasNext()) {
				// Entry entry = (Entry) it.next();
				// String key = (String) entry.getKey();
				// String val = (String) entry.getValue();
				// builder.environment().put(key, val);
				// }
			}

			// working directory
			if (self.dir != null)
				builder.directory(Interop.toJava((LocalFile) self.dir));

			// mergeErr
			if (self.mergeErr)
				builder.redirectErrorStream(true);

			// map Fantom streams to Java streams

			// start it
			this.proc = builder.start();

			// now launch threads to pipe std out, in, and err
			new PipeInToOut(this, "out", proc.getInputStream(), self.out).start();
			if (!self.mergeErr)
				new PipeInToOut(this, "err", proc.getErrorStream(), self.err).start();
			if (self.in != null)
				new PipeOutToIn(this, proc.getOutputStream(), self.in).start();

			return self;
		} catch (Throwable e) {
			this.proc = null;
			throw Err.make(e);
		}
	}

	public final long join(fan.std.Process self) {
		if (proc == null)
			throw Err.make("Process not running");
		try {
			return proc.waitFor();
		} catch (Throwable e) {
			throw Err.make(e);
		}
	}

	public final Process kill(fan.std.Process self) {
		if (proc == null)
			throw Err.make("Process not running");
		proc.destroy();
		return self;
	}

	private void checkRun() {
		if (proc != null)
			throw Err.make("Process already run");
	}

	boolean isAlive() {
		// hacky to use exception for flow control, but there
		// doesn't seem to be any other way to check state
		try {
			proc.exitValue();
			return false;
		} catch (IllegalThreadStateException e) {
			return true;
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// PipeInToOut
	//////////////////////////////////////////////////////////////////////////

	static class PipeInToOut extends java.lang.Thread {
		PipeInToOut(ProcessPeer proc, String name, InputStream in, OutStream out) {
			super("Process." + name);
			this.proc = proc;
			this.in = in;
			this.out = out == null ? null : Interop.toJava(out);
		}

		public void run() {
			byte[] temp = new byte[256];
			while (true) {
				try {
					int n = in.read(temp, 0, temp.length);
					if (n < 0) {
						if (out != null)
							out.flush();
						break;
					}
					if (out != null)
						out.write(temp, 0, n);
				} catch (Throwable e) {
					if (proc.isAlive())
						e.printStackTrace();
					else
						return;
				}
			}
		}

		final ProcessPeer proc;
		final InputStream in;
		final OutputStream out;
	}

	//////////////////////////////////////////////////////////////////////////
	// PipeOutToIn
	//////////////////////////////////////////////////////////////////////////

	static class PipeOutToIn extends java.lang.Thread {
		PipeOutToIn(ProcessPeer proc, OutputStream out, InStream in) {
			super("Process.in");
			this.proc = proc;
			this.out = out;
			this.in = Interop.toJava(in);
		}

		public void run() {
			byte[] temp = new byte[256];
			while (true) {
				try {
					int n = in.read(temp, 0, temp.length);
					if (n < 0)
						break;
					out.write(temp, 0, n);
					out.flush();
				} catch (Throwable e) {
					if (proc.isAlive())
						e.printStackTrace();
					else
						return;
				}
			}
		}

		final ProcessPeer proc;
		final OutputStream out;
		final InputStream in;
	}
}
