//
//Copyright (c) 2006, Brian Frank and Andy Frank
//Licensed under the Academic Free License version 3.0
//
//History:
//18 Aug 06  Brian Frank  Creation
//
package fan.std;

import java.io.IOException;
import java.util.Enumeration;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import fan.sys.*;
import fanx.main.Sys;
import fanx.main.Type;

import java.util.zip.GZIPOutputStream;
import java.util.zip.GZIPInputStream;
import java.util.zip.Deflater;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.Inflater;
import java.util.zip.InflaterInputStream;

/**
* Zip
*/
public final class Zip
extends FanObj
{

//////////////////////////////////////////////////////////////////////////
//Construction
//////////////////////////////////////////////////////////////////////////

public static Zip open(File file) { return new Zip(file); }

private Zip(File f)
{
 try
 {
   // only support local files
   if (!(f instanceof LocalFile))
     throw IOErr.make("Only local files supported: " + f);

   // open the file
   this.file = (LocalFile)f;
   this.zipFile = new ZipFile(LocalFilePeer.toJava(file));
 }
 catch (java.io.IOException e)
 {
   throw IOErr.make(e);
 }
}

public static Zip read(InStream in) { return new Zip(in); }

private Zip(InStream in)
{
 this.zipIn = new ZipInputStream(SysInStreamPeer.toJava(in));
}

public static Zip write(OutStream out) { return new Zip(out); }

private Zip(OutStream out)
{
 this.zipOut = new ZipOutputStream(SysOutStreamPeer.toJava(out));
}

//////////////////////////////////////////////////////////////////////////
//Obj
//////////////////////////////////////////////////////////////////////////

private static Type type;
public Type typeof() { 
	if (type == null) {
		type = Sys.findType("std::Zip");
	}
	return type;
}

public String toStr()
{
 if (file != null) return file.toStr();
 return super.toStr();
}

//////////////////////////////////////////////////////////////////////////
//Access
//////////////////////////////////////////////////////////////////////////

public File file()
{
 return file;
}

public Map contents()
{
 if (contents == null)
 {
   if (zipFile == null) return null;
   contents = contents(zipFile);
 }
 return contents.ro();
}

public static Map contents(ZipFile zipFile)
{
 Map c = Map.make();
 Enumeration e = zipFile.entries();
 while (e.hasMoreElements())
 {
   ZipEntry entry = (ZipEntry)e.nextElement();
   ZipEntryFile f = new fan.std.ZipEntryFile(zipFile, entry);
   c.set(f.uri, f);
 }
 return c;
}

public File readNext()
{
 if (zipIn == null) throw UnsupportedErr.make("Zip not opened for reading");
 try
 {
   ZipEntry entry = zipIn.getNextEntry();
   if (entry == null) return null;
   return new fan.std.ZipEntryFile(this, entry);
 }
 catch (java.io.IOException e)
 {
   throw IOErr.make(e);
 }
}

public OutStream writeNext(Uri path) { return writeNext(path, TimePoint.now()); }
public OutStream writeNext(Uri path, TimePoint modifyTime)
{
 if (zipOut == null) throw UnsupportedErr.make("Zip not opened for writing");
 if (path.frag != null) throw ArgErr.make("Path must not contain fragment: " + path);
 if (path.queryStr() != null) throw ArgErr.make("Path must not contain query: " + path);

 // Java 1.7+ supports ZIP64 which supports over 65,535 files, but
 // previous versions silently fail which is really bad; so add
 // Fantom specific sanity check here
// if (Sys.javaVersion < Sys.JAVA_1_7)
// {
//   if (zipOutCount >= 65535) throw UnsupportedErr.make("Zip cannot handle more than 65535 files");
//   zipOutCount++;
// }

 try
 {
   String zipPath = path.toString();
   if (zipPath.startsWith("/")) zipPath = zipPath.substring(1);
   ZipEntry entry = new ZipEntry(zipPath);
   entry.setTime(modifyTime.toMillis());
   zipOut.putNextEntry(entry);
   java.io.OutputStream zout = new java.io.FilterOutputStream(zipOut)
   {
	@Override
	public void close() throws IOException {
		zipOut.closeEntry();
	}
   };
   return SysOutStreamPeer.fromJava(zout, 0);
 }
 catch (java.io.IOException e)
 {
   throw IOErr.make(e);
 }
}

public boolean finish()
{
 if (zipOut == null) throw UnsupportedErr.make("Zip not opened for writing");
 try
 {
   zipOut.finish();
   return true;
 }
 catch (java.io.IOException e)
 {
   e.printStackTrace();
   return false;
 }
}

public boolean close()
{
 try
 {
   if (zipFile != null) zipFile.close();
   if (zipIn != null)   zipIn.close();
   if (zipOut != null)  zipOut.close();
   return true;
 }
 catch (java.io.IOException e)
 {
   e.printStackTrace();
   return false;
 }
}

//////////////////////////////////////////////////////////////////////////
//GZIP
//////////////////////////////////////////////////////////////////////////

public static OutStream gzipOutStream(OutStream out)
{
 try
 {
   return SysOutStreamPeer.fromJava(new GZIPOutputStream(SysOutStreamPeer.toJava(out)));
 }
 catch (java.io.IOException e)
 {
   throw IOErr.make(e);
 }
}

public static InStream gzipInStream(InStream in)
{
 try
 {
   return SysInStreamPeer.fromJava(new GZIPInputStream(SysInStreamPeer.toJava(in)));
 }
 catch (java.io.IOException e)
 {
   throw IOErr.make(e);
 }
}

//////////////////////////////////////////////////////////////////////////
//Deflate/Inflate
//////////////////////////////////////////////////////////////////////////

public static OutStream deflateOutStream(OutStream out) { return deflateOutStream(out, null); }
public static OutStream deflateOutStream(OutStream out, Map opts)
{
 int level = Deflater.DEFAULT_COMPRESSION;
 boolean nowrap = false;
 if (opts != null)
 {
   if (opts.get("nowrap") != null) nowrap = ((Boolean)opts.get("nowrap")).booleanValue();
   if (opts.get("level") != null) level = ((Long)opts.get("level")).intValue();
 }
 Deflater d = new Deflater(level, nowrap);
 return SysOutStreamPeer.fromJava(new DeflaterOutputStream(SysOutStreamPeer.toJava(out), d));
}

public static InStream deflateInStream(InStream in) { return deflateInStream(in, null); }
public static InStream deflateInStream(InStream in, Map opts)
{
 boolean nowrap = false;
 if (opts != null)
 {
   if (opts.get("nowrap") != null) nowrap = ((Boolean)opts.get("nowrap")).booleanValue();
 }
 Inflater i = new Inflater(nowrap);
 return SysInStreamPeer.fromJava(new InflaterInputStream(SysInStreamPeer.toJava(in), i));
}


//////////////////////////////////////////////////////////////////////////
//Fields
//////////////////////////////////////////////////////////////////////////

LocalFile file;           // open only
ZipFile zipFile;          // open only
Map contents;             // open only
ZipInputStream zipIn;     // read only
ZipOutputStream zipOut;   // write only
int zipOutCount;          // write only

}