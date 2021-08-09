//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    9 Jan 06  Brian Frank  Creation
//   27 Jan 10  Brian Frank  Rename Sys to Env
//

**
** Env defines a pluggable class used to boot and manage a Fantom
** runtime environment.  Use `cur` to access the current Env instance.
**
native rtconst class Env
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////
  static const Env _cur := Env()

  **
  ** Get the current runtime environment
  **
  static Env cur() { _cur }

  **
  ** Subclasses are constructed from a parent environment.
  **
  protected new make() { init }
  protected native Void init()

  override Bool isImmutable() { true }

  override Env toImmutable() { this }

//////////////////////////////////////////////////////////////////////////
// Non-Virtuals
//////////////////////////////////////////////////////////////////////////

  **
  ** Name of the host platform as a string formatted
  ** as "<os>-<arch>".  See `os` and `arch`.
  **
  Str platform() { "${os}-${arch}" }

  **
  ** Operating system name as one of the following constants:
  **   - "win32"
  **   - "macosx"
  **   - "linux"
  **   - "aix"
  **   - "solaris"
  **   - "hpux"
  **   - "qnx"
  **
  Str os()

  **
  ** Microprocessor architecture name as one of the following constants:
  **   - "x86"
  **   - "x86_64"
  **   - "ppc"
  **   - "sparc"
  **   - "ia64"
  **   - "ia64_32"
  **
  Str arch()

  **
  ** Virtual machine runtime as one of the following constants:
  **   - "java"
  **   - "dotnet"
  **   - "js"
  **
  Str runtime()

  **
  ** is Javascript runtime
  **
  Bool isJs()

  **
  ** Get the Java VM Version as a single integer (8, 9, etc.).
  ** If the `runtime` is not java, return 0.
  **
  Int javaVersion()

  **
  ** Return the default hash code of `Obj.hash` for the
  ** specified object regardless of whether the object
  ** has overridden the 'hash' method.  If null then
  ** return 0.
  **
  Int idHash(Obj? obj) {
    if (obj == null) return 0
    return NativeC.toId(obj)
  }

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the command line arguments used to run the fan process
  ** as an immutable List of strings.  Default implementation
  ** delegates to `parent`.
  **
  virtual Str[] args()

  **
  ** Get the environment variables as a case insensitive, immutable
  ** map of Str name/value pairs.  The environment map is initialized
  ** from the following sources from lowest priority to highest priority:
  **   1. shell environment variables
  **   2. Java system properties (Java VM only obviously)
  **
  ** Default implementation delegates to `parent`.
  **
  virtual Str:Str vars()

  **
  ** Poll for a platform dependent map of diagnostics name/value
  ** pairs for the current state of the VM.  Java platforms return
  ** key values from the 'java.lang.management' interface.
  ** Default implementation delegates to `parent`.
  **
  virtual [Str:Obj]? diagnostics()

  **
  ** Run the garbage collector.  No guarantee is made
  ** to what the VM will actually do.  Default implementation
  ** delegates to `parent`.
  **
  virtual Void gc()

  **
  ** Get the local host name of the machine running the
  ** virtual machine process.  Default implementation
  ** delegates to `parent`.
  **
  virtual Str host()

  **
  ** Get the user name of the user account used to run the
  ** virtual machine process.  Default implementation
  ** delegates to `parent`.
  **
  virtual Str user()

  **
  ** Standard input stream.
  ** Default implementation delegates to `parent`.
  **
  virtual InStream in()

  **
  ** Standard output stream.
  ** Default implementation delegates to `parent`.
  **
  virtual OutStream out()

  **
  ** Standard error output stream.
  ** Default implementation delegates to `parent`.
  **
  virtual OutStream err()

  **
  ** Prompt the user to enter a password from standard input with echo
  ** disabled.  Return null if end of stream has been reached.
  ** Default implementation delegates to `parent`.
  **
  virtual Str? promptPassword(Str msg := "")

  **
  ** Get the home directory of Fantom installation.
  ** Default implementation delegates to `parent`.
  **
  virtual File homeDir()

  **
  ** Get the working directory to use for saving compiled
  ** pods and configuration information.  Default implementation
  ** delegates to `parent`.
  **
  virtual File workDir() {
    File.fromPath(envPaths[0])
  }

  **
  ** Get the temp directory to use for scratch files.
  ** Default implementation delegates to `parent`.
  **
  virtual File tempDir() {
    workDir.plus(Uri.fromStr("temp/"), false);
  }

