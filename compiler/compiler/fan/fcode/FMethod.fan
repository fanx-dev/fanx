//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//   19 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FMethod is the read/write fcode representation of sys::Method.
**
class FMethod : FSlot, CMethod
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FType fparent)
    : super(fparent)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  FMethodVar[] fparams()
  {
    return vars.findAll |FMethodVar v->Bool| { v.isParam }
  }

//////////////////////////////////////////////////////////////////////////
// CMethod
//////////////////////////////////////////////////////////////////////////

  override CType returnType() { fparent.fpod.toType(ret) }
  override CParam[] params() { fparams }

  override Str signature()
  {
    return "$returnType $name(" + params.join(",") + ")"
  }

  override once Bool isGeneric()
  {
    return calcGeneric(this)
  }

  override CType inheritedReturnType()
  {
    return fparent.fpod.toType(inheritedRet)
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  Void write(OutStream out)
  {
    super.writeCommon(out)
    out.writeI2(ret)
    out.writeI2(inheritedRet)
    out.write(maxStack)
    out.write(paramCount)
    out.write(localCount)
    vars.each |FMethodVar var_v| { var_v.write(out) }
    FUtil.writeBuf(out, code)
    FUtil.writeAttrs(out, fattrs)
    //genericParams
    out.write(0)
  }

  This read(InStream in)
  {
    super.readCommon(in)
    ret = in.readU2
    inheritedRet = in.readU2
    maxStack   = in.readU1
    paramCount = in.readU1
    localCount = in.readU1
    vars = FMethodVar[,];
    (paramCount+localCount).times { vars.add(FMethodVar(this).read(in, fparent.fpod.fcodeVersion)) }
    code = FUtil.readBuf(in)
    fattrs = FUtil.readAttrs(in)
    //genericParams
    i := in.readU1
    return this
  }

  Void dump()
  {
    p := FPrinter(fparent.fpod)
    p.showCode = true
    p.method(this)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Int ret              // type qname index
  Int inheritedRet     // type qname index
  FMethodVar[]? vars   // parameters and local variables
  Int paramCount       // number of params in vars
  Int localCount       // number of locals in vars
  Buf? code            // method executable code
  Int maxStack := 16   // TODO - need to calculate in compiler

}

**************************************************************************
** FMethodVar
**************************************************************************

**
** FMethodVar models one parameter or local variable in a FMethod
**
class FMethodVar : FConst, CParam
{
  new make(FMethod fmethod) { this.fmethod = fmethod }

  override Str name() { fpod.n(nameIndex) }
  override CType paramType() { fpod.toType(typeRef) }
  override Bool hasDefault() { flags.and(FConst.ParamDefault) != 0 }
  override Str toStr() { "$paramType $name" }

  Bool isParam()  { flags.and(FConst.Param) != 0 }

  Void write(OutStream out)
  {
    out.writeI2(nameIndex)
    out.writeI2(typeRef)
    out.write(flags)
    out.writeI2(startPos)
    out.writeI2(scopeLen)

    // we currently only support the DefaultParam attr
    if (def == null) out.writeI2(0)
    else
    {
      out.writeI2(1)
      out.writeI2(defNameIndex)
      FUtil.writeBuf(out, def)
    }
  }

  FMethodVar read(InStream in, Int version)
  {
    nameIndex = in.readU2
    typeRef   = in.readU2
    flags     = in.readU1

    if (version == 0 || version > 113) {
      startPos  = in.readU2
      scopeLen  = in.readU2
    }

    // we currently only support the DefaultParam attr
    in.readU2.times
    {
      attrNameIndex := in.readU2
      attrBuf  := FUtil.readBuf(in)
      if (fmethod.pod.n(attrNameIndex) == ParamDefaultAttr)
      {
        defNameIndex = attrNameIndex
        def = attrBuf
      }
    }
    return this
  }

  FPod fpod() { fmethod.fparent.fpod }

  FMethod fmethod
  Int nameIndex    // name index
  Int typeRef      // typeRef index
  Int flags        // method variable flags
  Int defNameIndex // name index of DefaultParamAttr
  Buf? def         // default expression or null (only for params)

  Int startPos    //start position in bytecode
  Int scopeLen
}