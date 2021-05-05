//
// Copyright (c) 2019, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   09 May 19  Matthew Giannini  Creation
//
package fan.std;

import java.util.stream.*;

import fan.sys.ArgErr;
import fan.sys.Err;
import fan.sys.IOErr;
import fan.sys.List;
import fan.sys.UnsupportedErr;

import java.util.function.*;
import java.nio.file.*;
import java.nio.file.attribute.*;
import fanx.interop.Interop;

/**
 * PathFile represents a file backed by a java.nio.file.Path
 */
public class PathFile
  extends File
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public PathFile(Path path)
  {
    File.privateMake$(this, pathUri(path));
    this.path = path;
  }

  static Uri pathUri(Path path)
  {
    Uri uri = Uri.fromStr(path.toUri().toString());
    if (Files.isDirectory(path)) uri = uri.plusSlash();
    return uri;
  }

  public final Path path;

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

//  public Type typeof() { return Sys.PathFileType; }

//////////////////////////////////////////////////////////////////////////
// File
//////////////////////////////////////////////////////////////////////////

  public boolean exists()
  {
    return Files.exists(path);
  }

  public long size()
  {
    try
    {
      if (isDir()) return 0;
      final long size = Files.size(path);
      if (size < 0) return 0;
      return (size);
    }
    catch (Exception e)
    {
      return 0;
    }
  }

  public TimePoint modified()
  {
    try
    {
      return TimePoint.fromMillis(Files.getLastModifiedTime(path).toMillis());
    }
    catch (Exception e)
    {
      return null;
    }
  }

  public void modified(TimePoint time)
  {
    try
    {
      Files.setLastModifiedTime(path, FileTime.fromMillis(time.toMillis()));
    }
    catch (Exception e)
    {
      throw Err.make(e);
    }
  }

  public String osPath()
  {
    java.io.File file = toJavaFile();
    return file == null ? null : file.getPath();
  }

  public File parent()
  {
    final Path parentPath = path.getParent();
    if (parentPath == null) return null;
    return new PathFile(parentPath);
  }
  
  public List list() {
	  try {
		  Stream<PathFile> s = Files.list(this.path).map(new Function<Path, PathFile>() {
	        @Override
	        public PathFile apply(Path path) { return new PathFile(path); }
	      });
		  return Interop.toFan(s, File.$Type);
	  } catch (Exception e) {
		  throw Err.make(e);
	  }
  }

//  public List list(Regex pattern)      { return doList(pattern, '*'); }
//  public List listFiles(Regex pattern) { return doList(pattern, 'f'); }
//  public List listDir(Regex pattern)   { return doList(pattern, 'd'); }
//
//  private List doList(final Regex pattern, final int mode)
//  {
//    try
//    {
//      Stream<PathFile> s = Files.list(this.path).filter(new Predicate<Path>() {
//        @Override
//        public boolean test(Path child) {
//          if (mode == 'd' && !Files.isDirectory(child)) return false;
//          if (mode == 'f' && Files.isDirectory(child)) return false;
//          if (pattern == null) return true;
//          return pattern.matches(child.getFileName().toString());
//        }
//      })
//      .map(new Function<Path, PathFile>() {
//        @Override
//        public PathFile apply(Path path) { return new PathFile(path); }
//      });
//      return Interop.toFan(s, Sys.PathFileType);
//    }
//    catch (Exception e)
//    {
//      throw Err.make(e);
//    }
//  }

  public File normalize()
  {
    return new PathFile(path.normalize());
  }

  public File plus(Uri uri, boolean checkSlash)
  {
    final Uri    newUri = this.uri().plus(uri);
    final String uriStr = newUri.toString();
    String pathStr = uriStr.startsWith("file:///")
      ? uriStr.substring("file:///".length())
      : newUri.pathStr;
    Path p = this.path.getFileSystem().getPath(pathStr);

    // TODO: on windows we will eventually hit empty pathStr "", which is interpreted
    // as the "default" directory of the filesystem (not necessarily the root).
    // if (!newUri.equals(pathUri(p))) throw IOErr.make("Mismatch uri " + newUri + " != " + pathUri(p));

    if (Files.isDirectory(p) && !newUri.isDir() && checkSlash)
      throw IOErr.make(p + " is directory, but resulting uri is not: " + newUri);
    return new PathFile(p);
  }

