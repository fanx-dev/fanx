package fan.std;

import fan.sys.*;
import fanx.fcode.*;
import fanx.interop.Interop;
import fanx.main.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.zip.ZipInputStream;

import fan.std.Env;
import fan.std.Log;
import fan.std.Map;
import fan.std.Uri;

public class Pod extends FanObj {
	FPod fpod;
	Version version;
	List depends;
	Map meta;

	boolean docLoaded;
	String doc;

	Log log;
	List types;
	Uri uri;

	private static Type typeof;

	public Type typeof() {
		if (typeof == null) {
			typeof = Sys.findType("std::Pod");
		}
		return typeof;
	}

	//////////////////////////////////////////////////////////////////////////
	// Management
	//////////////////////////////////////////////////////////////////////////

	private Pod(FPod pod) {
		fpod = pod;
	}
	
	public static Pod fromFPod(FPod fpod) {
		if (fpod.reflectPod == null) {
			fpod.reflectPod = new Pod(fpod);
		}
		return (Pod)fpod.reflectPod;
	}

	public static Pod of(Object obj) {
		return FanType.pod(FanType.of(obj));
	}

	public static Pod find(String name) {
		return find(name, true);
	}

	public static Pod find(String name, boolean checked) {
		FPod p = Sys.findPod(name, false);
		if (p == null) {
			if (checked)
				throw UnknownPodErr.make(name);
			return null;
		}
		return fromFPod(p);
	}

	public static List list() {
		List names = Env.cur().findAllPodNames();
		List list = List.make(names.size());
		for (int i =0; i<names.size(); ++i) {
			String n = (String)names.get(i);
			Uri f = Uri.fromStr(n);
			list.add(find(f.basename()));
		}
		list = (List) list.toImmutable();
		return list;
	}

	//////////////////////////////////////////////////////////////////////////
	// Methods
	//////////////////////////////////////////////////////////////////////////

	public final String name() {
		return fpod.podName;
	}

	public final Version version() {
		if (version == null)
			version = Version.fromStr(fpod.podVersion);
		return version;
	}

	public final List depends() {
		if (depends == null) {
			List dps = (List) List.make(fpod.depends.length);
			for (String n : fpod.depends) {
				dps.add(Depend.fromStr(n));
			}
			depends = (List) dps.toImmutable();
		}
		return depends;
	}

	public final Uri uri() {
		if (uri == null)
			uri = Uri.fromStr("fan://" + name());
		return uri;
	}

	public final String toStr() {
		return name();
	}

	public final Map meta() {
		if (meta == null) {
			Map m = Map.make();
			for (java.util.Map.Entry<String, String> entry : fpod.meta.entrySet()) {
				m.set(entry.getKey(), entry.getValue());
			}
			meta = (Map) m.toImmutable();
		}
		return meta;
	}

	//////////////////////////////////////////////////////////////////////////
	// Types
	//////////////////////////////////////////////////////////////////////////

	public List types() {
		if (types == null) {
			List list = List.make(fpod.types.length);
			for (FType f : fpod.types) {
//				if (f.isSynthetic()) continue;
				Type t = Type.fromFType(f, f.signature());
				list.add(t);
			}
			types = list;
		}
		return types;
	}

	public Type type(String name) {
		return type(name, true);
	}

	public Type type(String name, boolean checked) {
		FType ftype = fpod.type(name, checked);
		if (ftype != null) {
			Type type = Type.fromFType(ftype, ftype.signature());
			if (type != null)
				return type;
		}
		if (checked)
			throw UnknownTypeErr.make(this.name() + "::" + name);
		return null;
	}

	//////////////////////////////////////////////////////////////////////////
	// Documentation
	//////////////////////////////////////////////////////////////////////////

