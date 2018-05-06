//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FField is the read/write fcode representation of sys::Field.
**
class FField : FSlot, CField
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FType fparent)
    : super(fparent)
  {
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  Void write(OutStream out)
  {
    super.writeCommon(out)
    out.writeI2(typeRef)
    FUtil.writeAttrs(out, fattrs)
  }

  This read(InStream in)
  {
    super.readCommon(in)
    typeRef = in.readU2
    fattrs = FUtil.readAttrs(in)
    return this
  }

//////////////////////////////////////////////////////////////////////////
// CField
//////////////////////////////////////////////////////////////////////////

  override Str signature()
  {
    return "$fieldType $name"
  }

  override CType fieldType()
  {
    return fparent.fpod.toType(typeRef)
  }

  override CType inheritedReturnType()
  {
    if (!isOverride || getter == null) return fieldType
    else return getter.inheritedReturnType
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Int typeRef     // typeRef index
  override CMethod? getter
  override CMethod? setter

}