//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Sep 05  Brian Frank  Creation
//   7 Oct 06  Brian Frank  Port from Java to Fan
//

**
** WritePod writes the FPod to a zip file.
**
class WritePod : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Not used, use write instead
  **
  override Void run() { throw UnsupportedErr.make }

  **
  ** Run the step and return pod file written
  **
  File write()
  {
    dir  := compiler.input.outDir
    fpod := compiler.fpod
    podName := fpod.name
    podFile := dir + "${podName}.pod".toUri
    loc = Loc.makeFile(podFile)

    log.info("WritePod [${podFile.toStr}]")

    //may refer by other process
    //if (podFile.exists) podFile.delete

    // create output directory
    dir.create

    Zip? zip := null
    try
    {
      // open zip store
      zip = Zip.write(podFile.out)

      // write fpod data structures into zip file
      fpod.write(zip)

      // write javascript
      if (compiler.js != null)
      {
        writeStr(zip, `${podName}.js`, compiler.js)
        if (compiler.jsSourceMap != null)
        {
          writeStr(zip, `${podName}.js.map`, compiler.jsSourceMap)
        }
      }

      // if explicit locale props
      if (compiler.localeProps != null)
        writeStr(zip, `locale/en.props`, compiler.localeProps)

      // write resource files
      if (compiler.input.resFiles != null)
        compiler.input.resFiles.each |file| { writeRes(zip, file) }

      // if including fandoc write it out too
      if (compiler.input.includeDoc) writeDocs(zip)

      // if including source write it out too
      if (compiler.input.includeSrc)
        compiler.input.srcFiles.each |file| { writeSrc(zip, file) }
    }
    catch (CompilerErr e)
    {
      throw e
    }
    catch (Err e)
    {
      e.trace
      throw errReport(CompilerErr("Cannot write", loc, e))
    }

    // close file
    if (zip != null) zip.close
    return podFile
  }

//////////////////////////////////////////////////////////////////////////
// JavaScript
//////////////////////////////////////////////////////////////////////////

  private Void writeStr(Zip zip, Uri path, Str content)
  {
    try
      zip.writeNext(path, TimePoint.now).print(content).close
    catch (Err e)
      throw errReport(CompilerErr("Cannot write resource '$path'", loc, e))
  }

//////////////////////////////////////////////////////////////////////////
// Resource
//////////////////////////////////////////////////////////////////////////

  private Void writeRes(Zip zip, File file, Uri? path := null)
  {
    input := compiler.input
    if (path == null)
    {
      path = file.uri
      path = path.relTo(input.baseDir.uri)
      //echo("$path relTo ${input.baseDir.uri} is $path")
    }

    // ignore stupid OS X .DS_Store
    if (file.name == ".DS_Store") return

    // if locale/en.props and we have explicit definition
    // from LocaleProps then skip it
    if (path == `locale/en.props` && compiler.localeProps != null)
      return

    // if resource is jar file, then unzip it
    if (file.ext == "jar") { writeResZip(zip, file); return }

    try
    {
      out := zip.writeNext(path, file.modified)
      file.in.pipe(out)
      out.close
    }
    catch (Err e)
    {
      if (!file.isDir)
        throw errReport(CompilerErr("Cannot write resource file '$path': $e", loc, e))
    }
  }

  private Void writeResZip(Zip zip, File resFile)
  {
    // open resource file as a zip file
    Zip? resZip := null
    try
      resZip = Zip.open(resFile)
    catch (Err e)
      errReport(CompilerErr("Cannot open resource file as zip: 'f'", loc, e))

    // process each entry in zip as resource
    try
    {
      resZip.contents.each |c| { writeRes(zip, c, c.uri) }
    }
    finally resZip.close
  }

//////////////////////////////////////////////////////////////////////////
// Source Code
//////////////////////////////////////////////////////////////////////////

  private Void writeSrc(Zip zip, File file)
  {
    writeRes(zip, file, `src/$file.name`)
  }

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  private Void writeDocs(Zip zip)
  {
    writePodDocs(zip)
    compiler.pod.types.each |type|
    {
      if (type.isDocumented) writeApiDoc(zip, type)
    }
  }

  **
  ** If there is a *.fandoc as peer to build.fan then
  ** copy it into doc/
  **
  private Void writePodDocs(Zip zip)
  {
    files := compiler.input.baseDir.list.findAll |f| { f.ext == "fandoc" }
    files.each |f|
    {
      writeRes(zip, f, `doc/${f.name}`)
    }
  }

  **
  ** Write the API doc text file used by compilerDoc
  **
  private Void writeApiDoc(Zip zip, TypeDef t)
  {
    try
    {
      out := zip.writeNext("doc/${t.name}.apidoc".toUri)
      ApiDocWriter(out).writeType(t).close
    }
    catch (Err e)
    {
      throw errReport(CompilerErr("Cannot write fandoc '$t.name'", t.loc, e))
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Loc? loc
  private FacetDef[] noFacets := FacetDef[,].ro
}