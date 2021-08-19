//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** GenerateOutput creates the appropriate CompilerOutput instance
** for Compiler.output based on the configured CompilerInput.output.
**
class GenerateOutput : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor takes the associated Compiler
  **
  new make(CompilerContext compiler)
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
    if (compiler.input.isScript)
        compiler.transientPod = LoadPod(compiler).load
    else if (!compiler.input.onlyJs)
        compiler.podFile = WritePod(compiler).write
//    if (compiler.input.onlyJs)
//        compiler.js = compiler.js
  }

}