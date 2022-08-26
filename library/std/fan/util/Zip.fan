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
  private Int handle

  private File? _file
  private InStream? _in
  private OutStream? _out

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
  static Zip read(InStream in)

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
  private new make() {}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the underlying file or null if using streams.
  **
  File? file() { _file }

  **
  ** Return the contents of this zip as a map of Files.  The Uri
  ** keys will start with a slash and be relative to this zip file.
  ** Return null if using streams.
  **
  native [Uri:File]? contents(Str? exclude := null)

  **
  ** Read the next entry in the zip.  Use the File's input stream to read the
  ** file contents.  Some file meta-data such as size may not be available.
  ** Return null if at end of zip file.  Throw UnsupportedErr if not reading
  ** from an input stream.
  **
  native File? readNext()

  native Array<Int8>? readEntry(Uri path)

  **
  ** Call the specified function for every entry in the zip. Use the File's
  ** input stream to read the file contents.  Some file meta-data such as size
  ** may not be available. Throw UnsupportedErr if not reading from an input
  ** stream.
  **
  Void readEach(|File| c) {
    File? file
    while ((file = readNext) != null) {
      f.call(file)
    }
  }

  **
  ** Append a new file to the end of this zip file and return an OutStream
  ** which may be used to write the file contents.  The Uri must not contain
  ** a query or fragment; it may optionally start with a slash.  Closing the
  ** OutStream will close only this file entry - use Zip.close() when finished
  ** writing the entire zip file.  Throw UnsupportedErr if zip is not writing
  ** to an output stream.
  **
  ** Next entry options:
  **   - comment: Str entry comment
  **   - crc: Int CRC-32 of the uncompressed data
  **   - extra: Buf for extra bytes data field
  **   - level: Int between 9 (best compression) to 0 (no compression)
  **   - compressedSize: Int for compressed size of data
  **   - uncompressedSize: Int for uncompressed size of data
  **
  ** NOTE: setting level to 0 sets method to STORE, else to DEFLATED.
  **
  ** Examples:
  **   out := zip.writeNext(`/docs/test.txt`)
  **   out.writeLine("test")
  **   out.close
  **
  OutStream writeNext(Uri path, TimePoint modifyTime := TimePoint.now,  [Str:Obj?]? opts := null) {
    return ZipEntryOutStream(this, path, modifyTime, opts)
  }

  native Void writeEntry(Buf buf, Uri path, TimePoint modifyTime := TimePoint.now,  [Str:Obj?]? opts := null)

  **
  ** Finish writing the contents of this zip file, but leave the underlying
  ** OutStream open.  This method is guaranteed to never throw an IOErr.
  ** Return true if the stream was finished successfully or false if the
  ** an error occurred.  Throw UnsupportedErr if zip is not not writing to
  ** an output stream.
  **
  native Bool finish()

  **
  ** Close this zip file for reading and writing.  If this zip file is
  ** reading or writing an stream, then the underlying stream is also
  ** closed.  This method is guaranteed to never throw an IOErr.  Return
  ** true if the close was successful or false if the an error occurred.
  **
  Bool close() {
    ok := finish()
    if (_out != null) {
      if (!_out.close) ok = false
    }
    if (_in != null) {
      if (!_in.close) ok = false
    }
    return ok
  }

  **
  ** If file is not null then return file.toStr, otherwise return
  ** a suitable string representation.
  **
  override Str toStr() {
    if (file != null) return file.toStr
    return super.toStr
  }

  //protected native override Void finalize()

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

**************************************************************************
** ZipEntry File and Stream
**************************************************************************

native internal const class ZipEntryFile : File
{
  private const Unsafe<Zip> _parent
  private const Int _time
  private const Int _size

  new make(Str uri, Int time, Int size, Zip parent) : super.privateMake(("/"+uri).toUri) {
    _time = time
    _size = size
    _parent = Unsafe<Zip>(parent)
  }

  override Bool exists() { true }
  override Int size() { _size }
  override TimePoint? modified {
    get { TimePoint.fromMillis(_time) }
    set { throw IOErr.make("ZipEntryFile is readonly") }
  }
  override Str? osPath() { null }
  override File[] list() { List.defVal }
  override File normalize() { this }
  override File create() { throw IOErr.make("ZipEntryFile is readonly") }
  override File moveTo(File to) { throw IOErr.make("ZipEntryFile is readonly") }
  override Void delete() { throw IOErr.make("ZipEntryFile is readonly") }
  override File deleteOnExit() { throw IOErr.make("ZipEntryFile is readonly") }
  override Buf open(Str mode := "rw") { throw UnsupportedErr.make("ZipEntryFile.open"); }
  override Buf mmap(Str mode := "rw", Int pos := 0, Int size := this.size) { throw UnsupportedErr.make("ZipEntryFile.mmap"); }
  
  override OutStream out(Bool append := false, Int bufferSize := 4096) {
    throw IOErr.make("ZipEntryFile is readonly");
  }

  //lazy load
  override InStream in(Int bufferSize := 4096) {
    data := _parent.val.readEntry(uri)
    buf := MemBuf.makeBuf(data)
    return buf.in
  }
}

internal class ZipEntryOutStream : BufOutStream {
  private Zip parent
  private Uri path
  private TimePoint modifyTime
  private [Str:Obj?]? opts

  new make(Zip parent, Uri path, TimePoint modifyTime, [Str:Obj?]? opts) : super(MemBuf.make(1024)) {
    this.parent = parent
    this.path = path
    this.modifyTime = modifyTime
    this.opts = opts
  }

  override Bool close() {
    parent.writeEntry(buf, path, modifyTime, opts)
    return true
  }
}