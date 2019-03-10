//
// Copyright (c) 2018, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-08-11 Jed Young Creation
//

internal const class CachedScript {
  const TimePoint modified
  const Int size
  const Str typeName

  new make(File file, Type t) {
    modified = file.modified
    size = file.size
    typeName = t.qname
  }
}

internal const class ScriptCompiler {
  const ConcurrentMap<Str,CachedScript> cache := ConcurrentMap(16)
  static const ScriptCompiler cur := ScriptCompiler()

  Type compile(File file, [Str:Obj]? options := null) {
    file = file.normalize
    // unless force=true, check the cache
    if (options == null || !options.get("force", false))
    {
      c := cache.get(file.toStr)
      // if cached, try to lookup type (it might have been GCed)
      if (c != null && c.modified == file.modified && c.size == file.size)
      {
        t := Type.find(c.typeName, false)
        if (t != null) return t
      }
    }

    pod := compileFile(file, options)

    // get the primary type
    t := pod.types.find { it.isPublic }
    if (t == null) throw Err.make("Script file defines no public classes: " +  file)

    cache.set(file.toStr, CachedScript(file, t))
    return t
  }

  private Pod compileFile(File file, [Str:Obj]? options) {
    podName := file.basename + TimePoint.nowUnique
    m := Slot.findMethod("compiler::Main.compileScript", true)
    pod := m.call(podName, file, options)
    return pod
  }

  Int execute(Str fileName, Str[]? args) {
    file := fileName.toUri.toFile

    [Str:Obj]? options := null
    if (args != null && args.any { it == "-fcodeDump" }) {
      options = ["fcodeDump" : true]
    }

    pod := compileFile(file, options)

    // get the primary type
    types := pod.types
    Type? t := null
    Method? m := null
    for (i:=0; i<types.size; ++i) {
      t = types[i]
      m = t.method("main", false)
      if (m != null) break
    }

    if (m == null) {
      Env.cur.err.printLine("ERROR: missing main method: "+pod.types.first.name + ".main")
      return -1
    }

    //call Main
    Obj?[]? funcArgs := null
    if (m.params.size > 0 && args != null && args.size > 0) {
      funcArgs = [args]
    }

    Obj? res := null
    if (m.isStatic) {
      res = m.callList(funcArgs)
    }
    else {
      res = m.callOn(t.make, funcArgs)
    }
    return (res as Int) ?: 0
  }

}

