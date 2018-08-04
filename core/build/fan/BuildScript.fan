//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

using compiler

**
** BuildScript is the base class for build scripts - it manages
** the command line interface, argument parsing, environment, and
** target execution.
**
** See `docTools::Build` for details.
**
abstract class BuildScript
{

//////////////////////////////////////////////////////////////////////////
// Env
//////////////////////////////////////////////////////////////////////////

  **
  ** Log used for error reporting and tracing
  **
  BuildLog log := BuildLog()

  **
  ** The source file of this script
  **
  File scriptFile {
    protected set {
      &scriptFile = it;
      scriptDir = it.parent
    }
  }

  **
  ** The directory containing the this script
  **
  File scriptDir { private set }

  **
  ** Home directory of development installation.  By default this
  ** value is initialized by 'devHome' config prop, otherwise
  ** `sys::Env.homeDir` is used.
  **
  const File devHomeDir := configDir("devHome", Env.cur.homeDir)

  new make() {
    scriptFile = File(typeof->sourceFile.toStr.toUri).normalize
    scriptDir = scriptFile.parent
  }

//////////////////////////////////////////////////////////////////////////
// Targets
//////////////////////////////////////////////////////////////////////////

  **
  ** Lookup a target by name.  If not found and checked is
  ** false return null, otherwise throw an exception.
  **
  TargetMethod? target(Str name, Bool checked := true)
  {
    t := targets.find |t| { t.name == name }
    if (t != null) return t
    if (checked) throw Err("Target not found '$name' in $scriptFile")
    return null
  }

