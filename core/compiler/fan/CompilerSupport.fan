//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 May 06  Brian Frank  Creation
//

**
** CompilerSupport provides lots of convenience methods for classes
** used during the compiler pipeline.
**
class CompilerSupport
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor takes the associated Compiler
  **
  new make(Compiler compiler)
  {
    this.c = compiler
  }

//////////////////////////////////////////////////////////////////////////
// Convenience
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the compiler.
  **
  virtual Compiler compiler() { c }

  **
  ** Convenience for compiler.ns
  **
  CNamespace ns() { c.ns }

  **
  ** Convenience for compiler.pod
  **
  PodDef pod() { c.pod }

  **
  ** Convenience for compiler.pod.units
  **
  CompilationUnit[] units() { c.pod.units }

  **
  ** Get default compilation unit to use for synthetic definitions
  ** such as wrapper types.
  **
  CompilationUnit syntheticsUnit() { c.pod.units.first }

  **
  ** Convenience for compiler.types
  **
  TypeDef[] types() { c.types }

  **
  ** Convenience for compiler.log
  **
  CompilerLog log() { c.log }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Add a synthetic type
  **
  Void addTypeDef(TypeDef t)
  {
    t.unit.types.add(t)
    pod.typeDefs[t.name] = t
    c.types.add(t)
  }

  **
  ** Remove a synthetic type
  **
  Void removeTypeDef(TypeDef t)
  {
    t.unit.types.removeSame(t)
    pod.typeDefs.remove(t.name)
    c.types.removeSame(t)
  }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  **
  ** Create, log, and return a CompilerErr.
  **
  virtual CompilerErr err(Str msg, Loc? loc := null)
  {
    if (suppressErr) throw SuppressedErr.make
    return errReport(CompilerErr(msg, loc))
  }

  **
  ** Create, log, and return a warning CompilerErr.
  **
  virtual CompilerErr warn(Str msg, Loc? loc := null)
  {
    if (suppressErr) throw SuppressedErr.make
    return errReport(CompilerErr(msg, loc, null, LogLevel.warn))
  }

  **
  ** Log, store, and return the specified CompilerErr.
  **
  CompilerErr errReport(CompilerErr e)
  {
    c.log.compilerErr(e)
    if (e.isWarn)
      c.warns.add(e)
    else
      c.errs.add(e)
    return e
  }

  **
  ** If any errors are accumulated, then throw the first one
  **
  Void bombIfErr()
  {
    if (!c.errs.isEmpty)
      throw c.errs.first
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Compiler c           // parent compiler instance
  Bool suppressErr := false    // throw SuppressedErr instead of CompilerErr

}

**************************************************************************
** SuppressedErr
**************************************************************************

internal const class SuppressedErr : Err
{
  new make() : super("", null) {}
}