//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 06  Brian Frank  Creation
//
package fanx.fcode;

public class ResFile {
	/**
	 * ZipEntryFile represents a file entry inside a zip file.
	 */
	public static class ZipEntryFile extends ResFile
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
	// Fields
	//////////////////////////////////////////////////////////////////////////
	
	  public final java.util.zip.ZipFile parent;
	  public final java.util.zip.ZipEntry entry;
	  public final String uri;
	
	}
	
	public static class ClassLoaderFile extends ResFile
	{

	//////////////////////////////////////////////////////////////////////////
	// Construction
	//////////////////////////////////////////////////////////////////////////

	  public ClassLoaderFile(ClassLoader loader, String loaderPath, String uri)
	  {
	    this.loader     = loader;
	    this.loaderPath = loaderPath;
	    this.uri = uri;
	  }

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	  public final ClassLoader loader;
	  public final String loaderPath;
	  public final String uri;
	}
}