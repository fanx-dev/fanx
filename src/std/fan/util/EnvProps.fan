//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-7-29 Jed Young Creation
//

internal class EnvProps {
  Uri:FileProps cache := [:]
  Lock lock := Lock()

  Str:Str get(Pod pod, Uri path, Duration maxAge) {
    lock.sync |->Obj| {
      return getUnSafe(pod, path, maxAge)
    }
  }

  internal Str:Str getUnSafe(Pod pod, Uri path, Duration maxAge) {
    uri := `etc/$pod.name/$path`
    FileProps? props := cache.get(uri)

    if (props == null || TimePoint.now - props.readTime > maxAge) {
      File[] files := getFiles(pod, path, uri)
      if (props != null) {
        if (!props.isStale(files)) {
          return props.props
        }
      }
      props = FileProps()
      props.loadAll(files)
      cache[uri] = props
    }
    return props.props
  }

  private File[] getFiles(Pod pod, Uri path, Uri uri) {
    File[] files := Env.cur.findAllFiles(uri)
    File? f := pod.file(`/${path}`, false)
    if (f != null) {
      files.add(f)
    }
    //echo("$uri => $files")
    return files
  }
}

internal class FileProps {
  Str:Str props := [:]
  TimePoint readTime
  TimePoint[]? modified

  new make() {
    readTime = TimePoint.now
  }

  Void loadAll(File[] files) {
    modified = TimePoint[,]
    Str:Str props := [:]
    files.each |f| {
      load(props, f)
      modified.add(f.modified)
    }
    this.props = props.toImmutable
  }

  Bool isStale(File[] x)
  {
    if (modified.size != x.size) return true
    for (Int i:=0; i<x.size; ++i) {
      if (modified[i] != x[i].modified) return true
    }
    return false
  }

  internal static Void load(Str:Str props, File f) {
    try {
      Str:Str t := Props.readProps(f.in)
      //echo(t)
      //echo(f.readAllStr)
      t.each |v,k| {
        if (props.containsKey(k)) return
        props.set(k, v)
      }
    } catch (Err e) {
      Env.cur.err.printLine("ERROR: Cannot load props " + f);
      Env.cur.err.printLine("  " + e);
    }
  }
}

