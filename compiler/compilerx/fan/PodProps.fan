//
// Copyright (c) 2006, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-15 Jed Young Creation
//

**
** PodProps parser
**
class PodProps
{
  ** make from pod build file, and parse all srouce code
  static CompilerInput parseProps(File file) {
    props := file.in.readProps
    podName := props["podName"]
    summary := props.get("summary")
    versionStr := props.get("version")
    
    loc := Loc.makeFile(file)
    pod := PodDef(loc, podName)
    if (versionStr != null) pod.version = Version(versionStr)
    
    Depend[] depends := Depend[,]
    props.get("depends", "").split(',').each { if (it.size>0) depends.add(Depend(it)) }
    pod.depends = depends
    
    
    input := CompilerInput()
    input.podDef = pod
    baseDir := file.uri.parent.toFile
    input.baseDir = baseDir
    input.srcFiles = findAllFiles(baseDir, props.get("srcDirs"), "fan")
    input.resFiles = findAllFiles(baseDir, props.get("resDirs"), null)
    input.jsFiles = findAllFiles(baseDir, props.get("jsDirs"), null)
    
    
    pod.meta["pod.summary"] = summary
    docApi := props.get("docApi", "true") == "true"
    pod.meta["pod.docApi"] = docApi.toStr
    
    pod.meta["pod.native.java"]   = (props.get("jsDirs") != null).toStr
    pod.meta["pod.native.js"]     = (input.jsFiles     != null && !input.jsFiles.isEmpty).toStr

    //get matadata
    getStartsWith("meta.", props, pod.meta)

    //get index
    getStartsWith("index.", props, pod.index)
    
    return input
  }
  
  private static Void getStartsWith(Str str, [Str:Str] props, [Str:Str] map) {
    props.each |v,k| {
      if (k.startsWith(str)) {
        k = k[str.size..-1]
        map[k] = v
      }
    }
  }
  
  private static File[]? findAllFiles(File baseDir, Str? paths, Str? ext) {
    if (paths == null) return null
    dirs := parseDirs(baseDir.uri, paths)
    return findFiles(baseDir, dirs, ext)
  }

  ** list all dir
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
  
  ** search path in dir
  static private Uri[]? parseDirs(Uri baseDir, Str? str) {
    if (str == null) return null
    srcDirs := Uri[,]
    str.split(',').each |d| {
      if (d.endsWith("*")) {
        srcUri := d[0..<-1].toUri
        dirs := allDir(baseDir, srcUri)
        srcDirs.addAll(dirs)
      }
      else {
        srcDirs.add(d.toUri)
      }
    }
    return srcDirs
  }
  
  private static File[] findFiles(File baseDir, Uri[]? uris, Str? ext)
  {
    base := baseDir
    acc := File[,]
    uris?.each |uri|
    {
      f := base + uri
      if (!f.exists) throw ArgErr("Invalid file or directory: $f")
      if (f.isDir)
      {
        f.list.each |kid|
        {
          if (kid.isDir) return
          if (ext == null || kid.ext == ext) acc.add(kid)
        }
      }
      else
      {
        acc.add(f)
      }
    }
    return acc
  }
}
