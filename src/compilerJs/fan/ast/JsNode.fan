//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compiler

**
** JsNode translates a compiler::Node into the equivalent JavaScript
** source code.
**
abstract class JsNode
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(JsCompilerSupport support, Node? node := null)
  {
    this.support = support
    this.nodeRef = node
    this.loc = node?.loc
  }

  virtual Node? node() { nodeRef }
  private Node? nodeRef

  Loc? loc

//////////////////////////////////////////////////////////////////////////
// Write
//////////////////////////////////////////////////////////////////////////

  **
  ** Write the JavaScript source code for this node.
  **
  abstract Void write(JsWriter out)

//////////////////////////////////////////////////////////////////////////
// JavaScript
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the JavaScript qname for this CType.
  **
  Str qnameToJs(CType ctype)
  {
    // use this method as a hook to look for synthentic types
    // used in compiled types that we need to emit
    /*
    if (ctype.isSynthetic)
    {
      if (ctype.qname.contains("Curry\$"))
      {
        list := (support.compiler as JsCompiler).synth
        if (!list.contains(ctype)) list.add(ctype)
      }
    }
    */
    /*
    else
    {
      // also use this method to verify referenced types
      // have been configured to be compiled to js as well
      if (!Type.find(ctype.qname).facet(@js, false))
        support.err("Type not available in JavaScript: $ctype.qname")
    }
    */

    return "fan.${ctype.pod.name}.$ctype.name"
  }

  **
  ** Return the JavaScript variable name for the given Fan
  ** variable name.
  **
  Str vnameToJs(Str name)
  {
    if (vnames.get(name, false)) return "\$$name";
    return name;
  }

  // must keep in sync with fan.sys.Slot.prototype.$$name
  private const [Str:Bool] vnames :=
  [
    "char":   true,
    "delete": true,
    "enum":   true,
    "export": true,
    "fan":    true,
    "float":  true,
    "import": true,
    "in":     true,
    "int":    true,
    "name":   true,
    "typeof": true,
    "var":    true,
    "with":   true
  ].toImmutable

  **
  ** Return true if the type is a primitive type:
  **  - Bool
  **  - Decimal
  **  - Float
  **  - Int
  **  - Num
  **  - Str
  **
  Bool isPrimitive(CType ctype) { return pmap.get(ctype.qname, false) }
  const [Str:Bool] pmap :=
  [
    "sys::Bool":    true,
    "sys::Decimal": true,
    "sys::Float":   true,
    "sys::Int":     true,
    "sys::Num":     true,
    "sys::Str":     true
  ]
/*
  **
  ** The name of the 'this' var.
  **
  Str thisName
  {
    get { Actor.locals["compilerJs.this"] ?: "this" }
    set { Actor.locals["compilerJs.this"] = it }
  }

  **
  ** Return a unique identifier name.
  **
  Str unique()
  {
    Int id := Actor.locals["compilerJs.lastId"] ?: 0
    Actor.locals["compilerJs.lastId"] = id + 1
    return "\$_u$id"
  }
*/
  JsCompilerSupport support

}
