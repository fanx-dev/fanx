//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jun 06  Brian Frank  Creation
//

**
** ReflectPod is the CPod wrapper for a dependent Pod loaded via reflection.
**
class ReflectPod : CPod
{

  new make(ReflectNamespace ns, Pod pod)
  {
    this.ns = ns
    this.pod = pod
  }

  override ReflectNamespace ns { private set }

  override Str name() { pod.name }

  override Version version() { pod.version }

  override once CDepend[] depends() { CDepend.makeList(pod.depends) }

  override once File file() { Env.cur.findPodFile(name) }

  override CType[] types()
  {
    if (!loadedAllTypes)
    {
      loadedAllTypes = true
      pod.types.each |Type t| { resolveType(t.name, true) }
    }
    return typeMap.vals
  }

  override ReflectType? resolveType(Str typeName, Bool checked)
  {
    // check cache first
    rt := typeMap[typeName]
    if (rt != null) return rt

    // use reflection
    t := pod.type(typeName, checked)
    if (t == null) return null

    // make ReflectType and add to both
    // my own and my namespace cache
    rt = ReflectType(ns, t)
    typeMap[typeName] = rt
    ns.typeCache[t.signature] = rt
    return rt
  }

  Pod pod { private set }
  private Str:ReflectType typeMap := Str:ReflectType[:]
  private Bool loadedAllTypes := false

}