  **
  ** Get the list of published targets for this script.  The
  ** first target should be the default.  The list of targets
  ** is defined by all the methods with the `Target` facet.
  **
  virtual once TargetMethod[] targets()
  {
    acc := TargetMethod[,]
    typeof.methods.each |m|
    {
      if (!m.hasFacet(Target#)) return
      acc.add(TargetMethod(this, m))
    }
    return acc
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Get a config property using the following rules:
  **   1. `sys::Env.vars` with 'FAN_BUILD_$name.upper'
  **   2. `sys::Env.config` for build pod
  **   3. fallback to 'def' parameter
  **
  Str? config(Str name, Str? def := null)
  {
    Env.cur.vars["FAN_BUILD_$name.upper"] ?:
    Env.cur.config(BuildScript#.pod, name, def)
  }

  **
  ** Get a `config` prop which identifies a directory.
  ** If the prop isn't configured or doesn't map to a
  ** valid directory, then return def.
  **
  File? configDir(Str name, File? def := null)
  {
    c := config(name)
    if (c == null) return def
    try
    {
      f := File(c.toUri)
      if (!f.exists || !f.isDir) throw Err()
      return f
    }
    catch (Err e) log.err("Invalid configDir URI for '$name': $c\n  $e")
    return def
  }

  **
  ** Get the key/value map of config props which are loaded
  ** from "etc/build/config.props".
  **
  once Str:Str configs()
  {
    Env.cur.props(BuildScript#.pod, `config.props`, 10sec).ro
  }

  **
  ** Apply a set of macro substitutions to the given pattern.
  ** Substitution keys are indicated in the pattern using "@{key}"
  ** and replaced by definition in macros map.  If a substitution
  ** key is undefined then raise an exception.  The `configs`
  ** method is used for default macro key/value map.
  **
  Str applyMacros(Str pattern, Str:Str macros := this.configs)
  {
    // short circuit if we don't have @
    at := pattern.index("@")
    if (at == null) return pattern

    // rebuild string
    s := pattern
    for (i:=0; i<s.size-3; ++i)
    {
      if (s[i] == '@' && s[i+1] == '{')
      {
        c := s.index("}", i+2)
        if (c == null) throw Err("Unclosed macro: $pattern")
        key := s[i+2..<c]
        val := macros[key]
        if (val == null) throw Err("Undefined macro key: $key")
        s = s[0..<i] + val + s[c+1..-1]
      }
    }
    return s
  }

  **
  ** Resolve a set of URIs to files relative to scriptDir.
  **
  internal File[] resolveFiles(Uri[] uris)
  {
    uris.map |uri->File|
    {
      f := scriptDir + uri
      if (!f.exists || f.isDir) throw fatal("Invalid file: $uri")
      return f
    }
  }

  **
  ** Resolve a set of URIs to directories relative to scriptDir.
  **
  internal File[] resolveDirs(Uri[] uris)
  {
    uris.map |uri->File|
    {
      f := scriptDir + uri
      if (!f.exists || !f.isDir) throw fatal("Invalid dir: $uri")
      return f
    }
  }

  **
  ** Resolve a set of URIs to files/dirs relative to scriptDir.
  **
  internal File[] resolveFilesOrDirs(Uri[] uris)
  {
    uris.map |uri->File|
    {
      f := scriptDir + uri
      if (!f.exists) throw fatal("Invalid file: $uri")
      return f
    }
  }

  **
  ** Dump script environment for debug.
  **
  virtual Void dumpEnv()
  {
    log.printLine("---------------")
    log.printLine("  scriptFile:    $scriptFile")
    log.printLine("  typeof:        $typeof.base")
    log.printLine("  env.homeDir:   $Env.cur.homeDir")
    log.printLine("  env.workDir:   $Env.cur.workDir")
    log.printLine("  devHomeDir:    $devHomeDir")
    typeof.fields.each |f|
    {
      if (f.isPublic && !f.isStatic && f.parent != BuildScript#)
        log.printLine("  " + (f.name+ ":").padr(14) + " " + f.get(this))
    }
  }

  **
  ** Log an error and return a FatalBuildErr instance
  **
  FatalBuildErr fatal(Str msg, Err? err := null)
  {
    log.err(msg, err)
    return FatalBuildErr(msg, err)
  }

  **
  ** Return this script's source file path.
  **
  override Str toStr()
  {
    return typeof->sourceFile.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Arguments
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse the arguments passed from the command line.
  **
  private TargetMethod[]? parseArgs(Str[] args)
  {
    // check for -? or -dumpEnv
    if (args.contains("-?") || args.contains("-help")) { usage; return null }
    if (args.contains("-dumpEnv")) { dumpEnv; return null }

    success := true
    toRun := TargetMethod[,]

    // get published targetss
    published := targets
    if (published.isEmpty)
    {
      log.err("No targets available for script")
      return null
    }

    // process each argument
    for (i:=0; i<args.size; ++i)
    {
      arg := args[i]
      if (arg == "-v") { log.level = LogLevel.debug; dumpEnv }
      else if (arg.startsWith("-")) log.warn("Unknown build option $arg")
      else
      {
        // add target to our run list
        target := published.find |t| { t.name == arg }
        if (target == null)
        {
          log.err("Unknown build target '$arg'")
          success = false
        }
        else
        {
          toRun.add(target)
        }
      }
    }
    if (!success) return null

    // if no targets specified, then use the default
    if (toRun.isEmpty) toRun.add(published.first)
    return toRun
  }

  **
  ** Dump usage including all this script's published targets.
  **
  private Void usage()
  {
    log.printLine("usage: ")
    log.printLine("  build [options] <target>*")
    log.printLine("options:")
    log.printLine("  -? -help       Print usage summary")
    log.printLine("  -v             Verbose debug logging")
    log.printLine("  -dumpEnv       Debug dump of script env")
    log.printLine("targets:")
    targets.each |t, i|
    {
      n := i == 0 ? "${t.name}*" : "${t.name} "
      log.print("  ${n.justl(14)} $t.help")
      log.printLine
    }
  }

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the script with the specified arguments.
  ** Return 0 on success or -1 on failure.
  **
  Int main(Str[] args := Env.cur.args)
  {
    t1 := TimePoint.now
    success := false
    try
    {
      targetsToRun := parseArgs(args)
      if (targetsToRun == null) return 1
      targetsToRun.each |t| { t.run }
      success = true
    }
    catch (FatalBuildErr err)
    {
      // error should have alredy been logged
    }
    catch (Err err)
    {
      log.err("Internal build error [$toStr]")
      err.trace
    }
    t2 := TimePoint.now

    if (success)
    {
      if (log.level <= LogLevel.info)
        log.out.printLine("BUILD SUCCESS [${(t2-t1).toMillis}ms]!")
    }
    else
    {
      log.out.printLine("BUILD FAILED [${(t2-t1).toMillis}ms]!")
    }
    return success ? 0 : -1
  }

}

