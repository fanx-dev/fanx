//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 06  Brian Frank  Creation
//
package fanx.fcode;

/**
 * ZipEntryFile represents a file entry inside a zip file.
 */
public class ZipEntryFile
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public ZipEntryFile(java.util.zip.ZipFile parent, java.util.zip.ZipEntry entry, String uri)
  {
    this.parent = parent;
    this.entry  = entry;
    this.uri = uri;
  }

//////////////////////////////////////////////////////////////////////////
// File
//////////////////////////////////////////////////////////////////////////

  public boolean exists()
  {
    return true;
  }

  public Long size()
  {
    if (entry.isDirectory()) return null;
    long size = entry.getSize();
    if (size < 0) return null;
    return Long.valueOf(size);
  }

//  public InStream in(Long bufSize)
//  {
//    try
//    {
//      java.io.InputStream in;
//      if (parent instanceof Zip)
//      {
//        // never buffer if using ZipInputStream
//        in = new java.io.FilterInputStream(((Zip)parent).zipIn) { public void close() {} };
//      }
//      else
//      {
//        in = ((java.util.zip.ZipFile)parent).getInputStream(entry);
//
//        // buffer if specified
//        if (bufSize != null && bufSize.longValue() != 0)
//          in = new java.io.BufferedInputStream(in, bufSize.intValue());
//      }
//
//      // return as fan stream
//      return new SysInStream(in);
//    }
//    catch (java.io.IOException e)
//    {
//      throw IOErr.make(e);
//    }
//  }
//
//  public OutStream out(boolean append, Long bufSize)
//  {
//    throw IOErr.make("ZipEntryFile is readonly");
//  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  final Object parent;
  final java.util.zip.ZipEntry entry;
  final String uri;

}