//////////////////////////////////////////////////////////////////////////
// Resolution : pod file and config file
//////////////////////////////////////////////////////////////////////////

  private Array<Str> envPaths := getEnvPaths
  private native Array<Str> getEnvPaths()

  **
  ** Find a file in the environment using a relative path such
  ** as "etc/foo/config.props".  If the URI is not relative then
  ** throw ArgErr.  If the file is not found in the environment
  ** then throw UnresolvedErr or return null based on checked flag.  If
  ** `findAllFiles` would return multiple matches, then this method
  ** should always return the file with the highest priority.
  ** Default implementation delegates to `parent`.
  **
  virtual File? findFile(Uri uri, Bool checked := true) {
    if (uri.isPathAbs())
      throw ArgErr.make("Uri must be relative: " + uri);

    ps := envPaths
    for (i:=0; i<ps.size; ++i) {
      p := ps[i]
      File f = File.make(p.toUri + uri, false)
      if (f.exists()) {
        return f
      }
    }
    if (!checked) return null
    throw UnresolvedErr("File not found in Env: " + uri);
  }

  **
  ** Find all the files in the environment which match a relative
  ** path such as "etc/foo/config.props".  It is possible to have
  ** multiple matches if the environment uses a search path model.
  ** If the list contains more than one item, then the first file
  ** has the highest priority and the last item has the lowest
  ** priority.  If the URI is not relative then throw ArgErr.
  ** Return empty list if the file is not found in environment.
  ** Default implementation delegates to `parent`.
  **
  virtual File[] findAllFiles(Uri uri) {
    if (uri.isPathAbs())
      throw ArgErr.make("Uri must be relative: " + uri);

    ps := envPaths
    list := [,]
    for (i:=0; i<ps.size; ++i) {
      p := ps[i]
      File f = File.make(p.toUri + uri, false)
      if (f.exists()) {
        list.add(f)
      }
    }
    return list
  }

  **
  ** Resolve the pod file for the given pod name.  If the
  ** name cannot be resovled to a pod, return null.  The
  ** default implementation routes to `findFile` to look
  ** in "lib/fan" directory.
  **
  virtual File? findPodFile(Str podName) {
    return findFile(`lib/fan/${podName}.pod`, false)
  }

  **
  ** Return the list of pod names for all the pods currently installed
  ** in this environemnt.  This method is used by `Pod.list` and for
  ** constructing the type database.  Each of these names must be
  ** resolvable by `findPodFile`.  The default implementation routes
  ** to `findFile` to look in the "lib/fan" directory and assumes a
  ** naming convention of "{name}.pod".
  **
  virtual Str[] findAllPodNames() {
    ps := envPaths
    allPod := [:]
    for (i:=0; i<ps.size; ++i) {
      p := ps[i]
      File fdir = File.make(p.toUri + `lib/fan/`, false)
      fdir.list.each |f| {
        if (f.ext == "pod") {
          allPod[f.basename] = f
        }
      }
    }
    return allPod.keys
  }

//////////////////////////////////////////////////////////////////////////
// compile script
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile a script file into a pod and return the first
  ** public type declared in the script file.  If the file
  ** has been previously compiled and hasn't changed, then a
  ** cached type is returned.  If the script contains errors
  ** then the first CompilerErr found is thrown.  The options
  ** available:
  **   - logLevel: the default `LogLevel` to use for logging
  **     the compilation process and errors
  **   - log: the `compiler::CompilerLog` to use for
  **     logging the compilation process and errors
  **   - logOut: an output stream to capture logging
  **   - force: pass 'true' to not use caching, always forces
  **     a recompile
  **
  virtual Type compileScript(File f, [Str:Obj]? options := null) {
    Type t = ScriptCompiler.cur.compile(f, options)
    return t
  }

//////////////////////////////////////////////////////////////////////////
// index props
//////////////////////////////////////////////////////////////////////////

  private [Str:Str[]]? indexMap
  private [Str:Str[]]? keyToPodName

  private Void loadIndex() {
    if (this.indexMap != null) return

    indexMap := [:]
    keyToPodName := [:]

    podNames := findAllPodNames
    podNames.each |name|{
      podFile := findPodFile(name)
      addProps(podFile, name, indexMap, keyToPodName)
    }

    this.indexMap = indexMap.toImmutable
    this.keyToPodName = keyToPodName.toImmutable
  }

  private Void addProps(File podFile, Str podName, [Str:Str[]]? indexMap, [Str:Str[]]? keyToPodName) {
    zip := Zip.open(podFile)
    props := zip.contents[`/index.props`].in.readProps
    props.each |v,k| {
      res := indexMap.getOrAdd(k) { [,] }
      vals := v.split(',')
      vals.each |val| {
        val = val.trim
        if (val.size > 0) res.add(val)
      }
    }

    pods := keyToPodName.getOrAdd(podName) { [,] }
    pods.add(podName)
    zip.close
  }

  **
  ** Lookup all the matching values for a pod indexed key.  If no
  ** matches are found return the empty list.  Indexed props are
  ** declared in your pod's build script, and coalesced into a master
  ** index by the current environment.  See [docLang]`docLang::Env#index`
  ** for details.
  **
  virtual Str[] index(Str key) {
    loadIndex()
    return indexMap.get(key, List.defVal)
  }

  **
  ** Get listing of all keys mapped by indexed props.  The
  ** values of each key may be resolved by the `index` method.
  ** See [docLang]`docLang::Env#index` for details.
  **
  virtual Str[] indexKeys() {
    loadIndex
    return indexMap.keys
  }

  **
  ** Return list of all pod names that define the given key.
  ** NOTE: Java runtime only
  **
  virtual Str[] indexPodNames(Str key) {
    loadIndex
    return keyToPodName.get(key, List.defVal)
  }