	public String doc() {
		if (!docLoaded) {
			try {
				java.io.InputStream in = fpod.store.read("doc/pod.fandoc");
				if (in != null) {
					BufferedReader br = new BufferedReader(new InputStreamReader(in));
					try {
						StringBuilder sb = new StringBuilder();
						String line = br.readLine();
						while (line != null) {
							sb.append(line);
							sb.append("\n");
							line = br.readLine();
						}
						doc = sb.toString();
					} finally {
						br.close();
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			docLoaded = true;
		}
		return doc;
	}

	//////////////////////////////////////////////////////////////////////////
	// Files
	//////////////////////////////////////////////////////////////////////////
	
	private List filesList;
	private Map filesMap = Map.make(32);

	public final List files() {
		loadFiles();
		return filesList;
	}

	public final fan.std.File file(Uri uri) {
		return file(uri, true);
	}

	public final fan.std.File file(Uri uri, boolean checked) {
		loadFiles();
		if (!uri.isPathAbs())
			throw ArgErr.make("Pod.files Uri must be path abs: " + uri);
		if (uri.auth() != null && !uri.toStr().startsWith(uri().toStr()))
			throw ArgErr.make("Invalid base uri `" + uri + "` for `" + uri() + "`");
		else
			uri = this.uri().plus(uri);
		fan.std.File f = (fan.std.File) filesMap.get(uri);
		if (f != null || !checked)
			return f;

		//System.out.println(filesMap.toStr());
		throw UnresolvedErr.make(uri.toStr());
	}

	private void loadFiles() {
		synchronized (filesMap) {
			if (filesList != null)
				return;
			if (fpod.store == null)
				throw Err.make("Not backed by pod file: " + name());
			List list;
			try {
				java.util.List<fanx.fcode.ResFile> jlist = fpod.store.podFiles(uri().toStr());
				list = List.make(jlist.size());
				for (fanx.fcode.ResFile file : jlist) {
					fan.std.File f;
					if (file instanceof fanx.fcode.ResFile.ZipEntryFile) {
						fanx.fcode.ResFile.ZipEntryFile j = (fanx.fcode.ResFile.ZipEntryFile)file;
						f = new fan.std.ZipEntryFile(j.parent, j.entry, Uri.fromStr(j.uri));
					}
					else if (file instanceof fanx.fcode.ResFile.ClassLoaderFile) {
						fanx.fcode.ResFile.ClassLoaderFile j = (fanx.fcode.ResFile.ClassLoaderFile)file;
						f = new fan.std.ClassLoaderFile(j.loader, j.loaderPath, Uri.fromStr(j.uri));
					}
					else {
						continue;
					}
					list.add(f);
				}
				this.filesList = (List) list.toImmutable();
			} catch (java.io.IOException e) {
				e.printStackTrace();
				throw Err.make(e);
			}
			for (int i = 0; i < filesList.size(); ++i) {
				fan.std.File f = (fan.std.File) filesList.get(i);
				filesMap.set(f.uri(), f);
			}
		}
	}

//	public fan.std.File loadFile() {
//		if (loadFile == null) {
//			if (fpod == null)
//				return null;
//			java.io.File jfile = fpod.loadFile();
//			if (jfile == null)
//				return null;
//			loadFile = LocalFilePeer.make(jfile).normalize();
//		}
//		return (fan.std.File) loadFile;
//	}
	
	public static Pod load(InStream in) {
	    FPod fpod = null;
	    try
	    {
	      fpod = new FPod(null, null);
	      fpod.readFully(new ZipInputStream(Interop.toJava(in)));
	      Sys.addPod(fpod);
	    }
	    catch (Exception e)
	    {
	      throw Err.make(e);
	    }

	    return fromFPod(fpod);
	}
	
	public Object _getCompilerCache() {
		return fpod.compilerCache;
	}
	
	public void _setCompilerCache(Object val) {
		fpod.compilerCache = val;
	}

	public boolean isImmutable() {
    return true;
  }

  public Object toImmutable() {
    return this;
  }

	//////////////////////////////////////////////////////////////////////////
	// Utils
	//////////////////////////////////////////////////////////////////////////

	public final Log log() {
		if (log == null)
			log = Log.get(name());
		return log;
	}

	 public final Map props(Uri uri, Duration maxAge) {
		 return Env.cur().props(this, uri, maxAge);
	 }
	
	 public final String config(String key) {
		 return Env.cur().config(this, key);
	 }
	
	 public final String config(String key, String def) {
		 return Env.cur().config(this, key, def);
	 }
	
	 public final String locale(String key) {
		 return Env.cur().locale(this, key);
	 }
	
	 public final String locale(String key, String def) {
		 return Env.cur().locale(this, key, def);
	 }


  public static List flattenDepends(List pods)
  {
    Map acc = Map.make();
    for (int i=0; i<pods.sz(); ++i)
      doFlattenDepends(acc, (Pod)pods.get(i));
    return acc.vals();
  }

  private static void doFlattenDepends(Map acc, Pod pod)
  {
    if (acc.get(pod.name()) != null) return;
    acc.set(pod.name(), pod);
    List depends = pod.depends();
    for (int i=0; i<depends.sz(); ++i)
    {
      Depend d = (Depend)depends.get(i);
      doFlattenDepends(acc, Pod.find(d.name));
    }
  }

  public static List orderByDepends(List pods)
  {
    List left = pods.dup().sort();
    List ordered = List.make(pods.size());
    while (!left.isEmpty())
    {
      // find next pod that doesn't have depends in left list
      int i;
      for (i = 0; i<left.sz(); ++i)
        if (noDependsInLeft(left, (Pod)left.get(i))) break;
      ordered.add(left.removeAt(i));
    }
    return ordered;
  }

  private static boolean noDependsInLeft(List left, Pod p)
  {
    List depends = p.depends();
    for (int i=0; i<depends.sz(); ++i)
    {
      Depend d = (Depend)depends.get(i);
      for (int j=0; j<left.sz(); ++j)
        if (d.name.equals(((Pod)left.get(j)).name()))
          return false;
    }
    return true;
  }


}
