//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** Delete is used to delete a file or directory.
**
class Delete : Task
{

  new make(BuildScript script, File file)
    : super(script)
  {
    this.file = file
  }

  override Void run()
  {
    try
    {
      if (!file.exists) return
      log.info("Delete [$file]")
      file.delete
    }
    catch (Err err)
    {
      log.err("Cannot delete file [$file]", err)
    }
  }

  File file
}