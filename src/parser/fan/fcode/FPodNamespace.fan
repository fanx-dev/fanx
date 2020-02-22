//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   29 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** FPodNamespace implements Namespace by reading the fcode
** from pods directly.  Its not as efficient as using reflection,
** but lets us compile against a different pod set.
**
class FPodNamespace : CNamespace
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Make a FPod namespace which looks in the specified directory
  ** to resolve pod files or null to delegate to 'Env.findPodFile'.
  **
  new make(File? dir)
  {
    this.dir = dir
    init
  }

//////////////////////////////////////////////////////////////////////////
// CNamespace
//////////////////////////////////////////////////////////////////////////

  **
  ** Map to an FPod
  **
  protected override FPod? findPod(Str podName)
  {
    // try to find it
    File? file
    try
    {
      if (dir != null)
        file = dir + `${podName}.pod`
      else
        file = Env.cur.findPodFile(podName)
    }
    catch (Err e) {
      e.trace
      return null
    }

    //echo("find depends pod: $file")

    //get from memory for script pod
    if (file == null || !file.exists) {
      pod := Pod.find(podName, false)
      if (pod == null) return null
      Buf? buf := pod->_getCompilerCache
      if (buf == null) return null
      buf.seek(0)
      fpod := FPod(this, podName, Zip.read(buf.in))
      fpod.readStream
      return fpod
    }

    // load it
    fpod := FPod(this, podName, Zip.open(file))
    fpod.read
    return fpod
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** where to look for pod or null to delegate to Env.findPodFile
  const File? dir
}