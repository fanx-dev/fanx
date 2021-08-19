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
class FType : CType
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

  override CNamespace ns() { fpod.ns }
  override FPod pod() { fpod }
  override once Str name() { fpod.n(fpod.typeRef(self).typeName) }
  override once Str qname() { "${fpod.name}::${name}" }
  override once Str extName()   { fpod.typeRef(self).sig }
  //override once Str signature() { "$qname$extName" }

  FAttr? attr(Str name)
  {
    fattrs.find |a| { fpod.n(a.name) == name }
  }

  override CType? base
  {
    get
    {
      if (&base == null) &base = fpod.toType(fbase)
      return &base
    }
  }

  override once CType[] mixins()
  {
    return fpod.resolveTypes(fmixins)
  }

  /*override once Bool isVal()
  {
    return isValType(qname)
  }*/

  override CFacet? facet(Str qname)
  {
    if (ffacets == null) reflect
    return ffacets.find |f| { f.qname == qname }
  }

  override Str:CSlot slots()
  {
    if (slotsCached == null) reflect
    return slotsCached
  }
  private [Str:CSlot]? slotsCached

  override once COperators operators() { COperators(this) }

  override Bool isNullable() { false }

  override once CType toNullable() { NullableType(this) }

  override Bool isGeneric()
  {
    return genericParams.size > 0
  }

  override Bool isParameterized() { false }

  override Bool hasGenericParameter() { false }

  override GenericParameter? getGenericParameter(Str name) {
    if (genericParams.size == 0) return null
    return genericParameters[name]
  }

  private once [Str:GenericParameter] genericParameters() {
    res := [Str:GenericParameter][:]
    genericParams.size.times |i| {
      n := fpod.n(genericParams[i])
      t := fpod.toType(genericParamBounds[i])
      gt := GenericParameter(ns, n, this, i, t)
      res[n] = gt
    }
    return res
  }

  override once CType toListOf() { ListType(this) }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  private Void reflect()
  {
    // lazy read from the pod file
    read

    // map all the declared fields and methods
    slotsCached = Str:CSlot[:]
    ffields.each  |FField f|  { slots[f.name] = f }
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
        slotsCached[m.name] = m
      }
    }

    // inherited slots
    if (base != null) inherit(base)
    mixins.each |CType t| { inherit(t) }
  }

  private Void inherit(CType t)
  {
    t.slots.each |CSlot newSlot|
    {
      // if slot already mapped, skip it
      if (slotsCached[newSlot.name] != null) return

      // we never inherit constructors, private slots,
      // or internal slots outside of the pod
      if (newSlot.isCtor || newSlot.isPrivate || newSlot.isStatic ||
          (newSlot.isInternal && newSlot.parent.pod != t.pod))
        return

      // inherit it
      slotsCached[newSlot.name] = newSlot
    }
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
    out.write(genericParams.size)
    genericParams.each |param| { out.writeI2(param) }
    genericParamBounds.each |t| { out.writeI2(t) }
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
      genericParams.add(in.readU2)
    }
    genericParamCount.times {
      genericParamBounds.add(in.readU2)
    }
    return this
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
  Int[] genericParams := [,]
  Int[] genericParamBounds := [,]
}