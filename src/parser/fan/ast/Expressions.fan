

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

//  static LiteralExpr makeDefaultLiteral(Loc loc, TypeRef ctype)
//  {
//    if (!ctype.isNullable())
//    {
//      if (ctype.isBool())  return make(loc, ExprId.falseLiteral, false)
//      if (ctype.isInt())   return make(loc, ExprId.intLiteral, 0)
//      if (ctype.isFloat()) return make(loc, ExprId.floatLiteral, 0f)
//    }
//    return makeNull(loc, ns)
//  }

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

**************************************************************************
** UnaryExpr
**************************************************************************

**
** UnaryExpr is used for unary expressions including !, +.
** Note that - is mapped to negate() as a shortcut method.
**
class UnaryExpr : Expr
{
  new make(Loc loc, ExprId id, Token opToken, Expr operand)
    : super(loc, id)
  {
    this.opToken = opToken
    this.operand = operand
  }

  override Void walkChildren(Visitor v)
  {
    operand = operand.walk(v)
  }

  override Str toStr()
  {
    if (id == ExprId.cmpNull)
      return operand.toStr + " == null"
    else if (id == ExprId.cmpNotNull)
      return operand.toStr + " != null"
    else
      return opToken.toStr + operand.toStr
  }

  Token opToken   // operator token type (Token.bang, etc)
  Expr operand    // operand expression

}

**************************************************************************
** BinaryExpr
**************************************************************************

**
** BinaryExpr is used for binary expressions with a left hand side and a
** right hand side including assignment.  Note that many common binary
** operations are actually modeled as ShortcutExpr to enable method based
** operator overloading.
**
class BinaryExpr : Expr
{
  new make(Expr lhs, Token opToken, Expr rhs)
    : super(lhs.loc, tokenToExprId(opToken))
  {
    this.lhs = lhs
    this.opToken = opToken
    this.rhs = rhs
  }

  new makeAssign(Expr lhs, Expr rhs, Bool leave := false)
    : this.make(lhs, Token.assign, rhs)
  {
//    this.ctype = lhs.ctype
    this.leave = leave
  }

  override Obj? assignTarget() { id === ExprId.assign ? lhs : null }

  override Bool isStmt() { id === ExprId.assign }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f)
  {
    if (id === ExprId.assign && f(lhs)) return true
    return rhs.isDefiniteAssign(f)
  }

  override Void walkChildren(Visitor v)
  {
    lhs = lhs.walk(v)
    rhs = rhs.walk(v)
  }

//  override Str serialize()
//  {
//    if (id === ExprId.assign)
//      return "${lhs.serialize}=${rhs.serialize}"
//    else
//      return super.serialize
//  }

  override Str toStr()
  {
    return "($lhs $opToken $rhs)"
  }

  Token opToken      // operator token type (Token.and, etc)
  Expr lhs           // left hand side
  Expr rhs           // right hand side
  MethodVar? tempVar // temp local var to store field assignment leaves

}

**************************************************************************
** CondExpr
**************************************************************************

**
** CondExpr is used for || and && short-circuit boolean conditionals.
**
class CondExpr : Expr
{
  new make(Expr first, Token opToken)
    : super(first.loc, tokenToExprId(opToken))
  {
    this.opToken = opToken
    this.operands = [first]
  }

  override Bool isCond() { true }

  override Void walkChildren(Visitor v)
  {
    operands = walkExprs(v, operands)
  }

  override Str toStr()
  {
    return operands.join(" $opToken ")
  }

  Token opToken      // operator token type (Token.and, etc)
  Expr[] operands    // list of operands

}

**************************************************************************
** NameExpr
**************************************************************************

**
** NameExpr is the base class for an identifier expression which has
** an optional base expression.  NameExpr is the base class for
** UnknownVarExpr and CallExpr which are resolved via CallResolver
**
abstract class NameExpr : Expr
{
  new make(Loc loc, ExprId id, Expr? target, Str? name)
    : super(loc, id)
  {
    this.target = target
    this.name   = name
    this.isSafe = false
  }

  override Bool isAlwaysNullable() { isSafe }

