//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FAttr is attribute meta-data for a FType or FSlot
**
class FAttr : FConst
{

//////////////////////////////////////////////////////////////////////////
// Data
//////////////////////////////////////////////////////////////////////////

  Str utf() { data.seek(0).readUtf }

  Int u2() { data.seek(0).readU2 }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  Void write(OutStream out)
  {
    out.writeI2(name)
    FUtil.writeBuf(out, data)
  }

  FAttr read(InStream in)
  {
    name  = in.readU2
    data  = FUtil.readBuf(in)
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Int name    // name index
  Buf? data
}

**************************************************************************
** FFacet
**************************************************************************

class FFacet : CFacet
{
  static FFacet[] decode(FPod fpod, FAttr? attr)
  {
    if (attr == null) return List.defVal//FFacet#.emptyList
    num := attr.data.seek(0).readU2
    ffacets := FFacet[,]; ffacets.capacity = num
    num.times
    {
      qname := fpod.typeRef(attr.data.readU2).signature(fpod)
      val   := attr.data.readUtf
      ffacets.add(FFacet(qname, val))
    }
    return ffacets
  }

  new make(Str qn, Str v) { qname = qn; val = v }
  override const Str qname
  override Str toStr() { val.isEmpty ? qname : val }
  override Obj? get(Str name)
  {
    // this is a bit hackish and doesn't handle default
    // values but should work for simple cases like "msg"
    try
    {
      s := val.index(name) + name.size + 1  // name=xxx
      e := val.index(";", s+1) ?: val.size-1
      v := val[s..<e]
      return v.in.readObj
    }
    catch {}
    return null
  }
  const Str val
}