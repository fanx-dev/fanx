//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Dec 09  Brian Frank  Creation
//

**
** CompileJs is used to call the compilerJs plugin to generate
** javascript for the pod if the @js facet is configured.
**
class CompileJs  : CompilerStep
{

  new make(Compiler compiler) : super(compiler) {}

  override Void run()
  {
    // short circuit if no types define the @Js facet
    if (!needCompileJs) return

    // try to resolve plugin type
    t := Type.find("compilerJs::CompileJsPlugin", false)
    if (t == null)
    {
      log.info("WARN: compilerJs not installed!")
      return
    }

    // do it!
    log.info("CompileJs")
    t.make([compiler])->run
  }

  Bool needCompileJs()
  {
    // in JS mode we force JS compilation
    if (compiler.input.output === CompilerOutputMode.js) return true

    if (compiler.input.compileJs) return true

    // if any JS directories were specified force JS compilation
    if (compiler.jsFiles != null && !compiler.jsFiles.isEmpty) return true

    // run JS compiler is any type has @Js facet
    return compiler.types.any { it.hasFacet("sys::Js") }
  }

}