  override Void walkChildren(Visitor v)
  {
    target = walkExpr(v, target)
  }

  override Str toStr()
  {
    if (target != null)
      return target.toStr + (isSafe ? "?." : ".") + name
    else
      return name
  }

  Expr? target  // base target expression or null
  Str? name     // name of variable (local/field/method)
  Bool isSafe   // if ?. operator
}

**************************************************************************
** UnknownVarExpr
**************************************************************************

**
** UnknownVarExpr is a place holder in the AST for a variable until
** we can figure out what it references: local or slot.  We also use
** this class for storage operators before they are resolved to a field.
**
class UnknownVarExpr : NameExpr
{
  new make(Loc loc, Expr? target, Str name, ExprId id := ExprId.unknownVar)
    : super(loc, id, target, name)
  {
  }
}

**************************************************************************
** CallExpr
**************************************************************************

**
** CallExpr is a method call.
**
class CallExpr : NameExpr
{
  new make(Loc loc, Expr? target := null, Str? name := null, ExprId id := ExprId.call)
    : super(loc, id, target, name)
  {
    args = Expr[,]
    isDynamic = false
    isCheckedCall = true
    isSafe = false
    isCtorChain = false
  }

//  new makeWithMethod(Loc loc, Expr? target, CMethod method, Expr[]? args := null)
//    : this.make(loc, target, method.name, ExprId.call)
//  {
//    this.method = method
//    this.ctype = method.isCtor ? method.parent : method.returnType
//    if (args != null) this.args = args
//  }

  override Str toStr()
  {
    return toCallStr(true)
  }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f)
  {
    if (target != null && target.isDefiniteAssign(f)) return true
    return args.any |Expr arg->Bool| { arg.isDefiniteAssign(f) }
  }

//  override Bool isStmt()
//  {
//    // stand alone constructor is not a valid stmt
//    if (method.isCtor) return false
//
//    // with block applied to stand alone constructor is not valid stmt
//    if (method.name == "with" && target is CallExpr && ((CallExpr)target).method.isCtor)
//      return false
//
//    // consider any other call a stand alone stmt
//    return true
//  }

  virtual Bool isCompare() { false }

  override Void walkChildren(Visitor v)
  {
    target = walkExpr(v, target)
    args = walkExprs(v, args)
  }

//  override Str serialize()
//  {
//    // only serialize a true Type("xx") expr which maps to Type.fromStr
//    if (id != ExprId.construction || method.name != "fromStr")
//      return super.serialize
//
//    argSer := args.join(",") |Expr e->Str| { e.serialize }
//    return "$method.parent($argSer)"
//  }

  override Void print(AstWriter out)
  {
    out.w(toCallStr(false))
    if (args.size > 0 && args.last is ClosureExpr)
      args.last.print(out)
  }

  private Str toCallStr(Bool isToStr)
  {
    s := StrBuf.make

    if (target != null)
    {
      s.add(target).add(isSafe ? "?" : "").add(isDynamic ? "->" : ".")
    }
//    else if (method != null && (method.isStatic || method.isCtor))
//      s.add(method.parent.qname).add(".")

    s.add(name).add("(")
    if (args.last is ClosureExpr)
    {
      s.add(args[0..-2].join(", ")).add(") ");
      if (isToStr) s.add(args.last)
    }
    else
    {
      s.add(args.join(", ")).add(")")
    }
    return s.toStr
  }

  Expr[] args         // Expr[] arguments to pass
  [Int:Str]? paramNames  // args pos to name for named param
  Bool isDynamic      // true if this is a -> dynamic call
  Bool isCheckedCall  // true if this is a ~> dynamic call
  Bool isCtorChain    // true if this is MethodDef.ctorChain call
  Bool noParens       // was this call accessed without parens
  Bool isCallOp       // was this 'target()' (instead of 'target.name()')
  Bool isItAdd        // if using comma operator
//  CMethod? method     // resolved method
  override Bool synthetic := false
}

**************************************************************************
** ShortcutExpr
**************************************************************************

