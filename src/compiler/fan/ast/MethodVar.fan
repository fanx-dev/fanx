//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Feb 06  Brian Frank  Creation
//   11 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** MethodVar is a variable used in a method - either param or local.
**
class MethodVar
{

  new make(MethodDef method, Int register, CType ctype, Str name, Int flags := 0, Block? scope := null)
  {
    this.method   = method
    this.register = register
    this.ctype    = ctype
    this.name     = name
    this.flags    = flags
    this.scope    = scope
  }

  new makeForParam(MethodDef method, Int register, ParamDef p, CType paramType)
    : this.make(method, register, paramType, p.name, FConst.Param, null)
  {
    this.paramDef = p
  }

  Bool isParam() { flags.and(FConst.Param) != 0 }

  Bool isWrapped() { wrapField != null }

  override Str toStr() { "$register  $name: $ctype" }

  Void reassigned()
  {
    isReassigned = true
    if (shadows != null) shadows.reassigned
  }

  MethodDef method    // declared method (doCall if declared in closure)
  Int register        // register number
  CType ctype         // variable type
  Str name            // variable name
  Int flags           // Param
  Bool isCatchVar     // is this auto-generated var for "catch (Err x)"
  Block? scope        // block which scopes this variable
  ParamDef? paramDef  // if param
  Bool usedInClosure  // local used by closure within containing method
  MethodVar? shadows  // if closure var, this is the variable in parent scope we shadow
  CField? wrapField   // if wrapped onto heap this is 'Wrapper.val' field
  Bool isReassigned   // keeps track of reassigment assignment (we don't count initial local assign)
  MethodVar? paramWrapper  // wrapper local var if param has to be wrapped

}