//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   29 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** ReflectNamespace implements Namespace using reflection to
** compile against the VM's current pod repository.
**
class ReflectNamespace : CNamespace
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct a ReflectNamespace
  **
  new make()
  {
    this.pods = Str:ReflectPod[:]
    init
  }

//////////////////////////////////////////////////////////////////////////
// CNamespace
//////////////////////////////////////////////////////////////////////////

  **
  ** Map an imported Pod into a CPod
  **
  protected override ReflectPod? findPod(Str podName)
  {
    // try to load it
    pod := Pod.find(podName, false)
    if (pod == null) return null
    return ReflectPod(this, pod)
  }

//////////////////////////////////////////////////////////////////////////
// Mapping
//////////////////////////////////////////////////////////////////////////

  **
  ** Map an imported Pod into a CPod
  **
  ReflectPod importPod(Pod pod)
  {
    return resolvePod(pod.name, null)
  }

  **
  ** Map an imported Type into a CType
  **
  CType? importType(Type? t)
  {
    if (t == null) return null
    return resolveType(t.signature)
  }

  **
  ** Map a list of imported Types into a CTypes
  **
  CType[] importTypes(Type[] t)
  {
    t.map |Type x->CType| { importType(x) }
  }

  **
  ** Map an imported Slot into a CSlot
  **
  CSlot importSlot(Slot slot)
  {
    if (slot is Method)
      return importMethod((Method)slot)
    else
      return importField((Field)slot)
  }

  **
  ** Map an imported Field into a CField
  **
  CField importField(Field f)
  {
    ReflectField(this, importType(f.parent), f)
  }

  **
  ** Map an imported Method into a CMethod
  **
  CMethod importMethod(Method m)
  {
    ReflectMethod(this, importType(m.parent), m)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Str:ReflectPod pods  // keyed by pod name

}