**
** ShortcutExpr is used for operator expressions which are a shortcut
** to a method call:
**   a + b     =>  a.plus(b)
**   a - b     =>  a.minus(b)
**   a * b     =>  a.mult(b)
**   a / b     =>  a.div(b)
**   a % b     =>  a.mod(b)
**   a[b]      =>  a.get(b)
**   a[b] = c  =>  a.set(b, c)
**   -a        =>  a.negate()
**   ++a, a++  =>  a.increment()
**   --a, a--  =>  a.decrement()
**   a == b    =>  a.equals(b)
**   a != b    =>  ! a.equals(b)
**   a <=>     =>  a.compare(b)
**   a > b     =>  a.compare(b) > 0
**   a >= b    =>  a.compare(b) >= 0
**   a < b     =>  a.compare(b) < 0
**   a <= b    =>  a.compare(b) <= 0
**
class ShortcutExpr : CallExpr
{
  new makeUnary(Loc loc, Token opToken, Expr operand)
    : super.make(loc, null, null, ExprId.shortcut)
  {
    this.op      = tokenToShortcutOp(opToken, 1)
    this.opToken = opToken
    this.name    = op.methodName
    this.target  = operand
  }

  new makeBinary(Expr lhs, Token opToken, Expr rhs)
    : super.make(lhs.loc, null, null, ExprId.shortcut)
  {
    this.op      = tokenToShortcutOp(opToken, 2)
    this.opToken = opToken
    this.name    = op.methodName
    this.target  = lhs
    this.args.add(rhs)
  }

  new makeGet(Loc loc, Expr target, Expr index)
    : super.make(loc, null, null, ExprId.shortcut)
  {
    this.op      = ShortcutOp.get
    this.opToken = Token.lbracket
    this.name    = op.methodName
    this.target  = target
    this.args.add(index)
  }

  new makeFrom(ShortcutExpr from)
    : super.make(from.loc, null, null, ExprId.shortcut)
  {
    this.op      = from.op
    this.opToken = from.opToken
    this.name    = from.name
    this.target  = from.target
    this.args    = from.args
    this.isPostfixLeave = from.isPostfixLeave
  }

  override Bool assignRequiresTempVar() { isAssignable }

  override Obj? assignTarget() { isAssign ? target : null }

  override Bool isAssignable() { op === ShortcutOp.get }

  override Bool isCompare() { op === ShortcutOp.eq || op === ShortcutOp.cmp }

  override Bool isStmt() { isAssign || op === ShortcutOp.set }

  Bool isAssign() { opToken.isAssign || opToken.isIncrementOrDecrement }

//  Bool isStrConcat() { opToken == Token.plus && args.size == 1 && target.ctype.isStr }

  override Str toStr()
  {
    if (op == ShortcutOp.get) return "${target}[$args.first]"
    if (op == ShortcutOp.increment) return isPostfixLeave ? "${target}++" : "++${target}"
    if (op == ShortcutOp.decrement) return isPostfixLeave ? "${target}--" : "--${target}"
    if (isAssign) return "${target} ${opToken} ${args.first}"
    if (op.degree == 1) return "${opToken}${target}"
    if (op.degree == 2) return "(${target} ${opToken} ${args.first})"
    return super.toStr
  }

  override Void print(AstWriter out)
  {
    out.w(toStr())
  }

  ShortcutOp op
  Token opToken
  Bool isPostfixLeave := false  // x++ or x-- (must have Expr.leave set too)
  MethodVar? tempVar    // temp local var to store += to field/indexed
}

**
** IndexedAssignExpr is a subclass of ShortcutExpr used
** in situations like x[y] += z where we need keep of two
** extra scratch variables and the get's matching set method.
** Note this class models the top x[y] += z, NOT the get target
** which is x[y].
**
** In this example, IndexedAssignExpr shortcuts Int.plus and
** its target shortcuts List.get:
**   x := [2]
**   x[0] += 3
**
class IndexedAssignExpr : ShortcutExpr
{
  new makeFrom(ShortcutExpr from)
    : super.makeFrom(from)
  {
  }

  MethodVar? scratchA
  MethodVar? scratchB
//  CMethod? setMethod
}

