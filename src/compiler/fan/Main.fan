//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    3 Jun 06  Brian Frank  Ported from Java to Fantom - Megan's b-day
//

**
** Main is the main entry point for the Fantom compiler.
** Originally it was used for "fanc" command line, but it
** encapsualtes static methods used by sys.
**
class Main
{

  **
  ** Required name of the pod.
  **
  Str? podName := null

  **
  ** Required summary description of pod.
  **
  Str? summary := null

  **
  ** Version of the pod - default is set to `BuildScript.config`
  ** prop 'buildVersion'.
  **
  Version version := Version("1.0")

  **
  ** List of dependencies for pod formatted as `sys::Depend`.
  ** Strings are automatically run through `BuildScript.applyMacros`.
  **
  Depend[] depends := Depend[,]

  **
  ** Pod meta-data name/value pairs to compile into pod.  See `sys::Pod.meta`.
  **
  Str:Str meta := OrderedMap<Str,Str>()//[:] { ordered = true }

  **
  ** Pod index name/value pairs to compile into pod.  See `sys::Env.index`.
  ** The index values can be a single Str or a Str[] if there are
  ** multiple values mapped to one key.
  **
  Str:Obj index := Str:Obj[:]

  **
  ** Indicates if if fandoc API should be included in the documentation.
  ** By default API *is* included.
  **
  Bool docApi := true

  **
  ** Indicates if if source code should be included in the pod/documentation.
  ** By default source code it *not* included.
  **
  Bool docSrc := false

  **
  ** List of Uris relative to build script of directories containing
  ** the Fan source files to compile.
  **
  Uri[]? srcDirs

  **
  ** List of optional Uris relative to build script of directories of
  ** resources files to package into pod zip file.  If a file has a "jar"
  ** extension then its contents are unzipped into the target pod.
  **
  Uri[]? resDirs

  **
  ** List of Uris relative to build script of directories containing
  ** the Java source files to compile for Java native methods.
  **
  Uri[]? javaDirs

  ** List of Uris relative to build script of directories containing
  ** the JNI C source files to compile.
  Uri[]? jniDirs

  ** If non-null, whitelist of platforms JNI should be enabled for.
  ** Platform string may be full platform name ("macosx-x86_64") or OS
  ** only ("macosx").
  Str[]? jniPlatforms

  **
  ** List of Uris relative to build script of directories containing
  ** the C# source files to compile for .NET native methods.
  **
  Uri[]? dotnetDirs

  **
  ** List of Uris relative to build script of directories containing
  ** the JavaScript source files to compile for JavaScript native methods.
  **
  Uri[]? jsDirs

  **
  ** The directory to look in for the dependency pod file (and
  ** potentially their recursive dependencies).  If null then we
  ** use the compiler's own pod definitions via reflection (which
  ** is more efficient).  As a general rule you shouldn't mess
  ** with this field - it is used by the 'build' and 'compiler'
  ** build scripts for bootstrap build.
  **
  Uri? dependsDir := devHomeDir.plus(`lib/fan/`).uri

  **
  ** Directory to output pod file.  By default it goes into
  ** "{Env.cur.workDir}/lib/fan/"
  **
  Uri outPodDir := devHomeDir.plus(`lib/fan/`).uri

  **
  ** Directory to output documentation (docs always get placed in sub-directory
  ** named by pod).  By default it goes into
  ** "{Env.cur.workDir}/doc/"
  **
  Uri outDocDir := devHomeDir.plus(`doc/`).uri


  private File? scriptFile

  **
  ** Home directory of development installation.  By default this
  ** value is initialized by 'devHome' config prop, otherwise
  ** `sys::Env.homeDir` is used.
  **
  static const File devHomeDir := getDevHomeDir

  ** init devHomeDir
  private static File getDevHomeDir() {
    devHome := Env.cur.vars["FANX_DEV_HOME"]
    if (devHome != null) {
      //Windows driver name
      if (devHome.size > 1 && devHome[0].isAlpha && devHome[1] == ':') {
        devHome = File.os(devHome).uri.toStr
      }
    }
    if (devHome == null)
      devHome = Pod.find("build", false)?.config("devHome")
    if (devHome == null)
      devHome = Main#.pod.config("devHome")

    if (devHome != null)
    {
      path := devHome.toUri
      f := File(path)
      if (!f.exists || !f.isDir) throw Err("Invalid dir URI for '$devHome'")
      return f
    }
    else {
      return Env.cur.workDir
    }
  }

