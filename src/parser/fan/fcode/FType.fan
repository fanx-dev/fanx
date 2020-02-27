//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FType is the read/write fcode representation of sys::Type.
**
class FType : CTypeDef
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FPod fpod)
  {
    this.fpod = fpod
    this.fattrs = FAttr[,]
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override once Loc loc() {
    attr := this.attr(FConst.SourceFileAttr)
    line := this.attr(FConst.LineNumberAttr)
    if (attr == null || line == null) return Loc.makeFile(fpod.file)
    return Loc.make(attr.utf, line.u2)
  }
  
  override DocDef? doc() {
    lines := fpod.apiDoc.typeDoc(name)
    if (lines.isEmpty) return null
    return DocDef(fpod.loc, lines)
  }
  
//  override CNamespace ns() { fpod.ns }
  override FPod pod() { fpod }
  override once Str name() { fpod.n(fpod.typeRef(self).typeName) }
  override once Str qname() { "${fpod.name}::${name}" }
  override once Str extName()   { fpod.typeRef(self).sig }
  //override once Str signature() { "$qname$extName" }

  FAttr? attr(Str name)
  {
    fattrs.find |a| { fpod.n(a.name) == name }
  }
  
  override once CType[] inheritances() {
    res := CType[,]
    base := fpod.toType(fbase)
    if (base != null) res.add(base)
    res.addAll(fpod.resolveTypes(fmixins))
    return res
  }

  override CFacet[]? facets()
  {
    if (ffacets == null) reflect
    return ffacets
  }

//  override once CType toListOf() { ListType(this) }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  private Void reflect()
  {
    // lazy read from the pod file
    read
    
    slotsCached = CSlot[,]

    // map all the declared fields and methods
    ffields.each  |FField f|  { slotsCached.add(f) }
    fmethods.each |FMethod m|
    {
      f := slots[m.name] as FField
      if (f != null)
      {
        // if already mapped to field must be getter/setter
        if (m.flags.and(FConst.Getter) != 0)
          f.getter = m
        else if (m.flags.and(FConst.Setter) != 0)
          f.setter = m
        else
          throw Err("Conflicting slots: $f and $m")
      }
      else if (m.flags.and(FConst.Overload) != 0) {
        //
      }
      else
      {
        slotsCached.add(m)
      }
    }
  }
  
  private CSlot[]? slotsCached
  override CSlot[] slotDefs() {
    if (slotsCached == null) reflect
    return slotsCached
  }

//////////////////////////////////////////////////////////////////////////
// Meta IO
//////////////////////////////////////////////////////////////////////////

  Void writeMeta(OutStream out)
  {
    out.writeI2(self)
    out.writeI2(fbase)
    out.writeI2(fmixins.size)
    fmixins.each |Int m| { out.writeI2(m) }
    out.writeI4(flags.and(FConst.FlagsMask))
    out.write(genericParameters.size)
    genericParameters.each |param| { out.writeI2(fpod.addName(param.paramName)) }
    genericParameters.each |param| { out.writeI2(fpod.addTypeRef(param.bound)) }
  }

  This readMeta(InStream in)
  {
    self    = in.readU2
    fbase   = in.readU2
    fmixins = Int[,]
    in.readU2.times { fmixins.add(in.readU2) }
    flags   = in.readU4

    
    
    genericParamCount := in.readU1
    genericParamCount.times {
      genericParamNames.add(in.readU2)
    }
    genericParamCount.times {
      genericParamBounds.add(in.readU2)
    }
    return this
  }
  
  
  private Int[] genericParamNames := [,]
  private Int[] genericParamBounds := [,]
  override once GenericParamDef[]? genericParameters() {
    res := GenericParamDef[,]
    genericParamNames.size.times |i| {
      n := fpod.n(genericParamNames[i])
      t := fpod.toType(genericParamBounds[i])
      gt := GenericParamDef(Loc.makeUninit, n, this, i, t)
      res.add(gt)
    }
    return res
  }

//////////////////////////////////////////////////////////////////////////
// Body IO
//////////////////////////////////////////////////////////////////////////

  Uri uri()
  {
    return Uri.fromStr("/fcode/" + fpod.n(fpod.typeRef(self).typeName) + ".fcode")
  }

  Void write()
  {
    out := fpod.out(uri)

    out.writeI2(ffields.size)
    ffields.each |FField f| { f.write(out) }

    out.writeI2(fmethods.size)
    fmethods.each |FMethod m| { m.write(out) }

    out.writeI2(fattrs.size)
    fattrs.each |FAttr a| { a.write(out) }

    out.close
  }

  Void read(InStream? in := null)
  {
    if (!hollow) return
    if (in == null) in = fpod.in(uri)

    ffields = FField[,]
    in.readU2.times { ffields.add(FField(this).read(in)) }

    fmethods = FMethod[,]
    in.readU2.times { fmethods.add(FMethod(this).read(in)) }

    fattrs = FAttr[,]
    in.readU2.times { fattrs.add(FAttr.make.read(in)) }

    ffacets = FFacet.decode(fpod, attr(FConst.FacetsAttr))

    in.close

    hollow = false
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override Int flags    // bitmask
  Bool hollow := true   // have we only read meta-data
  FPod fpod             // parent pod
  Int self              // self typeRef index
  Int fbase             // base typeRef index
  Int[]? fmixins        // mixin typeRef indexes
  FField[]? ffields     // fields
  FMethod[]? fmethods   // methods
  FAttr[]? fattrs       // type attributes
  FFacet[]? ffacets     // decoded facet attributes
}