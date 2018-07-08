//
//Copyright (c) 2006, Brian Frank and Andy Frank
//Licensed under the Academic Free License version 3.0
//
//History:
//26 Mar 06  Brian Frank  Creation
//
package fan.reflect;

import fan.std.Buf;
import fan.std.File;
import fan.std.InStream;
import fan.std.OutStream;
import fan.std.SysInStreamPeer;
import fan.std.TimePoint;
import fan.std.Uri;
import fan.sys.IOErr;
import fan.sys.List;
import fan.sys.UnsupportedErr;

/**
 * ZipEntryFile represents a file entry inside a zip file.
 */
public class ZipEntryFile extends File {

	//////////////////////////////////////////////////////////////////////////
	// Construction
	//////////////////////////////////////////////////////////////////////////

	public ZipEntryFile(java.util.zip.ZipFile parent, java.util.zip.ZipEntry entry, Uri uri) {
		this.parent = parent;
		this.entry = entry;
		File.privateMake$(this, uri);
	}

	public ZipEntryFile(java.util.zip.ZipFile parent, java.util.zip.ZipEntry entry) {
		this(parent, entry, entryUri(entry));
	}

	static Uri entryUri(java.util.zip.ZipEntry entry) {
		return Uri.fromStr("/" + (entry.getName()));
	}

	//////////////////////////////////////////////////////////////////////////
	// File
	//////////////////////////////////////////////////////////////////////////

	public boolean exists() {
		return true;
	}

	public long size() {
		if (isDir())
			return 0;
		long size = entry.getSize();
		return size;
	}

	public TimePoint modified() {
		return TimePoint.fromMillis(entry.getTime());
	}

	public void modified(TimePoint time) {
		throw IOErr.make("ZipEntryFile is readonly");
	}

	public String osPath() {
		return null;
	}

	public File parent() {
		return null;
	}

	public File normalize() {
		return this;
	}

	public File plus(Uri uri, boolean checkSlash) {
		throw UnsupportedErr.make("ZipEntryFile.plus");
	}

	//////////////////////////////////////////////////////////////////////////
	// File Management
	//////////////////////////////////////////////////////////////////////////

	public File create() {
		throw IOErr.make("ZipEntryFile is readonly");
	}

	public File moveTo(File to) {
		throw IOErr.make("ZipEntryFile is readonly");
	}

	public void delete() {
		throw IOErr.make("ZipEntryFile is readonly");
	}

	public File deleteOnExit() {
		throw IOErr.make("ZipEntryFile is readonly");
	}

	//////////////////////////////////////////////////////////////////////////
	// IO
	//////////////////////////////////////////////////////////////////////////

	public Buf open(String mode) {
		throw UnsupportedErr.make("ZipEntryFile.open");
	}

	@Override
	public Buf mmap(String mode, long pos, long size) {
		throw UnsupportedErr.make("ZipEntryFile.mmap");
	}

	public InStream in(long bufSize) {
		try {
			java.io.InputStream in;
			in = ((java.util.zip.ZipFile) parent).getInputStream(entry);
			// return as fan stream
			return SysInStreamPeer.make(in, bufSize);
		} catch (java.io.IOException e) {
			throw IOErr.make(e);
		}
	}

	public OutStream out(boolean append, long bufSize) {
		throw IOErr.make("ZipEntryFile is readonly");
	}

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	final Object parent;
	final java.util.zip.ZipEntry entry;

	@Override
	public List list() {
		return List.defVal;
	}

}