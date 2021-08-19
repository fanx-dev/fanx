//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

**
** BuildGroup is the base class for build scripts which compose
** a set of children build scripts into a single group.  The
** target's of a BuildGroup are the union of the target
** names available in the children scripts.
**
abstract class BuildGroup : BuildScript
{

  **
  ** Required list of Uris relative to this scriptDir of
  ** Fantom build script files to group together.
  **
  Uri[] childrenScripts := Uri[,]

  **
  ** Compiled children scripts
  **
  once BuildScript[] children()
  {
    acc := BuildScript[,]
    childrenScripts.each |uri|
    {
      f := scriptDir + uri
      log.debug("CompileScript [$f]")
      s := (BuildScript)FanScript(this, f).compile.types.first.make
      s.log = log
      acc.add(s)
    }
    return acc
  }

  **
  ** BuildGroup publishes the union by name of it's
  ** children script targets plus any of its own targets.
  **
  override once TargetMethod[] targets()
  {
    // get union of names in my children scripts
    Str[]? names := null
    children.each |child|
    {
      // get all the target names in this subscript
      Str[] n := child.targets.map |t| { t.name }

      // get union of names
      if (names == null)
        names = n
      else
        names = names.union(n)
    }

    // map names to group targets
    map := OrderedMap<Str,TargetMethod>()//[:] { ordered = true }
    names.each |n| { map[n] = GroupTarget(this, n) }

    // add my own targets, which trump children targets
    this.typeof.methods.each |m|
    {
      if (!m.hasFacet(Target#)) return
      map[m.name] = TargetMethod(this, m)
    }

    // now create a Target for each name
    list := map.vals
    list.moveTo(map["compile"], 0)
    return list
  }

  **
  ** Run the specified target name on each of the
  ** children scripts that support the specified name.
  **
  virtual Void runOnChildren(Str targetName)
  {
    children.each |child|
    {
      target := child.target(targetName, false)
      if (target != null) target.run
    }
  }

  **
  ** Run the specified target name on each of the children
  ** scripts that support the specified name.  Unlike runOnChildren
  ** this method actually spawns a new process to run the child
  ** script.
  **
  virtual Void spawnOnChildren(Str targetName)
  {
    fanExe := Exec.exePath(devHomeDir + `bin/fan`)
    children.each |child|
    {
      target := child.target(targetName)
      if (target != null)
        Exec(this, [fanExe, child.scriptFile.osPath, targetName]).run
    }
  }

  override Void dumpEnv()
  {
    super.dumpEnv
    children.each |child| { child.dumpEnv }
  }
}

internal class GroupTarget : TargetMethod
{
  new make(BuildGroup s, Str n) : super(s, BuildGroup#runOnChildren) { name = n }
  override const Str name
  override Str help() { "Run '$name' on group" }
  override Void run() { ((BuildGroup)script).runOnChildren(name) }
}