**************************************************************************
** FieldExpr
**************************************************************************

**
** FieldExpr is used for a field variable access.
**
class FieldExpr : NameExpr
{
  new make(Loc loc, Expr? target, Str name, Bool useAccessor := true)
    : super(loc, ExprId.field, target, null)
  {
    this.useAccessor = useAccessor
    this.isSafe = false
    this.name = name
  }

  override Bool isAssignable() { true }

//  override Bool assignRequiresTempVar() { !field.isStatic }

//  override Bool sameVarAs(Expr that)
//  {
//    x := that as FieldExpr
//    if (x == null) return false
//    return field == x.field &&
//           target != null &&
//           x.target != null &&
//           target.sameVarAs(x.target)
//  }

//  override Int? asTableSwitchCase()
//  {
//    // TODO - this should probably be tightened up if we switch to const
//    if (field.isStatic && field.parent.isEnum && ctype.isEnum)
//    {
//      ordinal := field.enumOrdinal
//      if (ordinal == -1) throw Err("Invalid field for tableswitch: $field.typeof $loc.toLocStr")
//      return ordinal
////      
////      switch (field.typeof)
////      {
////        //case ReflectField#:
////        //  ifield := field as ReflectField
////        //  return ((Enum)ifield.f.get).ordinal
////        case FieldDef#:
////          fieldDef := field as FieldDef
////          enumDef := fieldDef.parentDef.enumDef(field.name)
////          if (enumDef != null) return enumDef.ordinal
////        case FField#:
////          ffield := field as FField
////          attr := ffield.attr(FConst.EnumOrdinalAttr)
////          if (attr != null) return attr.u2
////        default:
////          throw Err("Invalid field for tableswitch: $field.typeof $loc.toLocStr")
////      }
//    }
//    return null
//  }
//
//  override Str serialize()
//  {
//    if (field.isStatic)
//    {
//      if (field.parent.isFloat)
//      {
//        switch (name)
//        {
//          case "nan":    return "sys::Float(\"NaN\")"
//          case "posInf": return "sys::Float(\"INF\")"
//          case "negInf": return "sys::Float(\"-INF\")"
//        }
//      }
//
//      if (field.isEnum)
//        return "${field.parent.qname}(\"$name\")"
//    }
//
//    return super.serialize
//  }

  override Str toStr()
  {
    s := StrBuf.make
    if (target != null) s.add(target).add(".");
    if (!useAccessor) s.add("@")
    s.add(name)
    return s.toStr
  }

//  CField? field       // resolved field
//  Str name
  Bool useAccessor    // false if access using '*' storage operator
}

**************************************************************************
** LocalVarExpr
**************************************************************************

**
** LocalVarExpr is used to access a local variable stored in a register.
**
class LocalVarExpr : Expr
{
  new make(Loc loc, MethodVar? var_v, ExprId id := ExprId.localVar)
    : super(loc, id)
  {
    if (var_v != null)
    {
      this.var_v = var_v
//      this.ctype = var_v.ctype
    }
  }

  static LocalVarExpr makeNoUnwrap(Loc loc, MethodVar var_v)
  {
    self := make(loc, var_v, ExprId.localVar)
    self.unwrap = false
    return self
  }

  override Bool isAssignable() { true }

  override Bool assignRequiresTempVar() { var_v.usedInClosure }

  override Bool sameVarAs(Expr that)
  {
    x := that as LocalVarExpr
    if (x == null) return false
    if (var_v?.usedInClosure != x?.var_v?.usedInClosure) return false
    return register == x.register
  }

  virtual Int register() { var_v.register }

  override Str toStr()
  {
    if (var_v == null) return "???"
    return var_v.name
  }

  MethodVar? var_v        // bound variable
  Bool unwrap := true   // if hoisted onto heap with wrapper
}

**************************************************************************
** ThisExpr
**************************************************************************

**
** ThisExpr models the "this" keyword to access the implicit this
** local variable always stored in register zero.
**
class ThisExpr : LocalVarExpr
{
  new make(Loc loc)
    : super(loc, null, ExprId.thisExpr)
  {
//    this.ctype = ctype
  }

