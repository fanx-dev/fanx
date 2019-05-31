//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//
package fanx.util;

import java.io.*;
import java.util.zip.*;

/**
 * FileUtil provides all the methods that you just
 * wonder why java.io.File doesn't provide.
 */
public class FileUtil
{
  public static String osPahtToUri(String path, boolean checkDir) {
	String osPath = path;
	// deal with Windoze drive name
    if (path.length() > 2 && path.charAt(1) == ':' && path.charAt(0) != '/')
      path = "/"+path;
    
	if (java.io.File.separatorChar == '\\') {
		path = path.replace("\\", "/");
	}
	
	if (checkDir) {
		File file = new File(osPath);
		if (file.exists()) {
			if (file.isDirectory()) {
				if (path.charAt(path.length() - 1) != '/') {
					path = path + "/";
				}
			}
			else {
				if (path.charAt(path.length() - 1) == '/') {
					throw new IllegalArgumentException(osPath + " is dir");
				}
			}
		}
	}
	return path;
  }

//////////////////////////////////////////////////////////////////////////
// File Management
//////////////////////////////////////////////////////////////////////////

  /**
   * Same as File.listFiles()
   */
  public static File[] list(File f)
  {
    String[] names = f.list();
    if (names == null || names.length == 0) return none;
    File[] files= new File[names.length];
    for (int i=0; i<names.length; ++i)
      files[i] = new File(f, names[i]);
    return files;
  }

  /**
   * Same as File.getParentFile()
   */
  public static File parent(File f)
  {
    return new File(f.getParent());
  }

  /**
   * Same as File.mkdirs() exception IOException is thrown on error.
   */
  public static void mkdir(File f)
    throws IOException
  {
    if (f.exists() && f.isDirectory()) return;

    if (!f.mkdirs())
      throw new IOException("Cannot mkdir: " + f);
  }

  /**
   * Recursive delete.  Actually throw IOException on error.
   */
  public static void delete(File f)
    throws IOException
  {
    if (!f.exists()) return;

    if (f.isDirectory())
    {
      File[] kids = list(f);
      for (int i=0; kids != null && i<kids.length; ++i)
        delete(kids[i]);
    }

    if (!f.delete())
      throw new IOException("Cannot delete: " + f);
  }

  /**
   * Create a zip from the specified directory.
   */
  public static void zip(File srcDir, File zipFile)
    throws IOException
  {
    mkdir(parent(zipFile));

    ZipOutputStream out = new ZipOutputStream(new BufferedOutputStream(new FileOutputStream(zipFile)));
    try
    {
      File[] kids = list(srcDir);
      for (int i=0; kids != null && i<kids.length; ++i)
        zip(kids[i], "", out);
    }
    finally
    {
      out.close();
    }
  }

  private static void zip(File src, String parentPath, ZipOutputStream out)
    throws IOException
  {
    String name = src.getName();
    String path = (parentPath == "") ? name : parentPath + "/" + name;
    if (src.isDirectory())
    {
      File[] kids = list(src);
      for (int i=0; kids != null && i<kids.length; ++i)
        zip(kids[i], path, out);
    }
    else
    {
      out.putNextEntry(new ZipEntry(path));
      InputStream in = new BufferedInputStream(new FileInputStream(src));
      try
      {
        pipe(in, out);
      }
      finally
      {
        try { in.close(); } catch (Exception e) {}
      }
      out.closeEntry();
    }
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  /**
   * Copy file with overwrite behavior.
   */
  public static void copy(File from, File to)
    throws IOException
  {
    InputStream in = new BufferedInputStream(new FileInputStream(from));
    try
    {
      OutputStream out = new BufferedOutputStream(new FileOutputStream(to));
      try
      {
        pipe(in, out);
      }
      finally { try { out.close(); } catch (Exception e) {} }
    }
    finally { try { in.close(); } catch (Exception e) {} }
  }

  /**
   * Pipe all the bytes available from the input stream to
   * the output stream.
   */
  public static void pipe(InputStream in, OutputStream out)
    throws IOException
  {
    byte[] buf = new byte[4096];
    int n;
    while ((n = in.read(buf, 0, buf.length)) >= 0)
      out.write(buf, 0, n);
  }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  /**
   * Read the specified text file into a memory char buffer.
   * The file *must* be UTF8 encoded.  This method also normalizes
   * all newlines so that \r and \r\n are replaced with \n.
   */
  public static char[] read(File f)
    throws IOException
  {
    // can't ever have more characters than bytes in file,
    // for ASCII this will be an exact size (so we don't
    // have to take a resize hit)
    char[] buf  = new char[(int)f.length()];
    int n = 0;

    // open file
    InputStream in = new BufferedInputStream(new FileInputStream(f));
    try
    {
      // read characters
      int c, last=-1;
      while ((c = in.read()) >= 0)
      {
        // if not ASCII, then read rest of character
        if ((c & 0x80) != 0) c = readUtf8(c, in);

        // normalize newlines and add to buffer
        if (c == '\r') buf[n++] = '\n';
        else if (last == '\r' && c == '\n') continue;
        else buf[n++] = (char)c;
        last = c;
      }
    }
    finally
    {
      in.close();
    }

    // if we don't need to trim, then just return buf
    if (n == buf.length) return buf;

    // trim to size
    char[] trim = new char[n];
    System.arraycopy(buf, 0, trim, 0, n);
    return trim;
  }

  private static int readUtf8(int c0, InputStream in)
    throws IOException
  {
    // at this point 0xxx xxxx (ASCII) is already handled
    // since it is inlined into read() itself

    int c1, c2, c3;
    switch (c0 >> 4)
    {
      case 12:
      case 13:
        // 110x xxxx   10xx xxxx
        c1 = in.read();
        if ((c1 & 0xC0) != 0x80)
          throw new UTFDataFormatException(Integer.toHexString(c0));
        return ((c0 & 0x1F) << 6) | ((c1 & 0x3F) << 0);
      case 14:
        // 1110 xxxx  10xx xxxx  10xx xxxx
        c1 = in.read();
        c2 = in.read();
        if (((c1 & 0xC0) != 0x80) || ((c2 & 0xC0) != 0x80))
          throw new UTFDataFormatException();
        return ((c0  & 0x0F) << 12) | ((c1 & 0x3F) << 6)  | ((c2 & 0x3F) << 0);
      case 15:
        // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
        /* I think this is valid, but Java doesn't seem to output
           characters this high - so cap things below this
        c1 = in.read();
        c2 = in.read();
        c3 = in.read();
        if (((c1 & 0xC0) != 0x80) || ((c2 & 0xC0) != 0x80) || ((c3 & 0xC0) != 0x80))
          throw new UTFDataFormatException();
        return ((c0  & 0x07) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6)  | ((c3 & 0x3F) << 0);
        */
        throw new UTFDataFormatException(Integer.toHexString(c0));
      default:
        throw new UTFDataFormatException(Integer.toHexString(c0));
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public static final File[] none = new File[0];

}