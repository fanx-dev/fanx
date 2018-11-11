//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   08 Jun 15  Matthew Giannini Creation
//

using compiler

**
** Utility for working with JS closures. Shared by JsPod and JsClosureExpr
** for writing javascript related to closures.
**
** Every closure in JS requires that we create a 'fan.sys.Func'. The Func
** requires a 'ClosureFuncSpec$' object that represents the closure
** specification for the Func.This class analyzes all closures for the pod and creates
** a static field for each unique ClosureFuncSpec it identifies.Then, when the actual
** closure Func is created and called, it uses that static field instead of creating
** a new one every time the closure is called.
**
class JsPodClosures : JsNode
{
  new make(JsCompilerSupport s) : super(s)
  {
  }

  ** Write the actual closure Func (JsClosureExpr)
  Void writeClosure(ClosureExpr ce, JsWriter out)
  {
    loc  := ce.loc
    func := JsMethod(support, ce.doCall)
    sig  := func.sig(func.params)

    out.w("fan.sys.Func.make\$closure(", loc).nl
    out.indent

    CType[] sigTypes := [,].addAll(ce.signature.params).add(ce.signature.ret)
    isJs := sigTypes.all { JsType.isJsSafe(it) }
    if (isJs)
    {
      // closure spec
      out.w("${mapFuncSpec(ce)},", loc).nl

      // func
      out.w("function$sig", loc).nl
      out.w("{").nl
      out.indent
      old := support.thisName
      support.thisName = "\$this"
      func.code?.write(out)
      support.thisName = old
      out.unindent
      out.w("})")
    }
    else
    {
      // this closure uses non-JS types. Write a closure that documents this fact
      out.w("new fan.sys.ClosureFuncSpec\$(fan.sys.Void.\$type, []),").nl
      out.w("function() {").nl
      out.w("  // Cannot write closure. Signature uses non-JS types: ${ce.signature}").nl
      out.w("})")
    }

    out.unindent
  }

  ** Write the unique closure specification fields for this pod (JsPod)
  override Void write(JsWriter out)
  {
    varToFunc.each |JsMethod func, Str var|
    {
      loc := func.loc
      t := var["fan".size+1..-1]
      pos2 := t.find(".")
      podName := t[0..<pos2]
      typeName := t[pos2+1..-1]
      out.w("${var} = new fan.sys.ClosureFuncSpec\$(\"$podName::$typeName\",", loc)

      // return type
      JsTypeLiteralExpr.writeType(func.ret, out)
      out.w(",")

      // raw parameters
      out.w("[")
      func.params.each |p,i|
      {
        if (i > 0) out.w(",")
        out.w("\"${p.name}\",\"${p.paramType.sig}\",\"${p.hasDef}\"", loc)
      }
      out.w("]);").nl
    }
  }

  ** Creates a variable for the ClosureFuncSpec of this closure and
  ** returns the variable name. If we have already seen a closure with
  ** the EXACT same spec, then re-use that variable declaration and
  ** return the existing variable name.
  private Str mapFuncSpec(ClosureExpr ce)
  {
    func := JsMethod(support, ce.doCall)
    var  := specKeyToVar.getOrAdd(specKey(func)) |->Str|
    {
      "${pod(ce)}.\$clos${support.unique}"
    }
    varToFunc[var] = func
    return var
  }

  ** Get the pod variable prefix for all the closure func specs
  static private Str pod(ClosureExpr ce) { "fan.${ce.enclosingType.pod}" }

  ** Return the unique key for this function specification
  static private Str specKey(JsMethod func)
  {
    buf := StrBuf()
    func.params.each |p|
    {
      buf.add("${p.name}-${p.paramType.sig}-${p.hasDef},")
    }
    buf.add("${func.ret.sig}")
    return buf.toStr
  }

  ** Func spec key to field variable name
  private Str:Str specKeyToVar := [:]

  ** Func spec field variable name to prototype function (for params and return type)
  private Str:JsMethod varToFunc := OrderedMap<Str,JsMethod>()//[:] { ordered = true }
}