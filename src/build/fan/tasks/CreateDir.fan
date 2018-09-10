//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** CreateDir is used to create a directory
**
class CreateDir : Task
{

  new make(BuildScript script, File dir)
    : super(script)
  {
    this.dir = dir
  }

  override Void run()
  {
    try
    {
      if (!dir.exists)
        log.info("CreateDir [$dir]")
      dir.create
      if (!dir.isDir) throw Err.make
    }
    catch (Err err)
    {
      throw fatal("Cannot create dir [$dir]", err)
    }
  }

  File dir
}