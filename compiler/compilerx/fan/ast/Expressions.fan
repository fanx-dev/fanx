//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//

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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(operand)
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
    this.ctype = lhs.ctype
    this.leave = leave
    super.len = (rhs.loc.offset + rhs.len) - lhs.loc.offset
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(lhs)
    list.add(rhs)
  }

  override Str serialize()
  {
    if (id === ExprId.assign)
      return "${lhs.serialize}=${rhs.serialize}"
    else
      return super.serialize
  }

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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    operands.each |e| {
      list.add(e)
    }
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
    if (target != null && loc.offset > target.loc.offset) {
      super.loc = target.loc
    }
    this.target = target
    this.name   = name
    this.isSafe = false
  }

  override Bool isAlwaysNullable() { isSafe }

  override Void walkChildren(Visitor v)
  {
    target = walkExpr(v, target)
  }
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    if (target != null) list.add(target)
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

  new makeWithMethod(Loc loc, Expr? target, CMethod method, Expr[]? args := null)
    : this.make(loc, target, method.name, ExprId.call)
  {
    this.method = method
    this.ctype = method.isCtor ? method.parent.asRef : method.returnType
    if (args != null) this.args = args
  }

  override Str toStr()
  {
    return toCallStr(true)
  }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f)
  {
    if (target != null && target.isDefiniteAssign(f)) return true
    return args.any |Expr arg->Bool| { arg.isDefiniteAssign(f) }
  }

  override Bool isStmt()
  {
    if (method == null) return true
    
    // stand alone constructor is not a valid stmt
    if (method.isCtor) return false

    // with block applied to stand alone constructor is not valid stmt
    if (method.name == "with" && target is CallExpr && ((CallExpr)target).method.isCtor)
      return false

    // consider any other call a stand alone stmt
    return true
  }

  virtual Bool isCompare() { false }

  override Void walkChildren(Visitor v)
  {
    target = walkExpr(v, target)
    args = walkExprs(v, args)
  }
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    if (target != null) list.add(target)
    args.each |e| {
      list.add(e)
    }
  }

  override Str serialize()
  {
    // only serialize a true Type("xx") expr which maps to Type.fromStr
    if (id != ExprId.construction || method.name != "fromStr")
      return super.serialize

    argSer := args.join(",") |Expr e->Str| { e.serialize }
    return "$method.parent($argSer)"
  }

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
  CMethod? method     // resolved method
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

  Bool isStrConcat() { opToken == Token.plus && args.size == 1 && target.ctype.isStr }

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
  CMethod? setMethod
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
  
  new makeField(Loc loc, Expr? target, CField field, Bool useAccessor := true)
    : super.make(loc, ExprId.field, target, null)
  {
    this.useAccessor = useAccessor
    this.isSafe = false
    this.name = field.name
    this.field = field
    this.ctype = field.fieldType
  }

  override Bool isAssignable() { true }

  override Bool assignRequiresTempVar() { !field.isStatic }

  override Bool sameVarAs(Expr that)
  {
    x := that as FieldExpr
    if (x == null) return false
    return field == x.field &&
           target != null &&
           x.target != null &&
           target.sameVarAs(x.target)
  }

  override Int? asTableSwitchCase()
  {
    // TODO - this should probably be tightened up if we switch to const
    if (field.isStatic && field.parent.isEnum && ctype.isEnum)
    {
      ordinal := field.enumOrdinal
      if (ordinal == -1) throw Err("Invalid field for tableswitch: $field.typeof $loc.toLocStr")
      return ordinal
    }
    return null
  }

  override Str serialize()
  {
    if (field.isStatic)
    {
      if (field.parent.isFloat)
      {
        switch (name)
        {
          case "nan":    return "sys::Float(\"NaN\")"
          case "posInf": return "sys::Float(\"INF\")"
          case "negInf": return "sys::Float(\"-INF\")"
        }
      }

      if (field.isEnum)
        return "${field.parent.qname}(\"$name\")"
    }

    return super.serialize
  }

  override Str toStr()
  {
    s := StrBuf.make
    if (target != null) s.add(target).add(".");
    if (!useAccessor) s.add("&")
    s.add(name)
    return s.toStr
  }

  CField? field       // resolved field
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
      this.ctype = var_v.ctype
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
    
    if (register == x.register && register != -1) return true
    if (var_v == null || x.var_v == null) return false
    return var_v.name == x.var_v.name
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
  
  new makeType(Loc loc, CType ctype)
    : super.make(loc, null, ExprId.thisExpr)
  {
    this.ctype = ctype
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
  new make(Loc loc, CType? explicitType := null)
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

  CType? explicitType   // if "named super"
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
  
  //ClosureExpr? enclosingClosure //for check setting an const field in ctor + it-block
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
  CType target
  
  new make(Loc loc, CType target)
    : super(loc, ExprId.staticTarget)
  {
    this.target = target
    this.ctype = target
  }

  override Bool sameVarAs(Expr that)
  {
    that.id === ExprId.staticTarget && target == ((StaticTargetExpr)that).target
  }

  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(target)
  }

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
  new make(Loc loc, ExprId id, Expr target, CType check)
    : super(loc, id)
  {
    this.target = target
    this.check  = check
    this.ctype  = check
    super.len = target.len
  }

  new coerce(Expr target, CType to)
    : super.make(target.loc, ExprId.coerce)
  {
    //if (to.isGenericParameter) to = to.raw
    this.target = target
    this.from   = target.ctype
    this.check  = to
    this.ctype  = to
    this.synthetic = true
    super.len = target.len
  }

  override Void walkChildren(Visitor v)
  {
    target = walkExpr(v, target)
  }
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(target)
  }

  override Bool isStmt()
  {
    return id === ExprId.coerce && target.isStmt
  }

  override Bool isAlwaysNullable() { id === ExprId.asExpr }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f) { target.isDefiniteAssign(f) }

  override Str serialize()
  {
    if (id == ExprId.coerce)
      return target.serialize
    else
      return super.serialize
  }

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
  CType? from { get { &from ?: target.ctype } }

  Expr target
  CType check    // to type if coerce
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(condition)
    list.add(trueExpr)
    list.add(falseExpr)
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
  new make(Loc loc, CType target)
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(target)
    vals.each |e| {
      list.add(e)
    }
  }

  override Str toStr() { doToStr |expr| { expr.toStr } }

  override Str serialize() { doToStr |expr| { expr.serialize } }

  Str doToStr(|Expr->Str| f)
  {
    s := StrBuf()
    s.add("$target {")
    names.each |Str n, Int i| { s.add("$n = ${f(vals[i])};") }
    s.add("}")
    return s.toStr
  }

  CType target
  Str[] names
  Expr[] vals
}

**************************************************************************
** DslExpr
**************************************************************************

**
** DslExpr is an embedded Domain Specific Language which
** is parsed by a DslPlugin.
**
class DslExpr : Expr
{
  new make(Loc loc, CType anchorType, Loc srcLoc, Str src)
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(anchorType)
  }

  CType anchorType  // anchorType <|src|>
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(exception)
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
    this.ctype = expr.ctype
  }

  override Void walkChildren(Visitor v)
  {
    expr = expr.walk(v)
  }
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(expr)
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
    m := [Str:ShortcutOp][:]
    vals.each |val| { m[val.methodName] = val }
    prefixes = m
  }

  Str formatErr(CType lhs, CType rhs)
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
  new make(Loc loc, CType type)
    : super(loc, ExprId.sizeOfExpr)
  {
    this.type = type
    //this.ctype  = ns.intType
  }

  override Str toStr()
  {
    return "sizeof($type)"
  }
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(type)
  }

  CType type
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    list.add(var_v)
  }

  override Str toStr()
  {
    return "addressof($var_v)"
  }

  Expr var_v
}