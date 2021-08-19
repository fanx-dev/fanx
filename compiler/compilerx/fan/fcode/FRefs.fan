//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 06  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FTypeRef stores a typeRef structure used to reference type signatures.
**
const class FTypeRef
{

  new make(Int podName, Int typeName, Str sig)
  {
    this.podName  = podName
    this.typeName = typeName
    this.sig      = sig
    this.hashcode = podName.shiftl(17).xor(typeName).xor(sig.hash)
  }

  override Int hash() { hashcode }

  override Bool equals(Obj? obj)
  {
    x := (FTypeRef)obj
    return podName == x.podName && typeName == x.typeName && sig == x.sig
  }

  //Bool isGenericInstance() { sig.size > 1 }

  Str signature(FPod pod)
  {
    return pod.n(podName) + "::" + pod.n(typeName) + sig
  }

  Str format(FPod pod) { signature(pod) }

  Void write(OutStream out)
  {
    out.writeI2(podName)
    out.writeI2(typeName)
    out.writeUtf(sig)
  }

  static FTypeRef read(InStream in)
  {
    return make(in.readU2, in.readU2, in.readUtf)
  }

  const Int podName     // names index
  const Int typeName    // names index
  const Str sig
  const Int hashcode

}

**************************************************************************
** FFieldRef
**************************************************************************

const class FFieldRef
{

  new make(Int parent, Int name, Int typeRef)
  {
    this.parent  = parent
    this.name    = name
    this.typeRef = typeRef
    this.hashcode = parent.shiftl(23).xor(name.shiftl(7)).xor(typeRef)
  }

  override Int hash()
  {
    return hashcode
  }

  override Bool equals(Obj? obj)
  {
    x := (FFieldRef)obj
    return parent == x.parent && name == x.name && typeRef == x.typeRef
  }

  Str format(FPod pod)
  {
    return pod.typeRefStr(parent) + "." + pod.names[name] + " -> " + pod.typeRefStr(typeRef)
  }

  Void write(OutStream out)
  {
    out.writeI2(parent)
    out.writeI2(name)
    out.writeI2(typeRef)
  }

  static FFieldRef read(InStream in)
  {
    return make(in.readU2, in.readU2, in.readU2)
  }

  const Int parent    // typeRefs index
  const Int name      // names index
  const Int typeRef   // typeRefs index
  const Int hashcode
}

**************************************************************************
** FMethodRef
**************************************************************************

const class FMethodRef
{

  new make(Int parent, Int name, Int ret, Int[] params, Int flags)
  {
    this.parent  = parent
    this.name    = name
    this.ret     = ret
    this.params  = params
    this.hashcode = parent.shiftl(23).xor(name.shiftl(7)).xor(ret)
    this.flags = flags
  }

  override Int hash()
  {
    return hashcode
  }

  override Bool equals(Obj? obj)
  {
    x := (FMethodRef)obj
    return parent == x.parent && name == x.name && ret == x.ret && params == x.params
  }

  Str format(FPod pod)
  {
    s := pod.typeRefStr(parent) + "." + pod.names[name] + "("
    params.each |Int p, Int i|
    {
      if (i > 0) s += ", "
      s += pod.typeRefStr(p)
    }
    s += ") -> " + pod.typeRefStr(ret)
    return s
  }

  Void write(OutStream out)
  {
    out.writeI2(parent)
    out.writeI2(name)
    out.writeI2(ret)
    out.write(params.size)
    params.each |Int param| { out.writeI2(param) }
    out.write(flags)
  }

  static FMethodRef read(InStream in)
  {
    parent := in.readU2
    name   := in.readU2
    ret    := in.readU2
    p := Int[,]
    in.readU1.times { p.add(in.readU2) }
    flags := in.readU1
    return make(parent, name, ret, p, flags)
  }

  const Int parent    // typeRefs index
  const Int name      // names index
  const Int ret       // typeRefs index
  const Int[] params  // typeRefs indices
  const Int hashcode
  const Int flags // the orignal method param that include default param
}