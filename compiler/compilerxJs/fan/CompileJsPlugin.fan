//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Dec 08  Andy Frank  Creation
//

using compilerx

**
** Fantom source to JavaScript source compiler - this class is
** plugged into the compiler pipeline by the compiler::CompileJs step.
**
class CompileJsPlugin : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext c) : super(c) {}

//////////////////////////////////////////////////////////////////////////
// Pipeline
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    buf       := StrBuf()
    support   := JsCompilerSupport(this.compiler)
    sourcemap := SourceMap(support)
    jsOut     := JsWriter(buf.out, sourcemap)

    jsPod = JsPod(support, compiler.pod, compiler.pod.types)
    jsPod.write(jsOut)

    compiler.jsPod = jsPod
    compiler.js    = buf.toStr

    buf.clear
    sourcemap.write(jsOut.line, buf.clear.out)
    compiler.jsSourceMap = buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  JsPod? jsPod  // JsPod AST

}
