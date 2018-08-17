//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    3 Sep 05  Brian Frank  Creation
//   18 May 06  Brian Frank  Ported from Java to Fan
//

**
** Compiler manages the top level process of the compiler pipeline.
** There are a couple different "pipelines" used to accomplish
** various twists on compiling Fantom code (from memory, files, etc).
** The pipelines are implemented as discrete CompilerSteps.
** As the steps are executed, the Compiler instance itself stores
** the state as we move from files -> ast -> resolved ast -> code.
**
** Error reporting is managed via the Compiler.errors list.  If
** the compiler encounters problems it accumulates the errors as
** CompileExceptions in this list, then raises the first exception
** to the caller.  All errors go thru the CompilerSupport.err()
** methods for logging.  To log an error and continue we simply
** call err().  To fail fast, we code something like: throw err().
** Or at the end of a step we may call bombIfErr() which throws the
** first exception if any errors have accumulated.
**
class Compiler
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with reasonable defaults
  **
  new make(CompilerInput input)
  {
    if ((Obj?)input.log == null)
      throw ArgErr("CompilerInput.log is null")

    this.input      = input
    this.log        = input.log
    this.errs       = CompilerErr[,]
    this.warns      = CompilerErr[,]
    this.depends    = CDepend[,]
    this.wrappers   = Str:CField[:]
    this.localeDefs = LocaleLiteralExpr[,]
  }

//////////////////////////////////////////////////////////////////////////
// Compile
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile fan source code from the configured CompilerInput
  ** into a fan pod and return the resulting CompilerOutput.
  **
  virtual CompilerOutput compile()
  {
    log.info("Compile [${input.podName}]")
    log.indent

    try
    {
      frontend
      backend
    }
    catch (CompilerErr e)
    {
      if (errs.isEmpty) CompilerSupport(this).errReport(e)
      throw e
    }
    finally cleanup

    log.unindent
    return output
  }

  **
  ** Execute front-end compiler pipeline
  **
  virtual Void frontend()
  {
    InitInput(this).run
    Tokenize(this).run
    ResolveDepends(this).run
    ScanForUsingsAndTypes(this).run
    ResolveImports(this).run
    Parse(this).run
    OrderByInheritance(this).run
    CheckInheritance(this).run
    InitDataClass(this).run
    Inherit(this).run
    DefaultCtor(this).run
    InitEnum(this).run
    InitFacet(this).run
    InitClosures(this).run
    Normalize(this).run
    ResolveExpr(this).run
    CheckErrors(this).run
    CheckParamDefs(this).run
    LocaleProps(this).run
    CompileJs(this).run
    ClosureVars(this).run
    ClosureToImmutable(this).run
    ConstChecks(this).run
  }

  **
  ** Execute back-end compiler pipeline
  **
  virtual Void backend()
  {
    Assemble(this).run
    GenerateOutput(this).run
  }

  **
  ** Guaranteed cleanup of resources
  **
  private Void cleanup()
  {
    try
    {
      ns.cleanup
    }
    catch (Err e) e.trace
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CompilerInput input       // ctor
  CompilerLog log           // ctor
  CompilerErr[] errs        // accumulated errors
  CompilerErr[] warns       // accumulated warnings
  CDepend[] depends         // InitInput
  CNamespace? ns            // InitInput
  PodDef? pod               // InitInput
  //Bool isSys := false       // InitInput; are we compiling sys itself
  File[]? srcFiles          // InitInput
  File[]? resFiles          // InitInput
  File[]? jsFiles           // InitInput
  TypeDef[]? types          // Parse
  ClosureExpr[]? closures   // Parse
  Str:CField wrappers       // ClosureVars
  Obj? jsPod                // CompileJs (JavaScript AST)
  Str? js                   // CompileJs (JavaScript code)
  Str? jsSourceMap          // CompileJs (JavaScript sourcemap)
  LocaleLiteralExpr[] localeDefs  // ResolveExpr.resolveLocaleLiteral
  Str? localeProps          // LocaleProps
  FPod? fpod                // Assemble
  CompilerOutput? output    // GenerateOutput

}