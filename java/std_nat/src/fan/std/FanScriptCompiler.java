package fan.std;

import fan.sys.Err;
import fan.sys.List;
import fanx.main.Type;
import fanx.tools.Fan.ScriptCompiler;

public class FanScriptCompiler implements ScriptCompiler {
	static public FanScriptCompiler cur = new FanScriptCompiler();
	
	public Pod doCompileScript(File f, Map options) {
	    Type main = Pod.find("compiler").type("Main");
	    Method cs = TypeExt.method(main, "compileScript");
	    String podName = f.basename() + "_" + TimePoint.nowUnique();
	    Pod pod = (Pod)cs.call(podName, f, options);
	    return pod;
	}
	
	public int executeScript(String fileName, String[] args) {
		try {
			File file = File.make(Uri.fromStr(fileName));

			Map options = Map.make();
			for (int i = 0; args != null && i < args.length; ++i)
				if (args[i].equals("-fcodeDump"))
					options.add("fcodeDump", Boolean.TRUE);

			// use Fantom reflection to run compiler::Main.compileScript(File)
			Pod pod = doCompileScript(file, options);
			// get the primary type
			List types = pod.types();
			Type type = null;
			Method main = null;
			for (int i = 0; i < types.sz(); ++i) {
				type = (Type) types.get(i);
				main = TypeExt.method(type, "main", false);
				if (main != null)
					break;
			}

			if (main == null) {
				System.out.println("ERROR: missing main method: " + ((Type) types.get(0)).name() + ".main()");
				return -1;
			}
			
			return callMain(type, main);
		} catch (Err e) {
			System.out.println("ERROR: cannot compile script");
			// if (!e.getClass().getName().startsWith("fan.compiler"))
			e.trace();
			return -1;
		} catch (Exception e) {
			System.out.println("ERROR: cannot compile script");
			e.printStackTrace();
			return -1;
		}
	}

	int callMain(Type t, Method m) {
		// main method

		// check parameter type and build main arguments
		List args;
		List params = m.params();
		if (params.sz() == 0) {
			args = null;
		} else if (((Param) params.get(0)).type().fits(Type.find("sys::List"))
				&& (params.sz() == 1 || ((Param) params.get(1)).hasDefault())) {
			args = Env.cur().args();
		} else {
			System.out.println("ERROR: Invalid parameters for main: " + m.signature());
			return -1;
		}

		// invoke
		try {
			if (m.isStatic())
				return toResult(m.callList(args));
			else
				return toResult(m.callOn(TypeExt.make(t), args));
		} catch (Err ex) {
			ex.trace();
			return -1;
		} finally {
			cleanup();
		}
	}

	static int toResult(Object obj)
	  {
		if (obj == null) return 0;
	    if (obj instanceof Long) return ((Long)obj).intValue();
	    if (obj instanceof Integer) return ((Integer)obj).intValue();
	    return 0;
	  }

	static void cleanup() {
		try {
			Env.cur().out().flush();
			Env.cur().err().flush();
		} catch (Throwable e) {
		}
	}
}