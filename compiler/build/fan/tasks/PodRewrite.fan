//
// Copyright (c) 2021, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Aug 2021  Brian Frank  Creation
//

**
** PodRewrite is used to update the contents of one or more pod files.
** It can be used to strip javascript, source code, and docs.  However it
** cannot strip test code - that requires a recompile from source with
** the 'stripTest' flag.
**
class PodRewrite : Task
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct uninitialized task
  **
  new make(BuildScript script)
    : super(script)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the task
  **
  override Void run()
  {
    // config checking
    if (pods.isEmpty) throw fatal("Not configured: PodRewrite.pods")
    if (outDir == null) throw fatal("Not configured: PodRewrite.outDir")

    // map pod names/files to list of zip files
    File[] podFiles := pods.map |pod->File|
    {
      if (pod is Str) pod = Env.cur.findPodFile(pod)
      return pod as File ?: throw Err("Pod must be pod name or file: $pod [$pod.typeof]")
    }

    log.info("PodRewrite")
    log.indent
    podFiles.each |inFile|
    {
      log.info("Rewrite [$inFile.osPath]")
      outFile := outDir + inFile.name.toUri
      rewrite(inFile, outFile.out)
    }
    log.unindent
  }

  **
  ** Rewrite the given pod file with the configured options
  **
  Void rewrite(File podFile, OutStream out)
  {
    zipIn  := Zip.read(podFile.in)
    zipOut := Zip.write(out)
    File? entry
    while ((entry = zipIn.readNext()) != null)
    {
      data := entry.readAllBuf
      if (strip(entry, data)) continue
      zipOut.writeNext(entry.uri, entry.modified).writeBuf(data).close
    }
    zipOut.close
  }


  ** Return if we should strip the given file
  private Bool strip(File entry, Buf data)
  {
    if (stripJs)
    {
      if (entry.path.size == 1 && entry.name.contains(".js")) return true
    }

    if (stripDocs)
    {
      if (entry.path.first == "doc") return true
    }

    if (stripSrc)
    {
      if (entry.path.first == "src") return true
    }

    return false
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** Required output directory to place rewritten pods
  File? outDir

  ** List of pod files or pod names to rewrite
  Obj[] pods := Obj[,]

  ** Remove pod's JavaScript files: "pod.js" and "pod.js.map"
  Bool stripJs

  ** Remove pod's source code if bundled into the pod zip
  Bool stripSrc

  ** Remove pod's documentation: pod.fandoc and all api docs
  Bool stripDocs
}