//////////////////////////////////////////////////////////////////////////

  private Void validate()
  {
    if (podName == null) throw ArgErr("Must set BuildPod.podName")
    if (summary == null) throw ArgErr("Must set BuildPod.summary")

    // boot strap checking
    if (["std", "sys", "build", "compiler", "compilerJava"].contains(podName))
    {
      if (devHomeDir == Env.cur.homeDir)
        throw ArgErr("Must update 'devHome' for bootstrap build")
    }
  }

  private Uri[]? parseDirs(Str? str) {
    if (str == null) return null
    srcDirs := Uri[,]
    str.split(',').each |d| {
      if (d.endsWith("*")) {
        srcUri := d[0..<-1].toUri
        dirs := allDir(scriptFile.uri, srcUri)
        srcDirs.addAll(dirs)
      }
      else {
        srcDirs.add(d.toUri)
      }
    }
    return srcDirs
  }

  private Void getStartsWith(Str str, [Str:Str] props, [Str:Str] map) {
    props.each |v,k| {
      if (k.startsWith(str)) {
        k = k[str.size..-1]
        map[k] = v
      }
    }
  }

  private Void parse([Str:Str] props) {
    podName = props.get("podName")
    summary = props.get("summary")

    versionStr := props.get("version")
    if (versionStr != null) version = Version(versionStr)

    //get depends
    props.get("depends", "").split(',').each { if (it.size>0) depends.add(Depend(it)) }

    //get srcDirs
    srcDirs = parseDirs(props.get("srcDirs"))
    resDirs = parseDirs(props.get("resDirs"))
    javaDirs = parseDirs(props.get("javaDirs"))
    jsDirs = parseDirs(props.get("jsDirs"))

    //echo("srcDirs: $srcDirs resDirs: $resDirs")

    docApi = props.get("docApi", "true") == "true"

    //TODO fix ?.
    Str? temp := props.get("dependsDir", null)
    if (temp != null) dependsDir = temp.toUri

    //get outPodDir
    outPodDirStr := props.get("outPodDir", null)
    if (outPodDirStr != null) outPodDir = outPodDirStr.toUri

    // add my own meta
    //meta := this.meta.dup
    meta["pod.docApi"] = docApi.toStr
    meta["pod.docSrc"] = docSrc.toStr
    meta["pod.native.java"]   = (javaDirs   != null && !javaDirs.isEmpty).toStr
    meta["pod.native.jni"]    = (jniDirs    != null && !jniDirs.isEmpty).toStr
    meta["pod.native.dotnet"] = (dotnetDirs != null && !dotnetDirs.isEmpty).toStr
    meta["pod.native.js"]     = (jsDirs     != null && !jsDirs.isEmpty).toStr

    //get matadata
    getStartsWith("meta.", props, meta)

    //get index
    getStartsWith("index.", props, index)
    //echo("meta: $meta, index: $index")

    // if stripTest config property is set to true then don't
    // compile any Fantom code under test/ or include any res files
    if (this.typeof.pod.config("stripTest", "false") == "true")
    {
      if (srcDirs != null) srcDirs = srcDirs.dup.findAll |uri| { uri.path.first != "test" }
      if (resDirs != null) resDirs = resDirs.dup.findAll |uri| { uri.path.first != "test" }
    }
  }

  private Void compile() {
    // map my config to CompilerInput structure
    ci := CompilerInput()
    ci.inputLoc    = Loc.makeFile(scriptFile)
    ci.podName     = podName
    ci.summary     = summary
    ci.version     = version
    ci.depends     = depends
    ci.meta        = meta
    ci.index       = index
    ci.baseDir     = scriptFile.parent
    ci.srcFiles    = srcDirs
    ci.resFiles    = resDirs
    ci.jsFiles     = jsDirs
    //ci.log         = log
    ci.includeDoc  = docApi
    ci.includeSrc  = docSrc
    ci.mode        = CompilerInputMode.file
    ci.outDir      = outPodDir.toFile
    ci.output      = CompilerOutputMode.podFile

    if (dependsDir != null)
    {
      f := dependsDir.toFile
      if (!f.exists) throw ArgErr("Invalid dependsDir: $f")
      ci.ns = FPodNamespace(f)
    }

    // subclass hook
    //onCompileFan(ci)

    try {
      Compiler(ci).compile
    }
    catch (CompilerErr err) {
      // all errors should already be logged by Compiler
      throw err
    }
    catch (Err err) {
      throw err
    }
  }

  **
  ** mini build for boost
  **
  virtual Void main(Str[] args)
  {
    scriptFile = args.first.toUri.toFile.normalize
    props := scriptFile.in.readProps
    parse(props)
    validate
    compile
  }

  static Uri[] allDir(Uri base, Uri dir)
  {
    Uri[] subs := [,]
    (base + dir).toFile.walk |File f|
    {
      if(f.isDir)
      {
        rel := f.uri.relTo(base)
        subs.add(rel)
      }
    }
    return subs
  }

//////////////////////////////////////////////////////////////////////////

  **
  ** Compile the script file into a transient pod.
  ** See `sys::Env.compileScript` for option definitions.
  **
  static Pod compileScript(Str podName, File file, [Str:Obj]? options := null)
  {
    input := CompilerInput.make
    input.podName        = podName
    input.summary        = "script"
    input.version        = Version("0")
    input.log.level      = LogLevel.warn
    input.includeDoc     = true
    input.isScript       = true
    input.srcStr         = file.readAllStr
    input.srcStrLoc      = Loc.makeFile(file)
    input.mode           = CompilerInputMode.str
    input.output         = CompilerOutputMode.transientPod
    input.depends        = [Depend("sys 2.0"), Depend("std 1.0")]

    if (options != null)
    {
      log := options["log"]
      if (log != null) input.log = log

      logOut := options["logOut"]
      if (logOut != null) input.log = CompilerLog(logOut)

      logLevel := options["logLevel"]
      if (logLevel != null) input.log.level = logLevel

      fcodeDump := options["fcodeDump"]
      if (fcodeDump == true) input.fcodeDump = true
    }

    return Compiler(input).compile.transientPod
  }

}