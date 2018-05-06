//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Aug 06  Brian Frank  Creation
//

**
** Assemble is responsible for assembling the resolved, analyzed,
** normalized abstract syntax tree into it's fcode representation
** in memory as a FPod stored on compiler.fpod.
**
class Assemble : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor takes the associated Compiler
  **
  new make(Compiler compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the step
  **
  override Void run()
  {
    // don't both assembling fcode if we aren't going to use it
    if (compiler.input.output === CompilerOutputMode.js) return

    log.debug("Assemble")
    compiler.fpod = Assembler(compiler).assemblePod
    bombIfErr
    if (compiler.input.fcodeDump) compiler.fpod.dump(log.out)
  }

}