  override Bool isAssignable() { false }

  override Int register() { 0 }

  override Str toStr() { "this" }
}

**************************************************************************
** SuperExpr
**************************************************************************

**
** SuperExpr is used to access super class slots.  It always references
** the implicit this local variable stored in register zero, but the
** super class's slot definitions.
**
class SuperExpr : LocalVarExpr
{
  new make(Loc loc, TypeRef? explicitType := null)
    : super(loc, null, ExprId.superExpr)
  {
    this.explicitType = explicitType
  }

  override Bool isAssignable() { false }

  override Int register() { 0 }

  override Str toStr()
  {
    if (explicitType != null)
      return "${explicitType}.super"
    else
      return "super"
  }

  TypeRef? explicitType   // if "named super"
}

**************************************************************************
** ItExpr
**************************************************************************

**
** ItExpr models the "it" keyword to access the implicit
** target of an it-block.
**
class ItExpr : LocalVarExpr
{
  new make(Loc loc)
    : super(loc, null, ExprId.itExpr)
  {
  }

  override Bool isAssignable() { false }

  override Int register() { 1 }  // Void doCall(Type it)

  override Str toStr() { "it" }
}

**************************************************************************
** StaticTargetExpr
**************************************************************************

**
** StaticTargetExpr wraps a type reference as an Expr for use as
** a target in a static field access or method call
**
class StaticTargetExpr : Expr
{
  TypeRef target
  
  new make(Loc loc, TypeRef target)
    : super(loc, ExprId.staticTarget)
  {
    this.target = target
  }

//  override Bool sameVarAs(Expr that)
//  {
//    that.id === ExprId.staticTarget && ctype == that.ctype
//  }

  override Str toStr()
  {
    return target.toStr
  }
}

**************************************************************************
** TypeCheckExpr
**************************************************************************

**
** TypeCheckExpr is an expression which is composed of an arbitrary
** expression and a type - is, as, coerce
**
class TypeCheckExpr : Expr
{
  new make(Loc loc, ExprId id, Expr target, TypeRef check)
    : super(loc, id)
  {
    this.target = target
    this.check  = check
//    this.ctype  = check
  }

  new coerce(Expr target, TypeRef to)
    : super.make(target.loc, ExprId.coerce)
  {
//    if (to.hasGenericParameter) to = to.raw
    this.target = target
//    this.from   = target.ctype
    this.check  = to
//    this.ctype  = to
    this.synthetic = true
  }

  override Void walkChildren(Visitor v)
  {
    target = walkExpr(v, target)
  }

  override Bool isStmt()
  {
    return id === ExprId.coerce && target.isStmt
  }

  override Bool isAlwaysNullable() { id === ExprId.asExpr }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f) { target.isDefiniteAssign(f) }

//  override Str serialize()
//  {
//    if (id == ExprId.coerce)
//      return target.serialize
//    else
//      return super.serialize
//  }

  Str opStr()
  {
    switch (id)
    {
      case ExprId.isExpr:    return "is"
      case ExprId.isnotExpr: return "isnot"
      case ExprId.asExpr:    return "as"
      default:               throw Err(id.toStr)
    }
  }

  override Str toStr()
  {
    switch (id)
    {
      case ExprId.isExpr:    return "($target is $check)"
      case ExprId.isnotExpr: return "($target isnot $check)"
      case ExprId.asExpr:    return "($target as $check)"
      case ExprId.coerce:    return "(($check)$target)"
      default:               throw Err(id.toStr)
    }
  }

  ** From type if coerce
//  CType? from { get { &from ?: target.ctype } }

  Expr target
  TypeRef check    // to type if coerce
  override Bool synthetic := false
}

**************************************************************************
** TernaryExpr
**************************************************************************

**
** TernaryExpr is used for the ternary expression <cond> ? <true> : <false>
**
class TernaryExpr : Expr
{
  new make(Expr condition, Expr trueExpr, Expr falseExpr)
    : super(condition.loc, ExprId.ternary)
  {
    this.condition = condition
    this.trueExpr  = trueExpr
    this.falseExpr = falseExpr
  }

