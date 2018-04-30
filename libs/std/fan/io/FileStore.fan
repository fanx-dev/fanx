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
const abstract class FileStore
{
  ** Protected constructor for subclasses.
  //@NoDoc protected new makeNew()

  ** Total number of bytes in the store or null if unknown.
  abstract Int? totalSpace()

  ** Number of bytes available for use by the application or null if unknown.
  abstract Int? availSpace()

  ** Number of bytes unallocated in the store or null if unknown.
  abstract Int? freeSpace()
}

**************************************************************************
** LocalFileStore
**************************************************************************

internal const class LocalFileStore : FileStore
{
  //private new init()
  native override Int? totalSpace()
  native override Int? availSpace()
  native override Int? freeSpace()
}