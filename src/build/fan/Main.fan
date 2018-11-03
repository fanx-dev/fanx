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

  BuildPod? build

  private File? scriptFile

//////////////////////////////////////////////////////////////////////////

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
    build.scriptFile = scriptFile

    build.podName = props.get("podName")
    build.summary = props.get("summary")

    versionStr := props.get("version")
    if (versionStr != null) build.version = Version(versionStr)

    //get depends
    props.get("depends", "").split(',').each { if (it.size>0) build.depends.add(it) }

    //get srcDirs
    build.srcDirs = parseDirs(props.get("srcDirs"))
    build.resDirs = parseDirs(props.get("resDirs"))
    build.javaDirs = parseDirs(props.get("javaDirs"))
    build.jsDirs = parseDirs(props.get("jsDirs"))

    build.compileJs = props.get("compileJs", "false") == "true"

    //echo("srcDirs: $srcDirs resDirs: $resDirs")

    build.docApi = props.get("docApi", "true") == "true"

    //TODO fix ?.
    Str? temp := props.get("dependsDir", null)
    build.dependsDir = temp == null ? null : temp.toUri

    //get outPodDir
    outPodDirStr := props.get("outPodDir", null)
    if (outPodDirStr != null) build.outPodDir = outPodDirStr.toUri
    else {
      devHomeDir := this.typeof.pod.config("devHome")
      if (devHomeDir != null) build.outPodDir = devHomeDir.toUri + `lib/fan/`
      else {
        build.outPodDir = Env.cur.workDir.plus(`lib/fan/`).uri
      }
    }

    //get matadata
    getStartsWith("meta.", props, build.meta)

    //get index
    getStartsWith("index.", props, build.index)
    //echo("meta: $meta, index: $index")
  }

  **
  ** mini build for boost
  **
  virtual Int main(Str[] args)
  {
    build = BuildPod()
    scriptFile = args.first.toUri.toFile.normalize
    props := scriptFile.in.readProps
    parse(props)
    nargs := args.dup
    nargs.removeAt(0)
    return build.main(nargs)
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

}