  override Void walkChildren(Visitor v)
  {
    condition = condition.walk(v)
    trueExpr  = trueExpr.walk(v)
    falseExpr = falseExpr.walk(v)
  }

  override Str toStr()
  {
    return "$condition ? $trueExpr : $falseExpr"
  }

  Expr condition     // boolean test
  Expr trueExpr      // result of expression if condition is true
  Expr falseExpr     // result of expression if condition is false
}

**************************************************************************
** ComplexLiteral
**************************************************************************

**
** ComplexLiteral is used to model a serialized complex object
** declared in facets.  It is only used in facets, in all other
** code complex literals are parsed as it-block ClosureExprs.
**
class ComplexLiteral : Expr
{
  new make(Loc loc, TypeRef target)
    : super(loc, ExprId.complexLiteral)
  {
    this.target = target
    this.names = Str[,]
    this.vals  = Expr[,]
  }

  override Void walkChildren(Visitor v)
  {
    vals = walkExprs(v, vals)
  }

  override Str toStr() { doToStr |expr| { expr.toStr } }

//  override Str serialize() { doToStr |expr| { expr.serialize } }

  Str doToStr(|Expr->Str| f)
  {
    s := StrBuf()
    s.add("$target {")
    names.each |Str n, Int i| { s.add("$n = ${f(vals[i])};") }
    s.add("}")
    return s.toStr
  }

  TypeRef target
  Str[] names
  Expr[] vals
}

**************************************************************************
** ClosureExpr
**************************************************************************

**
** ClosureExpr is an "inlined anonymous method" which closes over it's
** lexical scope.  ClosureExpr is placed into the AST by the parser
** with the code field containing the method implementation.  In
** InitClosures we remap a ClosureExpr to an anonymous class TypeDef
** which extends Func.  The function implementation is moved to the
** anonymous class's doCall() method.  However we leave ClosureExpr
** in the AST in it's original location with a substitute expression.
** The substitute expr just creates an instance of the anonymous class.
** But by leaving the ClosureExpr in the tree, we can keep track of
** the original lexical scope of the closure.
**
class ClosureExpr : Expr
{
  new make(Loc loc, TypeDef enclosingType,
           SlotDef enclosingSlot, ClosureExpr? enclosingClosure,
           FuncType signature, Str name)
    : super(loc, ExprId.closure)
  {
//    this.ctype            = signature
    this.enclosingType    = enclosingType
    this.enclosingSlot    = enclosingSlot
    this.enclosingClosure = enclosingClosure
    this.signature        = signature
    this.name             = name
  }

//  once CField outerThisField()
//  {
//    if (enclosingSlot.isStatic) throw Err("Internal error: $loc.toLocStr")
//    //TODO
//    throw Err("TODO")
//    //return ClosureVars.makeOuterThisField(this)
//  }

  override Str toStr()
  {
    return "$signature { ... }"
  }

  override Void print(AstWriter out)
  {
    out.w(signature.toStr)
    if (substitute != null)
    {
      out.w(" { substitute: ")
      substitute.print(out)
      out.w(" }").nl
    }
    else
    {
      out.nl
      code.print(out)
    }
  }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f)
  {
    // at this point, we have moved code into doCall method
    if (doCall == null) return false
    return doCall.code.isDefiniteAssign(f)
  }

