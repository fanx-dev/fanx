//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compiler

**
** JsMethod
**
class JsMethod : JsSlot
{
  new make(JsCompilerSupport s, MethodDef m) : super(s, m)
  {
    this.parentPeer = JsType.findPeer(s, m.parent)
    this.isInstanceCtor = m.isInstanceCtor
    this.isGetter   = m.isGetter
    this.isSetter   = m.isSetter
    this.isAsync    = m.flags.and(FConst.Async) != 0
    this.params     = m.params.map |CParam p->JsMethodParam| { JsMethodParam(s, p) }
    this.ret        = JsTypeRef(s, m.ret, m.loc)
    this.hasClosure = ClosureFinder(m).exists
    if (m.ctorChain != null) this.ctorChain = JsExpr.makeFor(s, m.ctorChain)
    if (!m.isNative && !m.parent.isNative && m.code != null) this.code = JsBlock(s, m.code)
  }

  override MethodDef? node() { super.node }

  Bool isFieldAccessor() { isGetter || isSetter }

  override Void write(JsWriter out)
  {
    if (isInstanceCtor)
    {
      // write static factory make method
      ctorParams := [JsMethodParam.makeSelf(support)].addAll(params)
      out.w("${parent}.$name = function${sig(params)} {", loc).nl
         .indent
         .w("var self = new $parent();").nl
         .w("${parent}.$name\$${sig(ctorParams)};").nl
         .w("return self;").nl
         .w("}").nl
         .unindent

      // write factory make$ method
      support.thisName = "self"
      writeMethod(out, "$name\$", ctorParams)
      support.thisName = "this"
    }
    else if (isSetter) writeMethod(out, "$name\$", params)
    else writeMethod(out, name, params)
  }

  Void writeMethod(JsWriter out, Str methName, JsMethodParam[] methParams)
  {
    // skip abstract methods
    if (isAbstract) return

    out.w(parent, loc)
    if (!isStatic && !isInstanceCtor) out.w(".prototype")
    out.w(".$methName = ")
    if (isAsync) out.w("async ")
    out.w("function${sig(methParams)}", loc).nl
    out.w("{").nl
    out.indent

    // def params
    params.each |p|
    {
      if (!p.hasDef) return
      out.w("if ($p.name === undefined) $p.name = ", p.loc)
      p.defVal.write(out)
      out.w(";").nl
    }

    // closure support
    if (hasClosure) out.w("var \$this = $support.thisName;", loc).nl

    if (isNative)
    {
      if (isStatic)
      {
        out.w("return ${parentPeer.qname}Peer.$methName${sig(methParams)};", loc).nl
      }
      else
      {
        pars := isStatic ? params : [JsMethodParam.makeThis(support)].addAll(methParams)
        out.w("return this.peer.$methName${sig(pars)};", loc).nl
      }
    }
    else
    {
      // ctor chaining
      if (ctorChain != null)
      {
        ctorChain.write(out)
        out.w(";").nl
      }

      // method body
      code?.write(out)
    }

    out.unindent
    out.w("}").nl
  }

  Str sig(JsMethodParam[] pars)
  {
    buf := StrBuf().addChar('(')
    pars.each |p,i|
    {
      if (i > 0) buf.addChar(',')
      buf.add(p.name)
    }
    buf.addChar(')')
    return buf.toStr
  }

  JsTypeRef? parentPeer   // parent peer if has one
  Bool isInstanceCtor     // is this method an instance constructor
  Bool isGetter           // is this method a field getter
  Bool isSetter           // is this method a field setter
  JsMethodParam[] params  // method params
  JsTypeRef ret           // return type for method
  Bool hasClosure         // does this method contain a closure
  JsExpr? ctorChain       // ctorChain if has one
  JsBlock? code           // method body if has one
  Bool isAsync
}

**************************************************************************
** JsMethodRef
**************************************************************************

**
** JsMethodRef
**
class JsMethodRef : JsSlotRef
{
  new make(JsCompilerSupport s, CMethod m) : super(s, m) {}
}

**************************************************************************
** JsMethodParam
**************************************************************************

**
** JsMethodParam
**
class JsMethodParam : JsNode
{
  new make(JsCompilerSupport s, CParam p) : super(s)
  {
    this.loc = p is Node ? ((Node)p).loc : null
    this.reflectName = p.name
    this.name = vnameToJs(p.name)
    this.paramType = JsTypeRef(s, p.paramType, this.loc)
    this.hasDef = p.hasDefault
    if (hasDef) this.defVal = JsExpr.makeFor(s, p->def)
  }

  new makeThis(JsCompilerSupport s) : super.make(s)
  {
    this.reflectName = this.name = "this"
  }

  new makeSelf(JsCompilerSupport s) : super.make(s)
  {
    this.reflectName = this.name = "self"
  }

  override Void write(JsWriter out)
  {
    out.w(name)
  }

  Str reflectName       // reflected parameter name
  Str name              // js code param name
  JsTypeRef? paramType  // param type
  Bool hasDef           // has default value
  JsNode? defVal        // default value
}

**************************************************************************
** ClosureFinder
**************************************************************************

internal class ClosureFinder : Visitor
{
  new make(Node node) { this.node = node }
  Bool exists()
  {
    node->walk(this, VisitDepth.expr)
    return found
  }
  override Expr visitExpr(Expr expr)
  {
    if (expr is ClosureExpr) found = true
    return Visitor.super.visitExpr(expr)
  }
  Node node
  Bool found := false
}
