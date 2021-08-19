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
    output := CompilerOutput.make
    output.mode = compiler.input.output

    switch (output.mode)
    {
      case CompilerOutputMode.transientPod:
        output.transientPod = LoadPod(compiler).load

      case CompilerOutputMode.podFile:
        output.podFile = WritePod(compiler).write

      case CompilerOutputMode.js:
        output.js = compiler.js

      default:
        throw err("Unknown output type: '$output.mode'", null)
    }

    compiler.output = output
  }

}