//  Expr toWith(Expr target)
//  {
//    if (target.ctype != null) setInferredSignature(FuncType.makeItBlock(target.ctype))
//    x := CallExpr.makeWithMethod(loc, target, Expr[this])
//    // TODO: this coercion should be added automatically later in the pipeline
//    if (target.ctype == null) return x
//    return TypeCheckExpr.coerce(x, target.ctype)
//  }
//
//  Void setInferredSignature(FuncType t)
//  {
//    // bail if we didn't expect an inferred the signature
//    // or haven't gotten to InitClosures yet
//    if (cls == null) return
//
//    delArity := ((FuncType)cls.base).arity
//    if (!signature.inferredSignature && delArity == t.arity) {
//      return
//    }
//
//    // between the explicit signature and the inferred
//    // signature, take the most specific types; this is where
//    // we take care of functions with generic parameters like V
//    if (delArity <= t.arity) {
//      if (delArity < t.arity) {
//        addParams := CType[,]
//        for (i:=((FuncType)cls.base).arity; i<t.arity; ++i) {
//          ptype := t.params[i]
//          addParams.add(ptype)
//          //echo(doCall.params)
//          doCall.paramDefs.add(ParamDef(loc, ptype, "ignoreparam\$$i"))
//        }
//        collapseExprAndParams(call, addParams)
//      }
//      t = t.toArity(((FuncType)cls.base).arity)
//      t = signature.mostSpecific(t, signature.inferredSignature)
//    }
//    else if (isItBlock && t.arity == 0) {
//      call.paramDefs.clear
//      c := CallExpr.makeWithMethod(loc, ThisExpr(loc), doCall, [LiteralExpr.makeNull(loc)])
//      call.code.stmts.clear
//      if (t.ret.isVoid) {
//         call.code.add(c.toStmt)
//         call.code.add(ReturnStmt.makeSynthetic(loc, LiteralExpr.makeNull(loc)))
//      }
//      else {
//         call.code.add(ReturnStmt.makeSynthetic(loc, c))
//      }
//    }
//    else {
//      return
//    }
//
//    // sanity check
//    if (t.usesThis)
//      throw Err("Inferring signature with un-parameterized this type: $t")
//
//    // update my signature and the doCall signature
//    signature = t
//    ctype = t
//    if (doCall != null)
//    {
//      // update parameter types
//      doCall.paramDefs.each |ParamDef p, Int i|
//      {
//        if (i < signature.params.size)
//          p.paramType = signature.params[i]
//      }
//
//      // update return, we might have to translate an single
//      // expression statement into a return statement
//      if (doCall.ret.isVoid && !t.ret.isVoid)
//      {
//        doCall.ret = t.ret
//        collapseExprAndReturn(doCall)
//        collapseExprAndReturn(call)
//      }
//    }
//
//    // if an itBlock, set type of it
//    if (isItBlock) itType = t.params.first
//
//    // update base type of Func subclass
//    cls.base = t
//    ctype = t
//  }

  Void collapseExprAndParams(MethodDef m, TypeRef[] addParams)
  {
    addParams.each |ptype, i| {
      m.paramDefs.add(ParamDef(loc, TypeRef.objType(loc).toNullable, "ignoreparam\$$i"))
    }

    stmt := m.code.stmts.first
    CallExpr? call
    if (stmt is ReturnStmt) {
      call = ((ReturnStmt)stmt).expr
    }
    else {
      call = ((ExprStmt)stmt).expr
    }

    addParams.each |ptype, i| {
      arg := UnknownVarExpr(m.loc, null, "ignoreparam\$$i")
      carg := TypeCheckExpr.coerce(arg, ptype)
      call.args.add(carg)
    }
  }

  Void collapseExprAndReturn(MethodDef m)
  {
    code := m.code.stmts
    if (code.size != 2) return
    if (code[0].id !== StmtId.expr) return
    if (code[1].id !== StmtId.returnStmt) return
    if (!((ReturnStmt)code.last).isSynthetic) return
    expr := ((ExprStmt)code.first).expr
    code.set(0, ReturnStmt.makeSynthetic(expr.loc, expr))
    code.removeAt(1)
  }

  // Parse
  TypeDef enclosingType         // enclosing class
  SlotDef enclosingSlot         // enclosing method or field initializer
  ClosureExpr? enclosingClosure // if nested closure
  FuncType signature            // function signature
  Block? code                   // moved into a MethodDef in InitClosures
  Str name                      // anonymous class name
  Bool isItBlock                // does closure have implicit it scope

  // InitClosures
  Expr? substitute          // expression to substitute during assembly
  TypeDef? cls                  // anonymous class which implements the closure
  MethodDef? call               // anonymous class's call() with code
  MethodDef? doCall             // anonymous class's doCall() with code

  // ResolveExpr
  [Str:MethodVar]? enclosingVars // my parent methods vars in scope
  //Bool setsConst                 // sets one or more const fields (CheckErrors)