//////////////////////////////////////////////////////////////////////////
// File Management
//////////////////////////////////////////////////////////////////////////

  public File create()
  {
    if (isDir())
      createDir();
    else
      createFile();
    return this;
  }

  private void createFile()
  {
    if (Files.exists(path))
    {
      if (Files.isDirectory(path))
        throw IOErr.make("Already exists as directory: " + path);
    }
    else
    {
      try
      {
        final Path parent = path.getParent();
        if (parent != null && !Files.exists(parent))
          Files.createDirectories(parent);
      }
      catch (java.io.IOException e)
      {
        throw IOErr.make("Cannot create parent directories for: " + path, e);
      }
    }

    try
    {
      java.io.OutputStream out = Files.newOutputStream(path);
      out.close();
    }
    catch (java.io.IOException e)
    {
      throw IOErr.make(e);
    }
  }

  private void createDir()
  {
    if (Files.exists(path))
    {
      if (!Files.isDirectory(path))
        throw IOErr.make("Already exists as file: " + path);
    }
    else
    {
      try
      {
        Files.createDirectories(path);
      }
      catch (java.io.IOException e)
      {
        throw IOErr.make(e);
      }
    }
  }

  public File moveTo(final File to)
  {
    if (isDir() != to.isDir())
    {
      if (isDir())
        throw ArgErr.make("moveTo must be dir: " + to);
      else
        throw ArgErr.make("moveTo must not be dir: " + to);
    }

    if (to.exists())
      throw IOErr.make("moveTo already exists: " + to);

    if (!Files.isDirectory(this.path))
    {
      final File destParent = to.parent();
      if (destParent != null && !destParent.exists())
        destParent.create();
    }

    try
    {
      Path destPath = null;
      if (to instanceof LocalFile)
        destPath = ((java.io.File)(((LocalFile)to).jfile)).toPath();
      else if (to instanceof PathFile)
        destPath = ((PathFile)to).path;
      else
        throw IOErr.make("Cannot move PathFile to " + to.typeof());

      Files.copy(this.path, destPath);
    }
    catch (java.io.IOException err)
    {
      throw IOErr.make(err);
    }

    return to;
  }

  public void delete()
  {
    if (exists() && Files.isDirectory(path))
    {
      List kids = list();
      for (int i=0; i<kids.sz(); ++i)
        ((File)kids.get(i)).delete();
    }

    try
    {
      Files.deleteIfExists(this.path);
    }
    catch (java.io.IOException e)
    {
      throw IOErr.make("Cannot delete: " + path, e);
    }
  }

  public File deleteOnExit()
  {
    java.io.File file = toJavaFile();
    if (file != null) file.deleteOnExit();
    return this;
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  public Buf open(String mode)
  {
    throw UnsupportedErr.make("PathFile");
  }

  public Buf mmap(String mode, long pos, long size)
  {
    throw UnsupportedErr.make("PathFile");
  }

  public InStream in(long bufSize)
  {
    try
    {
      return SysInStreamPeer.fromJava(Files.newInputStream(this.path), bufSize);
    }
    catch (java.io.IOException err)
    {
      throw IOErr.make(err);
    }
  }

  public OutStream out(boolean append, long bufSize)
  {
    try
    {
      File parent = this.parent();
      if (parent != null && !parent.exists()) parent.create();
      java.io.OutputStream out = append
        ? Files.newOutputStream(this.path, StandardOpenOption.APPEND)
        : Files.newOutputStream(this.path);
      return SysOutStreamPeer.fromJava(out, bufSize);
    }
    catch (java.io.IOException err)
    {
      throw IOErr.make(err);
    }
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  private java.io.File toJavaFile()
  {
    try
    {
      return this.path.toFile();
    }
    catch (UnsupportedOperationException err)
    {
      return null;
    }
  }

}