//////////////////////////////////////////////////////////////////////////
// config props
//////////////////////////////////////////////////////////////////////////

  private EnvProps envProps := EnvProps();

  **
  ** Return a merged key/value map of all the prop files found
  ** using the following resolution rules:
  **   1. `Env.findAllFiles`: "etc/{pod}/{uri}"
  **   2. `Pod.files`: "/{uri}"
  **
  ** The uri must be relative.
  **
  ** The files are parsed using `InStream.readProps` and merged according
  ** to their priority order.  If the file is defined as a resource in
  ** the pod itself, then it is treated as lowest priority.  The first
  ** file returned by 'findAllFiles' is treated as highest priority and
  ** overwrites any key-value pairs defined at a lower priority.
  **
  ** The map is cached so that subsequent calls for the same path
  ** doesn't require accessing the file system again.  The 'maxAge'
  ** parameter specifies the tolerance accepted before a cache
  ** refresh is performed to check if any of the files have been
  ** modified.
  **
  ** Also see `Pod.props` and `docLang::Env`.
  **
  virtual Str:Str props(Pod pod, Uri uri, Duration maxAge) {
    envProps.get(pod, uri, maxAge)
  }

  **
  ** Lookup a configuration property for given pod/key pair.
  ** If not found then return 'def'.  Default implementation
  ** routes to `props` using max age of one minute:
  **
  **   props(pod, `config.props`, 1min).get(key, def)
  **
  ** Also see `Pod.config` and `docLang::Env`.
  **
  virtual Str? config(Pod pod, Str key, Str? defV := null) {
    props(pod, `config.props`, 1min).get(key, defV)
  }

  private static const Uri configProps = Uri.fromStr("config.props");
  private static const Uri localeEnProps = Uri.fromStr("locale/en.props");

  **
  ** Lookup a localized property for the specified pod/key pair.
  ** The following rules are used for resolution:
  **   1. 'props(pod, `locale/{locale}.props`)'
  **   2. 'props(pod, `locale/{lang}.props`)'
  **   3. 'props(pod, `locale/en.props`)'
  **   4. Fallback to 'pod::key' unless 'def' specified
  **
  ** Where '{locale}' is `Locale.toStr` and '{lang}' is `Locale.lang`.
  **
  ** Also see `Pod.locale` and `docLang::Localization`.
  **
  virtual Str? locale(Pod pod, Str key, Str? defV := "_nodef_", Locale locale := Locale.cur) {
    Str? val;
    Duration maxAge = Duration.maxVal;

    // 1. 'props(pod, `locale/{locale}.props`)'
    val = props(pod, Uri.fromStr("locale/" + locale.toStr() + ".props"), maxAge).get(key, null);
    if (val != null)
      return val;

    // 2. 'props(pod, `locale/{lang}.props`)'
    val = props(pod, Uri.fromStr("locale/" + locale.lang + ".props"), maxAge).get(key, null);
    if (val != null)
      return val;

    // 3. 'props(pod, `locale/en.props`)'
    val = props(pod, localeEnProps, maxAge).get(key, null);
    if (val != null)
      return val;

    // 4. Fallback to 'pod::key' unless 'def' specified
    if (defV == "_nodef_")
      return pod.name + "::" + key;
    return defV
  }

//////////////////////////////////////////////////////////////////////////
// Exiting and Shutdown Hooks
//////////////////////////////////////////////////////////////////////////

  **
  ** Terminate the current virtual machine.
  ** Default implementation delegates to `parent`.
  **
  native virtual Void exit(Int status := 0)

  private |->|[] shutdownHooks := [,]
  internal Void onExit() {
    shutdownHooks.each {
      it.call
    }
  }

  **
  ** Add a function to be called on VM shutdown.  Throw
  ** NotImmutableErr if the function is not immutable.
  ** Default implementation delegates to `parent`.
  **
  virtual Void addShutdownHook(|->| hook) {
    shutdownHooks.add(hook)
  }

  **
  ** Remove a shutdown hook function which was added
  ** by `addShutdownHook`.  Remove true if hook had been
  ** previously added and was unregistered, false otherwise.
  ** Default implementation delegates to `parent`.
  **
  virtual Bool removeShutdownHook(|->| hook) {
    shutdownHooks.remove(hook) != null
  }

}

**************************************************************************
** Env Implementations
**************************************************************************

//internal const class BootEnv : Env {}
//internal const class JarDistEnv : Env {} // JVM only

