
**************************************************************************
** LiteralExpr
**************************************************************************

**
** LiteralExpr puts an Bool, Int, Float, Str, Duration, Uri,
** or null constant onto the stack.
**
class LiteralExpr : Expr
{
  new make(Loc loc, ExprId id, Obj? val)
    : super(loc, id)
  {
    this.val   = val
//    if (val == null && !ctype.isNullable)
//      throw Err("null literal must typed as nullable!")
  }

  new makeNull(Loc loc)
    : this.make(loc, ExprId.nullLiteral, null) {}

  new makeTrue(Loc loc)
    : this.make(loc, ExprId.trueLiteral, true) {}

  new makeFalse(Loc loc)
    : this.make(loc, ExprId.falseLiteral, false) {}

  new makeStr(Loc loc, Str val)
    : this.make(loc, ExprId.strLiteral, val) {}

  static LiteralExpr makeDefaultLiteral(Loc loc, CType ctype)
  {
    LiteralExpr? literal
    if (!ctype.isNullable)
    {
      if (ctype.isBool())  literal = make(loc, ExprId.falseLiteral, false)
      if (ctype.isInt())   literal = make(loc, ExprId.intLiteral, 0)
      if (ctype.isFloat()) literal = make(loc, ExprId.floatLiteral, 0f)
      literal.ctype = ctype
      return literal
    }
    literal = makeNull(loc)
    literal.ctype = ctype
    return literal
  }

  override Bool isAlwaysNullable() { id === ExprId.nullLiteral }

  override Int? asTableSwitchCase()
  {
    return val as Int
  }

//  override Str serialize()
//  {
//    switch (id)
//    {
//      case ExprId.nullLiteral:     return "null"
//      case ExprId.falseLiteral:    return "false"
//      case ExprId.trueLiteral:     return "true"
//      case ExprId.intLiteral:      return val.toStr
//      case ExprId.floatLiteral:    return val.toStr + "f"
//      case ExprId.decimalLiteral:  return val.toStr + "d"
//      case ExprId.strLiteral:      return val.toStr.toCode
//      case ExprId.uriLiteral:      return val.toStr.toCode('`')
//      case ExprId.typeLiteral:     return "${val->signature}#"
//      case ExprId.durationLiteral: return val.toStr
//      default:                     return super.serialize
//    }
//  }

  override Str toStr()
  {
    switch (id)
    {
      case ExprId.nullLiteral: return "null"
      case ExprId.strLiteral:  return "\"" + val.toStr.replace("\n", "\\n") + "\""
      case ExprId.typeLiteral: return "${val}#"
      case ExprId.uriLiteral:  return "`$val`"
      default: return val.toStr
    }
  }

  Obj? val // Bool, Int, Float, Str (for Str/Uri), Duration, CType, or null
}

**************************************************************************
** LocaleLiteralExpr
**************************************************************************

**
** LocaleLiteralExpr: podName::key=defVal
**
class LocaleLiteralExpr: Expr
{
  new make(Loc loc, Str pattern)
    : super(loc, ExprId.localeLiteral)
  {
    this.pattern = pattern
    this.key = pattern
    eq := pattern.index("=")
    if (eq != null)
    {
      this.key = pattern[0..<eq]
      this.def = pattern[eq+1..-1]
    }

    colons := key.index("::")
    if (colons != null)
    {
      this.podName = key[0..<colons]
      this.key     = key[colons+2..-1]
    }
  }

  override Str toStr() { "<${pattern}>" }

  Str pattern
  Str key
  Str? podName
  Str? def
}

**************************************************************************
** SlotLiteralExpr
**************************************************************************

**
** SlotLiteralExpr
**
class SlotLiteralExpr : Expr
{
  new make(Loc loc, TypeRef parent, Str name)
    : super(loc, ExprId.slotLiteral)
  {
    this.parent = parent
    this.name = name
  }

//  override Str serialize() { "$parent.signature#${name}" }

  override Str toStr() { "$parent#${name}" }

  TypeRef parent
  Str name
  CSlot? slot
}

**************************************************************************
** RangeLiteralExpr
**************************************************************************

**
** RangeLiteralExpr creates a Range instance
**
class RangeLiteralExpr : Expr
{
  new make(Loc loc, Expr start, Expr end, Bool exclusive)
    : super(loc, ExprId.rangeLiteral)
  {
//    this.ctype = ctype
    this.start = start
    this.end   = end
    this.exclusive = exclusive
  }

  override Void walkChildren(Visitor v)
  {
    start = start.walk(v)
    end   = end.walk(v)
  }

  override Str toStr()
  {
    if (exclusive)
      return "${start}...${end}"
    else
      return "${start}..${end}"
  }

  Expr start
  Expr end
  Bool exclusive
}

**************************************************************************
** ListLiteralExpr
**************************************************************************

**
** ListLiteralExpr creates a List instance
**
class ListLiteralExpr : Expr
{
  new make(Loc loc, TypeRef? explicitType := null)
    : super(loc, ExprId.listLiteral)
  {
    this.explicitType = explicitType
  }

  new makeFor(Loc loc, TypeRef explicitType, Expr[] vals)
    : super.make(loc, ExprId.listLiteral)
  {
    this.explicitType = explicitType
    this.vals  = vals
  }

  override Void walkChildren(Visitor v)
  {
    vals = walkExprs(v, vals)
  }

//  override Str serialize()
//  {
//    return format |Expr e->Str| { e.serialize }
//  }

  override Str toStr()
  {
    return format |Expr e->Str| { e.toStr }
  }

  Str format(|Expr e->Str| f)
  {
    s := StrBuf.make
    if (explicitType != null) s.add(explicitType)
    s.add("[")
    if (vals.isEmpty) s.add(",")
    else vals.each |Expr v, Int i|
    {
      if (i > 0) s.add(",")
      s.add(f(v))
    }
    s.add("]")
    return s.toStr
  }

  TypeRef? explicitType
  Expr[] vals := Expr[,]
}

**************************************************************************
** MapLiteralExpr
**************************************************************************

**
** MapLiteralExpr creates a List instance
**
class MapLiteralExpr : Expr
{
  new make(Loc loc, TypeRef? explicitType := null)
    : super(loc, ExprId.mapLiteral)
  {
    this.explicitType = explicitType
  }

  override Void walkChildren(Visitor v)
  {
    keys = walkExprs(v, keys)
    vals = walkExprs(v, vals)
  }

//  override Str serialize()
//  {
//    return format |Expr e->Str| { e.serialize }
//  }

  override Str toStr()
  {
    return format |Expr e->Str| { e.toStr }
  }

  Str format(|Expr e->Str| f)
  {
    s := StrBuf.make
    if (explicitType != null) s.add(explicitType)
    s.add("[")
    if (vals.isEmpty) s.add(":")
    else
    {
      keys.size.times |Int i|
      {
        if (i > 0) s.add(",")
        s.add(f(keys[i])).add(":").add(f(vals[i]))
      }
    }
    s.add("]")
    return s.toStr
  }

  TypeRef? explicitType
  Expr[] keys := Expr[,]
  Expr[] vals := Expr[,]
}