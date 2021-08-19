//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Sep 08  Brian Frank  Creation
//

**
** CreateZip is used to create a zip file from a directory on the file system.
**
class CreateZip : Task
{

  new make(BuildScript script)
    : super(script)
  {
    this.filter  = |File f->Bool| { return true }
  }

  override Void run()
  {
    // basic sanity checking
    if (inDirs == null || inDirs.isEmpty) throw fatal("Not configured: CreateZip.inDirs")
    if (outFile == null) throw fatal("Not configured: CreateZip.outFile")

    // ensure outFile is not under inDir (although we do allow
    // outFile to be placed directly under inDir as convenience)
    inDirs.each |File inDir|
    {
      if (!inDir.isDir) throw fatal("Not a directory: $inDir")
      inPath := inDir.normalize.pathStr
      outPath := outFile.normalize.parent.pathStr
      if (outPath.startsWith(inPath) && inPath != outPath)
        throw fatal("Cannot set outFile under inDir: $outPath under $inPath")
    }

    // ensure prefixPath is formatted correctly
    if (pathPrefix != null)
    {
      if (pathPrefix.isPathAbs) throw fatal("Prefix path must not be absolute: $pathPrefix")
      if (!pathPrefix.isDir) throw fatal("Prefix path must be dir: $pathPrefix")
    }

    // zip it!
    log.info("CreateZip [$outFile]")
    out := Zip.write(outFile.out)
    try
    {
      inDirs.each |File inDir|
      {
        inDir.list.each |File f|
        {
          if (f.name == outFile.name) return
          uri := f.name.toUri
          if (pathPrefix != null) uri = pathPrefix + uri
          zip(out, f, uri.toStr)
        }
      }
    }
    catch (Err err)
    {
      throw fatal("Cannot create zip [$outFile]", err)
    }
    finally
    {
      out.close
    }
  }

  private Void zip(Zip out, File f, Str path)
  {
    if (!filter.call(f, path)) return
    if (f.isDir)
    {
      f.list.each |File sub|
      {
        zip(out, sub, path + "/" + sub.name)
      }
    }
    else
    {
      o := out.writeNext(path.toUri, f.modified)
      f.in.pipe(o)
      o.close
    }
  }

  ** Required output zip file to create
  File? outFile

  ** Required directories to zip up.  The contents of these dirs are
  ** recursively zipped up with zip paths relative to this root
  ** directory.
  File[]? inDirs

  ** This function is called on each file under 'inDir'; if true
  ** returned it is included in the zip, if false then it is excluded.
  ** Returning false for a directory will skip recursing the entire
  ** directory.
  |File f, Str path->Bool| filter

  **
  ** Specifies the top level directory inside the zip file
  ** prefixed to all the files.  For example use 'acme/' to
  ** put everything inside the zip file inside a "acme" directory.
  ** The URI used must end with a slash.  If null, then no path
  ** prefix is used.
  **
  Uri? pathPrefix := null
}