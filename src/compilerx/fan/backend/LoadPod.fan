//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Aug 06  Brian Frank  Creation
//

**
** LoadPod is used to immediately load the pod which has
** just been successfully compiled into Compiler.fpod.  This
** step is only used with script compiles.
**
class LoadPod : CompilerStep
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
  ** Not used, use load instead
  **
  override Void run() { throw UnsupportedErr.make }

  **
  ** Run the step and return loaded Pod instance
  **
  Pod load()
  {
    // create memory buffer to store pod zip
    buf := Buf(4096)

    // write the fpod to memory buf
    fpod := compiler.fpod
    fpod.zip = Zip.write(buf.out)
    fpod.write
    fpod.zip.close
    buf.flip

    //save to temp file for FPodNamespace
    //tempFile := Env.cur.tempDir+`scriptPods/${pod.name}.pod`
    //tempFile.out.writeBuf(buf).close
    //buf.seek(0)

    // have Sys load it up
    pod := Pod.load(buf.in)

    //tempFile.deleteOnExit
    pod._setCompilerCache(buf)
    return pod
  }

}