//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FSlot is the read/write fcode representation of sys::Slot.
**
abstract class FSlot : CSlot, FConst
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FType fparent)
  {
    this.fparent = fparent
  }

//////////////////////////////////////////////////////////////////////////
// CSlot
//////////////////////////////////////////////////////////////////////////

  FPod pod() { fparent.pod }
  override CTypeDef parent() { fparent }
  override Str name() { fparent.fpod.n(nameIndex) }
  override Str qname() { fparent.qname + "." + name }

  FAttr? attr(Str name)
  {
    fattrs.find |a| { fparent.pod.n(a.name) == name }
  }

  override CFacet[]? facets() {
    if (ffacets == null) ffacets = FFacet.decode(fparent.pod, attr(FConst.FacetsAttr))
    return ffacets
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  protected Void writeCommon(OutStream out)
  {
    out.writeI2(nameIndex)
    out.writeI4(flags.and(FlagsMask))
  }

  protected Void readCommon(InStream in)
  {
    nameIndex = in.readU2
    flags     = in.readU4
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FType fparent           // parent type
  override Int flags      // bitmask
  Int nameIndex           // name index
  FAttr[]? fattrs         // meta-data attributes
  FFacet[]? ffacets       // facets

}