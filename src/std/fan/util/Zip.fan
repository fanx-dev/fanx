//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Aug 06  Brian Frank  Creation
//

**
** Zip is used to read/write compressed zip files and streams.  Zip may be
** used in three modes:
**
**   1. `Zip.open` is used to read a random access file and provides
**      access to the entire contents with the ability to read select
**      entries
**   2. `Zip.read` is used to read a zip file from an input stream.
**      Each entry is pulled off the stream using `readNext`
**   3. `Zip.write` is used to write a zip file to an output stream.
**      Each entry must is written to the stream using `writeNext`
**
@NoJs
native final class Zip
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Open the specified file as a zip file for reading.  If the specified
  ** file does not exist, is not a valid file, or does not support random
  ** access then throw IOErr.
  **
  ** Example:
  **   zip := Zip.open(File(`test.zip`))
  **   txt := zip.contents[`/notice.txt`].readAllStr
  **   zip.close
  **
  static Zip open(File file)

  **
  ** Create a Zip used to read a zip file from the specified input stream.
  **
  ** Example:
  **   zip := Zip.read(File(`test.zip`).in)
  **   File entry
  **   while ((entry = zip.readNext()) != null)
  **   {
  **     data := entry.readAllBuf
  **     echo("$entry size=$data.size")
  **   }
  **   zip.close
  **
  static Zip read(InStream out)

  **
  ** Create a Zip used to write a zip file to the specified output stream.
  **
  ** Example:
  **   zip := Zip.write(File(`test.zip`).out)
  **   out := zip.writeNext(`/path/hello.txt`)
  **   out.writeLine("hello zip")
  **   out.close
  **   zip.close
  **
  static Zip write(OutStream out)

  **
  ** Private constructor
  **
  private new init(Uri uri)

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the underlying file or null if using streams.
  **
  File? file()

  **
  ** Return the contents of this zip as a map of Files.  The Uri
  ** keys will start with a slash and be relative to this zip file.
  ** Return null if using streams.
  **
  [Uri:File]? contents()

  **
  ** Read the next entry in the zip.  Use the File's input stream to read the
  ** file contents.  Some file meta-data such as size may not be available.
  ** Return null if at end of zip file.  Throw UnsupportedErr if not reading
  ** from an input stream.
  **
  File? readNext()

  **
  ** Append a new file to the end of this zip file and return an OutStream
  ** which may be used to write the file contents.  The Uri must not contain
  ** a query or fragment; it may optionally start with a slash.  Closing the
  ** OutStream will close only this file entry - use Zip.close() when finished
  ** writing the entire zip file.  Throw UnsupportedErr if zip is not writing
  ** to an output stream.
  **
  ** Examples:
  **   out := zip.writeNext(`/docs/test.txt`)
  **   out.writeLine("test")
  **   out.close
  **
  OutStream writeNext(Uri path, TimePoint modifyTime := TimePoint.now)

  **
  ** Finish writing the contents of this zip file, but leave the underlying
  ** OutStream open.  This method is guaranteed to never throw an IOErr.
  ** Return true if the stream was finished successfully or false if the
  ** an error occurred.  Throw UnsupportedErr if zip is not not writing to
  ** an output stream.
  **
  Bool finish()

  **
  ** Close this zip file for reading and writing.  If this zip file is
  ** reading or writing an stream, then the underlying stream is also
  ** closed.  This method is guaranteed to never throw an IOErr.  Return
  ** true if the close was successful or false if the an error occurred.
  **
  Bool close()

  **
  ** If file is not null then return file.toStr, otherwise return
  ** a suitable string representation.
  **
  override Str toStr()

//////////////////////////////////////////////////////////////////////////
// GZIP
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct a new GZIP output stream which wraps the given output stream.
  **
  static OutStream gzipOutStream(OutStream out)

  **
  ** Construct a new GZIP input stream which wraps the given input stream.
  **
  static InStream gzipInStream(InStream in)

//////////////////////////////////////////////////////////////////////////
// Deflate
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct a new deflate output stream which wraps the given output stream,
  ** and compresses data using the "deflate" compression format.  Options:
  **   - level: Int between 9 (best compression) to 0 (no compression)
  **   - nowrap: Bool false to suppress defalate header and adler checksum
  **
  static OutStream deflateOutStream(OutStream out, [Str:Obj?]? opts := null)

  **
  ** Construct a new deflate input stream which wraps the given input stream and
  ** inflates data written using the "deflate" compression format.  Options:
  **   - nowrap: Bool false to suppress defalate header and adler checksum
  **
  static InStream deflateInStream(InStream in, [Str:Obj?]? opts := null)

}