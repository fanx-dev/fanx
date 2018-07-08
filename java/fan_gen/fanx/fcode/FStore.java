//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Sep 05  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import java.util.*;
import java.util.zip.*;
import fanx.util.*;

/**
 * FStore models IO streams to use for reading and writing pod files.
 */
public abstract class FStore
{
//	public static String getFileBaseName(File file) {
//		String name = file.getName();
//		int pos = name.lastIndexOf('.');
//		if (pos < 0) return name;
//		return name.substring(0, pos);
//	}

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  /**
   * Construct a FStore to read from zipfile backing store.
   */
  public static FStore makeZip(java.io.File zipFile)
    throws Exception
  {
    if (zipFile == null) throw new IllegalStateException();
    return new ZipStore(zipFile, new java.util.zip.ZipFile(zipFile));
  }

//  /**
//   * Construct a FStore to read from a JAR's ClassLoader resources.
//   * If podName doesn't exist then throw UnknownPodErr.
//   */
//  public static FStore makeJarDist(ClassLoader loader, String podName)
//  {
//    JarDistStore store = new JarDistStore(loader);
//    if (store.hasPod(podName)) return store;
//    throw new RuntimeException("UnknownPodErr:"+podName);
//  }

//////////////////////////////////////////////////////////////////////////
// File Access
//////////////////////////////////////////////////////////////////////////

  /**
   * Return a backing file
   */
  public abstract java.io.File loadFile();

  /**
   * Return a list to use for Pod.files()
   */
  public abstract List<ZipEntryFile> podFiles(String podUri)
      throws IOException;

  /**
   * Convenience for read(path, false).
   */
  public final FStore.Input read(String path)
    throws IOException
  {
    return read(path, false);
  }

  /**
   * Open an input stream for the specified logical path.
   * Return null if not found.
   */
  public abstract FStore.Input read(String path, boolean required)
    throws IOException;

  /**
   * Read a file with the specified logical path into a memory
   * buffer.  Return null if not found.
   */
  public abstract Box readToBox(String path)
    throws IOException;

  /**
   * Close underlying file.
   */
  public abstract void close()
    throws IOException;

//////////////////////////////////////////////////////////////////////////
// FStore.Input
//////////////////////////////////////////////////////////////////////////

  /**
   * FStore.Input is used to read from a FStore file.
   */
  public static class Input
    extends DataInputStream
  {
    Input(FPod fpod, InputStream out) { super(out); this.fpod = fpod; }

    public final int    u1()  throws IOException { return readUnsignedByte(); }
    public final int    u2()  throws IOException { return readUnsignedShort(); }
    public final int    u4()  throws IOException { return readInt(); }
    public final long   u8()  throws IOException { return readLong(); }
    public final double f8()  throws IOException { return readDouble(); }
    public final String utf() throws IOException { return readUTF(); }
    public final String name() throws IOException { return fpod.name(u2()); }

    public final FPod fpod;
  }

//////////////////////////////////////////////////////////////////////////
// ZipStore
//////////////////////////////////////////////////////////////////////////

  static class ZipStore extends FStore
  {
    ZipStore(java.io.File loadFile, java.util.zip.ZipFile zipFile)
    {
      this.loadFile = loadFile;
      this.zipFile  = zipFile;
    }

    public java.io.File loadFile() { return loadFile; }

    public List<ZipEntryFile> podFiles(String podUri)
    {
      List<ZipEntryFile> list = new ArrayList<ZipEntryFile>();
      Enumeration en = zipFile.entries();
      while (en.hasMoreElements())
      {
        ZipEntry entry = (ZipEntry)en.nextElement();
        String name = entry.getName();
        if (name.startsWith("fcode/")) continue;
        if (name.endsWith(".class")) continue;
        String uri = (podUri + (entry.getName()));
        list.add(new ZipEntryFile(zipFile, entry, uri));
      }
      return list;
    }
    
    public FStore.Input read(String path, boolean required)
      throws IOException
    {
      ZipEntry entry = zipFile.getEntry(path);
      if (entry == null)
      {
        if (required)
          throw new IOException("Missing required file \"" + path + "\" in pod zip");
        else
          return null;
      }
      return new FStore.Input(fpod, zipFile.getInputStream(entry));
    }

    public Box readToBox(String path)
      throws IOException
    {
      ZipEntry entry = zipFile.getEntry(path);
      if (entry == null) return null;

      int size = (int)entry.getSize();
      byte[] buf = new byte[size];
      int n = 0;

      InputStream in = zipFile.getInputStream(entry);
      try
      {
        while (n < size)
          n += in.read(buf, n, size-n);
      }
      finally
      {
        try { in.close(); } catch (Exception e) {}
      }

      return new Box(buf);
    }

    public void close()
      throws IOException
    {
      zipFile.close();
    }

    final java.io.File loadFile;
    final java.util.zip.ZipFile zipFile;
  }

//////////////////////////////////////////////////////////////////////////
// JarDistStore
//////////////////////////////////////////////////////////////////////////

//  static class JarDistStore extends FStore
//  {
//    JarDistStore(ClassLoader loader) { this.loader = loader; }
//
//    public java.io.File loadFile() { return null; }
//
//    public boolean hasPod(String podName)
//    {
//      String path = "reflect/" + podName + "/meta.props";
//      InputStream in = loader.getResourceAsStream(path);
//      if (in == null) return false;
//      try { in.close(); } catch (Exception e) {}
//      return true;
//    }
//
//    public List<ZipEntryFile> podFiles(Uri podUri)
//      throws IOException
//    {
//      // JarDist build task generated "{res/pod}/res-manifiest.txt"
//      String manifestPath = "res/" + fpod.podName + "/res-manifest.txt";
//      BufferedReader in = new BufferedReader(new InputStreamReader(loader.getResourceAsStream(manifestPath)));
//      String line;
//      List<ZipEntryFile> list = new ArrayList<ZipEntryFile>();
//      while ((line = in.readLine()) != null)
//      {
//        if (line.length() == 0) continue;
//        String uri = (podUri + line);
//        String loaderPath = "res/" + fpod.podName + line;
//        File file = new ClassLoaderFile(loader, loaderPath, uri);
//        list.add(file);
//      }
//      return list;
//    }
//
//    public FStore.Input read(String path, boolean required)
//      throws IOException
//    {
//      path = "reflect/" + fpod.podName + "/" + path;
//      InputStream in = loader.getResourceAsStream(path);
//      if (in == null)
//      {
//        if (required)
//          throw new IOException("Missing required file \"" + path + "\" in pod zip");
//        else
//          return null;
//      }
//      return new FStore.Input(fpod, in);
//    }
//
//    public Box readToBox(String path)
//      throws IOException
//    {
//      path = "reflect/" + fpod.podName + "/" + path;
//      InputStream in = loader.getResourceAsStream(path);
//      if (in == null) return null;
//
//      byte[] temp = new byte[1024];
//      Box box = new Box();
//
//      try
//      {
//        while (true)
//        {
//          int n = in.read(temp, 0, 1024);
//          if (n < 0) break;
//          box.append(temp, n);
//        }
//      }
//      finally
//      {
//        try { in.close(); } catch (Exception e) {}
//      }
//
//      return box;
//    }
//
//    public void close() {}
//
//    ClassLoader loader;
//  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  FPod fpod;  // set by FPod in ctor

}