//  CType? itType                  // type of implicit it
  TypeRef? followCtorType          // follow make a new Type
}

**************************************************************************
** ClosureExpr
**************************************************************************

**
** DslExpr is an embedded Domain Specific Language which
** is parsed by a DslPlugin.
**
class DslExpr : Expr
{
  new make(Loc loc, TypeRef anchorType, Loc srcLoc, Str src)
    : super(loc, ExprId.dsl)
  {
    this.anchorType = anchorType
    this.src        = src
    this.srcLoc     = srcLoc
  }

  override Str toStr()
  {
    return "$anchorType <|$src|>"
  }

  override Void print(AstWriter out)
  {
    out.w(toStr)
  }

  TypeRef anchorType  // anchorType <|src|>
  Str src           // anchorType <|src|>
  Loc srcLoc        // location of first char of src
  Int leadingTabs   // number of leading tabs on original Fantom line
  Int leadingSpaces // number of leading non-tab chars on original Fantom line
}

**************************************************************************
** ThrowExpr
**************************************************************************

**
** ThrowExpr models throw as an expr versus a statement
** for use inside ternary/elvis operations.
**
class ThrowExpr : Expr
{
  new make(Loc loc, Expr exception)
    : super(loc, ExprId.throwExpr)
  {
    this.exception = exception
  }

  override Void walkChildren(Visitor v)
  {
    exception = exception.walk(v)
  }

  override Str toStr() { "throw $exception" }

  Expr exception   // exception to throw
}

class AwaitExpr : Expr {
  Expr expr
  
  new make(Loc loc, Expr expr)
    : super(loc, ExprId.awaitExpr)
  {
    this.expr = expr
//    this.ctype = expr.ctype
  }

  override Void walkChildren(Visitor v)
  {
    expr = expr.walk(v)
  }

  override Str toStr() { "await $expr" }
  override Bool isStmt() { true }
}


**************************************************************************
** ShortcutId
**************************************************************************

**
** ShortcutOp is a sub-id for ExprId.shortcut which identifies the
** an shortuct operation and it's method call
**
enum class ShortcutOp
{
  plus(2, "+"),
  minus(2, "-"),
  mult(2, "*"),
  div(2, "/"),
  mod(2, "%"),
  negate(1, "-"),
  increment(1, "++"),
  decrement(1, "--"),
  eq(2, "==", "equals"),
  cmp(2, "<=>", "compare"),
  get(2, "[]"),
  set(3, "[]="),
  add(2, ",")

  private new make(Int degree, Str symbol, Str? methodName := null)
  {
    this.degree = degree
    this.symbol = symbol
    this.methodName = methodName == null ? name : methodName
    this.isOperator = methodName == null
  }

  static ShortcutOp? fromPrefix(Str prefix) { prefixes[prefix] }
  private static const [Str:ShortcutOp] prefixes
  static
  {
    m := Str:ShortcutOp[:]
    vals.each |val| { m[val.methodName] = val }
    prefixes = m
  }

  Str formatErr(TypeRef lhs, TypeRef rhs)
  {
    if (this === get) return "$lhs [ $rhs ]"
    if (this === set) return "$lhs [ $rhs ]="
    return "$lhs $symbol $rhs"
  }

  const Int degree
  const Str methodName
  const Bool isOperator
  const Str symbol
}

class SizeOfExpr : Expr
{
  new make(Loc loc, TypeRef type)
    : super(loc, ExprId.sizeOfExpr)
  {
    this.type = type
    //this.ctype  = ns.intType
  }

  override Str toStr()
  {
    return "sizeof($type)"
  }

  TypeRef type
}

class AddressOfExpr : Expr
{
  new make(Loc loc, Expr var_v)
    : super(loc, ExprId.addressOfExpr)
  {
    this.var_v = var_v
    //this.ctype  = ns.ptrType
  }

  override Void walkChildren(Visitor v)
  {
    var_v = var_v.walk(v)
  }

  override Str toStr()
  {
    return "addressof($var_v)"
  }

  Expr var_v
}