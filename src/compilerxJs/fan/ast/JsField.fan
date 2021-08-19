//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compilerx

**
** JsField
**
class JsField : JsSlot
{
  new make(JsCompilerSupport s, FieldDef f) : super(s, f)
  {
    this.ftype = JsTypeRef(s, f.fieldType, f.loc)
  }

  override FieldDef? node() { super.node }

  override Void write(JsWriter out)
  {
    if (!isNative)
    {
      defVal := "null"
      if (!ftype.isNullable)
      {
        switch (ftype.qname)
        {
          case "fan.sys.Bool":    defVal = "false"
          case "fan.sys.Decimal": defVal = "fan.sys.Decimal.make(0)"
          case "fan.sys.Float":   defVal = "fan.sys.Float.make(0)"
          case "fan.sys.Int":     defVal = "0"
        }
      }

      out.w(parent, loc)
      if (!isStatic) out.w(".prototype")
      out.w(".m_$name = $defVal;", loc).nl
    }
  }

  JsTypeRef ftype  // field type
}

**************************************************************************
** JsFieldRef
**************************************************************************

**
** JsFieldRef
**
class JsFieldRef : JsSlotRef
{
  new make(JsCompilerSupport s, CField f) : super(s, f) {}
}
