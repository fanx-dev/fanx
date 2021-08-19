//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Nov 10  Brian Frank  Creation
//
package fan.std;

import fan.sys.IOErr;
import fan.sys.List;
import fan.sys.UnsupportedErr;

/**
 * ClassLoaderFile represents a file loaded as a resource from the class loader.
 */
public class ClassLoaderFile
  extends File
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public ClassLoaderFile(ClassLoader loader, String loaderPath, Uri uri)
  {
	File.privateMake$(this, uri);
    this.loader     = loader;
    this.loaderPath = loaderPath;
  }

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

//  public Type typeof() { return Sys.ClassLoaderFileType; }

//////////////////////////////////////////////////////////////////////////
// File
//////////////////////////////////////////////////////////////////////////

  public boolean exists()
  {
    return true;
  }

  public long size()
  {
    initMeta();
    return size;
  }

  public TimePoint modified()
  {
    initMeta();
    return TimePoint.fromMillis(modified);
  }

  public void modified(TimePoint time)
  {
    throw IOErr.make("ClassLoaderFile is readonly");
  }

  public String osPath()
  {
    return null;
  }

  public File parent()
  {
    return null;
  }

  public List list()
  {
	  return List.defVal;
  }

  public File normalize()
  {
    return this;
  }

  public File plus(Uri uri, boolean checkSlash)
  {
    throw UnsupportedErr.make("ClassLoaderFile.plus");
  }

//////////////////////////////////////////////////////////////////////////
// File Management
//////////////////////////////////////////////////////////////////////////

  public File create()
  {
    throw IOErr.make("ClassLoaderFile is readonly");
  }

  public File moveTo(File to)
  {
    throw IOErr.make("ClassLoaderFile is readonly");
  }

  public void delete()
  {
    throw IOErr.make("ClassLoaderFile is readonly");
  }

  public File deleteOnExit()
  {
    throw IOErr.make("ClassLoaderFile is readonly");
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  public Buf open(String mode)
  {
    throw UnsupportedErr.make("ClassLoaderFile.open");
  }

  public Buf mmap(String mode, long pos, long size)
  {
    throw UnsupportedErr.make("ClassLoaderFile.mmap");
  }

  public InStream in(long bufSize)
  {
    // get stream from class loader
    java.io.InputStream in = loader.getResourceAsStream(loaderPath);
    // return as fan stream
    return SysInStreamPeer.fromJava(in, bufSize);
  }

  public OutStream out(boolean append, long bufSize)
  {
    throw IOErr.make("ClassLoaderFile is readonly");
  }

//////////////////////////////////////////////////////////////////////////
// InitMeta
//////////////////////////////////////////////////////////////////////////

  private void initMeta()
  {
    if (inited) return;
    try
    {
      java.net.URL url = loader.getResource(loaderPath);
      java.net.URLConnection conn = url.openConnection();
      size = conn.getContentLength();
      modified = conn.getLastModified();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
    inited = true;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  final ClassLoader loader;
  final String loaderPath;
  private boolean inited;
  private int size;
  private long modified;
  
}