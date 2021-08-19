//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    2 Jun 06  Brian Frank  Ported from Java to Fan
//

**
** VisitStep represents one discrete task run during the compiler
** pipeline.  The implementations are found under steps.
**
abstract class CompilerStep : Visitor
{
  CompilerContext compiler

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor takes the associated Compiler
  **
  new make(CompilerContext compiler)
  {
    this.compiler = compiler
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the step
  **
  virtual Void run() { throw Err("unsupport") }
  
  protected Void walkUnits(VisitDepth depth) {
    walk(compiler.cunits, depth)
  }
  
  **
  ** current pod name
  **
  Str podName() { compiler.pod.name }
  
//////////////////////////////////////////////////////////////////////////
// Convenience
//////////////////////////////////////////////////////////////////////////

  **
  ** Convenience for compiler.log
  **
  CompilerLog log() { compiler.log }
  
  **
  ** Create, log, and return a CompilerErr.
  **
  CompilerErr err(Str msg, Loc? loc := null)
  {
    compiler.log.err(msg, loc)
  }

  **
  ** Create, log, and return a warning CompilerErr.
  **
  CompilerErr warn(Str msg, Loc? loc := null)
  {
    compiler.log.warn(msg, loc)
  }
  
  CompilerErr errReport(CompilerErr e)
  {
    compiler.log.errReport(e)
  }
  
  Void debug(Str msg, Loc? loc := null) {
    compiler.log.debug(msg, loc)
  }
  
  Void bombIfErr()
  {
    if (!compiler.log.errs.isEmpty)
      throw compiler.log.errs.first
  }
  
  CNamespace ns() { compiler.ns }


//////////////////////////////////////////////////////////////////////////
// Visitor
//////////////////////////////////////////////////////////////////////////

  Bool inStatic()
  {
    return curMethod == null || curMethod.isStatic
  }

  override Void enterUnit(CompilationUnit unit)
  {
    curUnit = unit
  }

  override Void exitUnit(CompilationUnit unit)
  {
    curUnit = null
  }

  override Void enterTypeDef(TypeDef def)
  {
    curType = def
  }

  override Void exitTypeDef(TypeDef def)
  {
    curType = null
  }

  override Void enterMethodDef(MethodDef def)
  {
    curMethod = def
  }

  override Void exitMethodDef(MethodDef def)
  {
    curMethod = null
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  TypeDef? curType
  MethodDef? curMethod
  CompilationUnit? curUnit

}