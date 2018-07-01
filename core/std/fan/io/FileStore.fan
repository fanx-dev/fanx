//
// Copyright (c) 2013, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Sep 13  Brian Frank  Creation
//

**
** FileStore represents the storage pool, device, partition, or volume
** used to store files.
**
const class FileStore
{
  ** Protected constructor for subclasses.
  new make(|This| f) { f(this) }

  ** Total number of bytes in the store or null if unknown.
  const Int totalSpace

  ** Number of bytes available for use by the application or null if unknown.
  const Int availSpace

  ** Number of bytes unallocated in the store or null if unknown.
  const Int freeSpace
}

