package fanx.main;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import fanx.fcode.FStore;

public class JarDistEnv extends BootEnv {

	@Override
	public FStore loadPod(String name, boolean checked) {
		FStore store = FStore.makeJarDist(JarDistEnv.class.getClassLoader(), name);
		if (store == null && checked) {
			throw Sys.makeErr("sys::UnknownPodErr", "pod:"+name);
		}
		return store;
	}

	@Override
	public List<String> listPodNames() {
		System.out.println("WARN: JarDistEnv.findFile not implemented");
		return new ArrayList<String>();
	}

	@Override
	public File getPodFile(String name, boolean checked) {
		System.out.println("WARN: JarDistEnv.findFile not implemented: " + name);
	    if (!checked) return null;
	    throw Sys.makeErr("sys::UnresolvedErr", "File not found in Env: " + name);
	}

}
