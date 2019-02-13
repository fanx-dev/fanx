//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 06  Brian Frank  Creation
//
package fanx.tools;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.*;
import java.util.zip.*;
import fanx.fcode.*;
import fanx.main.Sys;
import fanx.emit.*;
import fanx.util.*;

/**
 * Jstub loads an fcode pod and emits to a jar file
 */
public class Jstub {

	//////////////////////////////////////////////////////////////////////////
	// Stub
	//////////////////////////////////////////////////////////////////////////

	public void doStub(FPod pod) throws Exception {
		// read fcode into memory
		FType[] types = pod.types;

		// open jar file
		ZipOutputStream out = nozip ? null
				: new ZipOutputStream(new FileOutputStream(new File(outDir, pod.podName + ".jar")));

		try {
			// emit pod - we have to read back the pod here because normal
			// pod loading clears all these tables as soon as Pod$ is emitted
			FPodEmit podEmit = FPodEmit.emit(pod);
			add(out, podEmit.className, podEmit.classFile);

			// write out each type to one or more .class files
			for (int i = 0; i < types.length; ++i) {
				FType type = types[i];
				if (type.isNative())
					continue;
				type.load();
				FTypeEmit[] emitted = FTypeEmit.emit(type);
				// write to jar
				for (int j = 0; j < emitted.length; ++j) {
					FTypeEmit emit = emitted[j];
					add(out, emit.className, emit.classFile);
				}
			}

			// write manifest
			if (out != null) {
				out.putNextEntry(new ZipEntry("meta-inf/Manifest.mf"));
				out.write("Manifest-Version: 1.0\n".getBytes());
				out.write("Created-By: Fantom Java Stub\n".getBytes());
				out.closeEntry();
			}
		} finally {
			try {
				if (out != null)
					out.close();
			} catch (Exception e) {
			}
		}
	}

	/**
	 * Stub the specified pod
	 */
	public void stub(String name) throws Exception {
		String podName;
		File podFile = null;
		if (name.endsWith(".pod")) {
			podFile = new File(name);
			String fname = podFile.getName();
			podName = fname.substring(0, fname.length()-4);
		}
		else {
			podName = name;
		}
		System.out.println("    Java Stub [" + podName + "]");

		FPod pod;
		if (podFile != null) {
			FStore podStore = FStore.makeZip(podFile);
			pod = new FPod(podName, podStore);
			pod.read();
		}
		else {
			// read fcode into memory
			pod = Sys.findPod(podName);
		}
		doStub(pod);
	}
	
	public void stubFile(File podFile, String podName) throws Exception {
		System.out.println("    Java Stub [file:" + podFile + "]");

		// read fcode into memory
		FStore podStore = FStore.makeZip(podFile);
		FPod pod = pod = new FPod(podName, podStore);
		pod.read();
		doStub(pod);
	}

	private void add(ZipOutputStream out, String className, Box classFile) throws Exception {
		String path = className + ".class";
		if (verbose)
			System.out.println("  " + path);
		if (out != null) {
			// zip mode
			out.putNextEntry(new ZipEntry(path));
			out.write(classFile.buf, 0, classFile.len);
			out.closeEntry();
		} else {
			// nozip mode
			File f = new File(outDir, path);
			if (!f.getParentFile().exists())
				f.getParentFile().mkdirs();
			OutputStream fout = new FileOutputStream(f);
			fout.write(classFile.buf, 0, classFile.len);
			fout.close();
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Run
	//////////////////////////////////////////////////////////////////////////

	/**
	 * Main entry point for compiler.
	 */
	public int run(String[] args) throws Exception {
		ArrayList pods = new ArrayList();

		if (args.length == 0) {
			help();
			return -1;
		}

		// process args
		for (int i = 0; i < args.length; ++i) {
			String a = args[i].intern();
			if (a.length() == 0)
				continue;
			if (a == "-help" || a == "-h" || a == "-?") {
				help();
				return -1;
			} else if (a == "-v") {
				verbose = true;
			} else if (a == "-nozip") {
				nozip = true;
			} else if (a == "-d") {
				if (i + 1 >= args.length) {
					System.out.println("ERROR: must specified dir with -d option");
					return -1;
				}
				outDir = new File(args[++i]);
			} else if (a.charAt(0) == '-') {
				System.out.println("WARNING: Unknown option " + a);
			} else {
				pods.add(a);
			}
		}

		if (pods.size() == 0) {
			help();
			return -1;
		}

		for (int i = 0; i < pods.size(); ++i)
			stub((String) pods.get(i));

		// System.out.println("DONE");
		return 0;
	}

	/**
	 * Dump help usage.
	 */
	void help() {
		System.out.println("Java Stub");
		System.out.println("Usage:");
		System.out.println("  jstub [options] <pod> [<pod2> ...]");
		System.out.println("Options:");
		System.out.println("  -help, -h, -?  print usage help");
		System.out.println("  -d             output directory");
		System.out.println("  -v             verbose mode");
		System.out.println("  -nozip         generate classfiles instead of zip");

		System.out.println("  fan.home:        " + Sys.env.homeDir());

		List<String> path = Sys.env.envPaths();
		if (path != null) {
			System.out.println("");
			System.out.println("Env Path:");
			for (int i = 0; i < path.size(); ++i)
				System.out.println("  " + path.get(i));
			System.out.println("");
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Main
	//////////////////////////////////////////////////////////////////////////

	public static void main(String[] args) throws Exception {
		System.exit(new Jstub().run(args));
	}

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	boolean verbose;
	File outDir = new File(".");
	boolean nozip = false;

}