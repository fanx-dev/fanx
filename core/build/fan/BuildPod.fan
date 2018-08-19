//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

using compiler

**
** BuildPod is the base class for build scripts used to manage
** building a Fantom source code and resources into a Fantom pod.
**
** See `docTools::Build` for details.
**
class BuildPod : BuildScript
{

//////////////////////////////////////////////////////////////////////////
// Env
//////////////////////////////////////////////////////////////////////////

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
  Version version := Version(config("buildVersion", "0"))

  **
  ** List of dependencies for pod formatted as `sys::Depend`.
  ** Strings are automatically run through `BuildScript.applyMacros`.
  **
  Str[] depends := Str[,]

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
  Uri? dependsDir := null

  **
  ** Directory to output pod file.  By default it goes into
  ** "{Env.cur.workDir}/lib/fan/"
  **
  Uri outPodDir := Env.cur.workDir.plus(`lib/fan/`).uri

  **
  ** Directory to output documentation (docs always get placed in sub-directory
  ** named by pod).  By default it goes into
  ** "{Env.cur.workDir}/doc/"
  **
  Uri outDocDir := Env.cur.workDir.plus(`doc/`).uri

//////////////////////////////////////////////////////////////////////////
// Validate
//////////////////////////////////////////////////////////////////////////

  private Void validate()
  {
    if (podName == null) throw fatal("Must set BuildPod.podName")
    if (summary == null) throw fatal("Must set BuildPod.summary")

    // boot strap checking
    if (["sys", "std", "build", "compiler", "compilerJava"].contains(podName))
    {
      if (Env.cur.homeDir == devHomeDir) {
        //throw fatal("Must update 'devHome' for bootstrap build")
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Compile
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile the source into a pod file and all associated
  ** natives.  See `compileFan`, `compileJava`, and `compileDotnet`.
  **
  @Target { help = "Compile to pod file and associated natives" }
  virtual Void compile()
  {
    validate

    log.info("compile [$podName]")
    log.indent

    compileFan
    compileJava
    compileJni
// TODO-FACET
//    compileDotnet
    log.unindent
  }

//////////////////////////////////////////////////////////////////////////
// Compile Fan
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile Fan code into pod file
  **
  virtual Void compileFan()
  {
    // add my own meta
    meta := this.meta.dup
    meta["pod.docApi"] = docApi.toStr
    meta["pod.docSrc"] = docSrc.toStr
    meta["pod.native.java"]   = (javaDirs   != null && !javaDirs.isEmpty).toStr
    meta["pod.native.jni"]    = (jniDirs    != null && !jniDirs.isEmpty).toStr
    meta["pod.native.dotnet"] = (dotnetDirs != null && !dotnetDirs.isEmpty).toStr
    meta["pod.native.js"]     = (jsDirs     != null && !jsDirs.isEmpty).toStr

    // TODO: add additinal meta props defined by config file/env var
    // this behavior is not guaranteed in future versions, rather we
    // need to potentially overhaul how build data is defined
    // See topic http://fantom.org/sidewalk/topic/1584
    config("meta", "").split(',').each |pair|
    {
      if (pair.isEmpty) return
      tuples := pair.split('=')
      if (tuples.size != 2) throw Err("Invalid config meta: $pair")
      meta[tuples[0]] = tuples[1]
    }

    // if stripTest config property is set to true then don't
    // compile any Fantom code under test/ or include any res files
    srcDirs := this.srcDirs
    resDirs := this.resDirs
    if (config("stripTest", "false") == "true")
    {
      if (srcDirs != null) srcDirs = srcDirs.dup.findAll |uri| { uri.path.first != "test" }
      if (resDirs != null) resDirs = resDirs.dup.findAll |uri| { uri.path.first != "test" }
    }

    // map my config to CompilerInput structure
    ci := CompilerInput()
    ci.inputLoc    = Loc.makeFile(scriptFile)
    ci.podName     = podName
    ci.summary     = summary
    ci.version     = version
    ci.depends     = depends.map |s->Depend| { Depend(applyMacros(s)) }
    ci.meta        = meta
    ci.index       = index
    ci.baseDir     = scriptDir
    ci.srcFiles    = srcDirs
    ci.resFiles    = resDirs
    ci.jsFiles     = jsDirs
    ci.log         = log
    ci.includeDoc  = docApi
    ci.includeSrc  = docSrc
    ci.mode        = CompilerInputMode.file
    ci.outDir      = outPodDir.toFile
    ci.output      = CompilerOutputMode.podFile

    if (dependsDir != null)
    {
      f := dependsDir.toFile
      if (!f.exists) throw fatal("Invalid dependsDir: $f")
      ci.ns = FPodNamespace(f)
    }

    // subclass hook
    onCompileFan(ci)

    try
    {
      Compiler(ci).compile
    }
    catch (CompilerErr err)
     {
      // all errors should already be logged by Compiler
      throw FatalBuildErr()
    }
    catch (Err err)
    {
      log.err("Internal compiler error")
      err.trace
      throw FatalBuildErr.make
    }
  }

  **
  ** Callback to tune the Fantom compiler input
  **
  virtual Void onCompileFan(CompilerInput ci) {}

//////////////////////////////////////////////////////////////////////////
// Compile Java
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile Java class files if javaDirs is configured
  **
  virtual Void compileJava()
  {
    if (this.javaDirs == null) return
    javaDirs := resolveDirs(this.javaDirs)

    log.info("javaNative [$podName]")
    log.indent

    // env
    jtemp    := scriptDir + `temp-java/`
    //jstub    := jtemp + "${podName}.jar".toUri
    jdk      := JdkTask(this)
    javaExe  := jdk.javaExe
    jarExe   := jdk.jarExe
    sysJar   := devHomeDir + `lib/java/fanx.jar`
    libFan   := devHomeDir + `lib/fan/`
    curPod   := outPodDir.toFile + `${podName}.pod`
    depends  := depends.map |s->Depend| { Depend(applyMacros(s)) }

    // stub the pods fan classes into Java classfiles
    // by calling the JStub tool in the jsys runtime
    jtemp.create
    Exec(this, [javaExe,
                "-cp", sysJar.osPath,
                "-Dfan.home=$devHomeDir.osPath",
                "fanx.tools.Jstub",
                "-d", (devHomeDir+`lib/java/stub/`).osPath,
                podName]).run

    // compile
    if (!javaDirs.isEmpty)
    {
      javac := CompileJava(this)
      javac.outDir = jtemp
      //javac.cp.add(jstub)
      javac.cpAddExtJars
      javac.cp.add(sysJar)
      javac.cpAddJars((devHomeDir + `lib/java/`))
      javac.cpAddJars((devHomeDir + `lib/java/stub/`))
      depends.each |Depend d| { javac.cp.add(Env.cur.findPodFile(d.name)) }
      javac.src = javaDirs
      javac.run
    }

    // extract stub jar into the temp directory
    //Exec(this, [jarExe, "-xf", jstub.osPath], jtemp).run

    // now we can nuke the stub jar (and manifest)
    //Delete(this, jstub).run
    Delete(this, jtemp + `meta-inf/`).run

    // append files to the pod zip (we use java's jar tool)
    Exec(this, [jarExe, "-fu", curPod.osPath, "-C", jtemp.osPath, "."], jtemp).run

    // cleanup temp
    Delete(this, jtemp).run

    log.unindent
  }

//////////////////////////////////////////////////////////////////////////
// JNI
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile JNI bindings if jniDirs configured.
  **
  virtual Void compileJni()
  {
    if (jniDirs == null) return

    log.info("JNI [$podName]")
    log.indent

    // check whitelist
    if (jniPlatforms != null)
    {
      if (!jniPlatforms.contains(Env.cur.os) &&
          !jniPlatforms.contains(Env.cur.platform))
      {
        log.info("  Skipping platform $Env.cur.platform")
        return
      }
    }

    // env
    jtemp := scriptDir + `temp-jni/`
    jdirs := this->resolveDirs(jniDirs)

    // start with a clean directory
    Delete(this, jtemp).run
    CreateDir(this, jtemp).run

    // compile
    cc := CompileJni(this)
    cc.src = jdirs
    cc.out = jtemp
    cc.lib = podName
    cc.run

    // override target platform
    plat := config("jniPlatform") ?: Env.cur.platform

    // move files to /lib/java/ext/<plat>/
    libSrc := jtemp + cc.platLib
    libDst := (outPodDir.parent + `java/ext/${plat}/${cc.platLib}`).toFile
    log.info("Move [$libDst.osPath]")
    libSrc.copyTo(libDst, ["overwrite":true])

    // cleanup temp
    Delete(this, jtemp).run

    log.unindent
  }

//////////////////////////////////////////////////////////////////////////
// DotnetNative
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile native .NET assembly dotnetDirs configured
  **
  virtual Void compileDotnet()
  {
    if (dotnetDirs == null) return

    if (Env.cur.os != "win32")
    {
      log.info("dotnetNative skipping [$podName]")
      return
    }

    log.info("dotnetNative [$podName]")
    log.indent

    // env
    ntemp := scriptDir + `temp-dotnet/`
    nstub := ntemp + `${podName}.dll`
    nout  := ntemp + `${podName}Native_.dll`
    ndirs := resolveDirs(dotnetDirs)
    nlibs := [devHomeDir+`lib/dotnet/sys.dll`, nstub]
    nstubExe := devHomeDir + `bin/nstub`

    // start with a clean directory
    Delete(this, ntemp).run
    CreateDir(this, ntemp).run

    // stub the pods fan classes into Java classfiles
    // by calling the JStub tool in the jsys runtime
    Exec(this, [nstubExe.osPath, "-d", ntemp.osPath, podName]).run

    // compile
    csc := CompileCs(this)
    csc.output = nout
    csc.targetType = "library"
    csc.src  = ndirs
    csc.libs = nlibs
    csc.run

    // append files to the pod zip (we use java's jar tool)
    jdk    := JdkTask(this)
    jarExe := jdk.jarExe
    curPod := devHomeDir + `lib/fan/${podName}.pod`
    Exec(this, [jarExe, "-fu", curPod.osPath, "-C", ntemp.osPath,
      "${podName}Native_.dll", "${podName}Native_.pdb"], ntemp).run

    // cleanup temp
    Delete(this, ntemp).run

    log.unindent
  }

//////////////////////////////////////////////////////////////////////////
// Clean
//////////////////////////////////////////////////////////////////////////

  **
  ** Delete all intermediate and target files
  **
  @Target { help = "Delete all intermediate and target files" }
  virtual Void clean()
  {
    log.info("clean [$podName]")
    log.indent
    dir := isFantomCore ? devHomeDir : Env.cur.workDir
    Delete(this, dir+`lib/fan/${podName}.pod`).run
    Delete(this, dir+`lib/java/${podName}.jar`).run
    Delete(this, dir+`lib/dotnet/${podName}.dll`).run
    Delete(this, dir+`lib/dotnet/${podName}.pdb`).run
    Delete(this, dir+`lib/tmp/${podName}.dll`).run
    Delete(this, dir+`lib/tmp/${podName}.pdb`).run
    Delete(this, scriptDir+`temp-java/`).run
    Delete(this, scriptDir+`temp-dotnet/`).run
    log.unindent
  }

  private Bool isFantomCore() { meta["proj.name"] == "Fantom Core" }

//////////////////////////////////////////////////////////////////////////
// Test
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the unit tests using 'fant' for this pod
  **
  @Target { help = "Run the pod unit tests via fant" }
  virtual Void test()
  {
    log.info("test [$podName]")
    log.indent

    fant := Exec.exePath(devHomeDir + `bin/fant`)
    Exec(this, [fant, podName]).run

    log.unindent
  }

//////////////////////////////////////////////////////////////////////////
// Full
//////////////////////////////////////////////////////////////////////////

  **
  ** Run clean, compile, and test
  **
  @Target { help = "Run clean, compile, and test" }
  virtual Void full()
  {
    clean
    compile
    test
  }

}