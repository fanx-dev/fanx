//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 06  Brian Frank  Creation
//

**
** File is used to represent a Uri path to a file or directory.
** See [examples]`examples::sys-files`.
**
@NoPeer
abstract const class File
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Make a File for the Uri which represents a file on the local
  ** file system.  If creating a Uri to a directory, then the Uri
  ** must end in a trailing "/" slash or IOErr is thrown - or you
  ** may pass false for checkSlash in which case the trailing slash
  ** is implicitly added.  However if a trailing slash is added, then
  ** the resulting File's uri will not match the uri passed to this method.
  ** If the file doesn't exist, then it is assumed to be to a directory
  ** based on a trailing slash (see `isDir`).  If the Uri has a relative
  ** path, then it is assumed to be relative to the current working
  ** directory.  Throw ArgErr if the Uri has a scheme other than null
  ** or "file:".
  **
  native static new make(Uri uri, Bool checkSlash := true)

  **
  ** Make a File for the specified operating system specific path
  ** on the local file system.
  **
  native static File os(Str osPath)

  **
  ** Get the root directories of the operating system's local file system.
  **
  native static File[] osRoots()

  **
  ** Create a temporary file which is guaranteed to be a new, empty
  ** file with a unique name.  The file name will be generated using
  ** the specified prefix and suffix.  If dir is non-null then it is used
  ** as the file's parent directory, otherwise the system's default
  ** temporary directory is used.  If dir is specified it must be a
  ** directory on the local file system.  See `deleteOnExit` if you wish
  ** to have the file automatically deleted on exit.  Throw IOErr on error.
  **
  ** Examples:
  **   File.createTemp("x", ".txt") => `/tmp/x67392.txt`
  **   File.createTemp.deleteOnExit => `/tmp/fan5284.tmp`
  **
  native static File createTemp(Str prefix := "fan", Str suffix := ".tmp", File? dir := null)

  **
  ** Protected constructor for subclasses.
  **
  protected new privateMake(Uri uri) { this.uri = uri }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** File equality is based on the un-normalized Uri used to create the File.
  **
  override Bool equals(Obj? that) {
    if (that is File) {
      return uri == ((File)that).uri
    }
    return false
  }

  **
  ** Return 'uri.hash'.
  **
  override Int hash() { uri.hash }

  **
  ** Return 'uri.toStr'.
  **
  override Str toStr() { uri.toStr }

//////////////////////////////////////////////////////////////////////////
// Uri
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the Uri path used to create this File.
  ** This Uri may be absolute or relative.
  **
  const Uri uri

  **
  ** Convenience for [uri.isDir]`Uri.isDir`
  **
  virtual Bool isDir() { uri.isDir }

  **
  ** Convenience for [uri.path]`Uri.path`.
  **
  Str[] path() { uri.path }

  **
  ** Convenience for [uri.pathStr]`Uri.pathStr`.
  **
  Str pathStr() { uri.pathStr }

  **
  ** Convenience for [uri.name]`Uri.name`.
  **
  Str name() { uri.name }

  **
  ** Convenience for [uri.basename]`Uri.basename`.
  **
  Str basename() { uri.basename }

  **
  ** Convenience for [uri.ext]`Uri.ext`.
  **
  Str? ext() { uri.ext }

  **
  ** Convenience for [uri.mimeType]`Uri.mimeType`.
  **
  MimeType? mimeType() { uri.mimeType }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this file exists.
  **
  abstract Bool exists()

  **
  ** Return the size of the file in bytes otherwise 0 if a
  ** directory or unknown.
  **
  abstract Int size()

  **
  ** If this is a file return if the file size is zero or null.
  ** If this is a directory return if this directory has no
  ** files without reading a full listing.
  **
  virtual Bool isEmpty() {
    if (isDir) return list.isEmpty
    size := this.size()
    return size <= 0
  }

  **
  ** Get time the file was last modified or null if unknown.
  **
  abstract TimePoint? modified

  **
  ** Get this File as an operating system specific path on
  ** the local system.  If this File doesn't represent a
  ** path on the local file system then return null.
  **
  abstract Str? osPath()

  **
  ** Get the parent directory of this file or null.
  ** Also see `Uri.parent`.
  **
  virtual File? parent() {
    p := uri.parent
    if (p == null) return null
    return make(p)
  }

  **
  ** List the files contained by this directory.  This list includes
  ** both child sub-directories and normal files.  If the directory
  ** is empty or this file doesn't represent a directory, then return
  ** an empty list.
  **
  abstract File[] list()

  **
  ** List the child sub-directories contained by this directory.  If
  ** the directory doesn't contain any sub-direcotries or this file
  ** doesn't represent a directory, then return an empty list.
  **
  virtual File[] listDirs() {
    list.findAll |f|{ f.isDir }
  }

  **
  ** List the child files (excludes directories) contained by this
  ** directory.  If the directory doesn't contain any child files
  ** or this file doesn't represent a directory, then return an
  ** empty list.
  **
  virtual File[] listFiles() {
    list.findAll |File f->Bool|{ !f.isDir }
  }

  **
  ** Recursively walk this file/directory top down.  If this
  ** file is not a directory then the callback is invoked exactly
  ** once with this file.  If a directory, then the callback
  ** is invoked with this file, then recursively for each child
  ** file.
  **
  virtual Void walk(|File f| c) {
    c.call(this)
    if (isDir())
    {
      list.each |File f|{ f.walk(c) }
    }
  }

  **
  ** Normalize this file path to its canonical representation.
  ** If a file on the local file system, then the uri will
  ** include the "file:" scheme.  Throw IOErr on error.
  **
  abstract File normalize()

  **
  ** Make a new File instance by joining this file's Uri
  ** together with the specified path.  If the file maps
  ** to a directory and the resulting Uri doesn't end in
  ** slash then an IOErr is thrown - or pass false for
  ** checkSlash to have the slash implicitly added.
  **
  ** Examples:
  **   File(`a/b/`) + `c` => File(`a/b/c`)
  **   File(`a/b`) + `c`  => File(`a/c`)
  **
  @Operator virtual File plus(Uri path, Bool checkSlash := true) {
    u := uri + path
    return File.make(u, checkSlash)
  }

  **
  ** Get the store instance which models the storage pool, device,
  ** partition, or volume used to store this file.  Raise UnsupportedErr
  ** if this file is not associated with a store.
  **
  virtual FileStore? store() { null }

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  **
  ** Create a file or directory represented by this Uri.  If isDir() is
  ** false then create an empty file, or if the file already exists
  ** overwrite it to empty.  If isDir() is true then create a directory,
  ** or if the directory already exists do nothing.  This method will
  ** automatically create any parent directories.  Throw IOErr on error.
  ** Return this.
  **
  abstract File create()

  **
  ** Create a file under this directory.  Convenience for `create`:
  **   return (this+name.toUri).create
  ** Throw IOErr is this file is not a directory or if there is a
  ** error creating the new file.  Return the file created.
  **
  File createFile(Str name) { (this+Uri(name)).create }

  **
  ** Create a sub-directory under this directory.  Convenience
  ** for `create`:
  **   return (this+name/.toUri).create
  ** Throw IOErr is this file is not a directory or if there is a
  ** error creating the new directory.  Return the directory created.
  **
  File createDir(Str name) { (this+`$name/`).create }

  **
  ** Copy this file or directory to the new specified location.
  ** If this file represents a directory, then it recursively
  ** copies the entire directory tree.
  **
  ** The options map is used to customize how the copy is performed.
  ** The following summarizes the options:
  **   - exclude:   Regex or |File f->Bool|
  **   - overwrite: Bool or |File f->Bool|
  **
  ** If the "exclude" option is a Regex - each source file's Uri string
  ** is is checked for a match to skip.  If a directory is skipped, then
  ** its children are skipped also.  The exclude option can also be a
  ** function of type '|File f->Bool|' to check each file.  Exclude
  ** processing is performed first before checking for an overwrite.
  **
  ** If during the copy, an existing file of the same name is found,
  ** then the "overwrite" option should be to 'true' to overwrite or
  ** 'false' to skip.  The overwrite option can also be a function
  ** of type '|File f->Bool|' which is passed every destination file
  ** to be overwritten.  If the overwrite function throws an exception,
  ** it is raised to the 'copyTo' caller.  If a directory overwrite is
  ** skipped, then it its children are skipped too.  If options are null
  ** or overwrite is unspecified then the copy is immediately terminated
  ** with an IOErr.
  **
  ** Any IOErr or other error encountered during the file copy immediately
  ** terminates the copy and is raised to the caller, which might leave
  ** the copy in an unfinished state.
  **
  ** Return the 'to' destination file.
  **
  native File copyTo(File to, [Str:Obj]? options := null)


  **
  ** Copy this file under the specified directory and return
  ** the destination file.  This method is a convenience for:
  **   return this.copyTo(dir + this.name, options)
  **
  virtual File copyInto(File dir, [Str:Obj]? options := null) {
    if (!dir.isDir) throw ArgErr("Not a dir: `" + dir + "`")
    name := this.name
    if (isDir) name += "/"
    return copyTo(dir + `$name`, options)
  }

  **
  ** Move this file to the specified location.  If this file is
  ** a directory, then the entire directory is moved.  If the
  ** target file already exists or the move fails, then an IOErr
  ** is thrown.  Return the 'to' destination file.
  **
  abstract File moveTo(File to)

  **
  ** Move this file under the specified directory and return
  ** the destination file.  This method is a convenience for:
  **   return this.moveTo(dir + this.name)
  **
  virtual File moveInto(File dir) {
    if (!dir.isDir) throw ArgErr("Not a dir: `" + dir + "`")
    name := this.name
    if (isDir) name += "/"
    return this.moveTo(dir + `$name`)
  }

  **
  ** Renaming this file within its current directory.
  ** It is a convenience for:
  **   return this.moveTo(parent + newName)
  **
  virtual File rename(Str newName) {
    if (isDir) newName += "/"
    return this.moveTo(parent + `$newName`)
  }

  **
  ** Delete this file.  If this file represents a directory, then
  ** recursively delete it.  If the file does not exist, then no
  ** action is taken.  Throw IOErr on error.
  **
  abstract Void delete()

  **
  ** Request that the file or directory represented by this File
  ** be deleted when the virtual machine exits.  Long running applications
  ** should use this method will care since each file marked to delete will
  ** consume resources.  Throw IOErr on error.  Return this.
  **
  abstract File deleteOnExit()

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  **
  ** Open this file for random access.  Modes are:
  **   - "r": open the file for reading only.  Throws IOErr
  **     if file does not exist.
  **   - "rw": open the file for reading and writing; create
  **     if the file does not exist.
  **
  ** The Buf instance returned is backed by a random access file
  ** pointer. It provides the same functionality as a memory backed
  ** buffer, except for a couple exceptions such as `Buf.unread`.
  ** The resulting Buf is a raw interface to the random access
  ** file, no buffering is provided at the framework level - so
  ** use methods which only access a few bytes carefully.  However
  ** methods which transfer data with other Bufs and IO streams
  ** will use an internal buffer for efficiency.
  **
  abstract Buf open(Str mode := "rw")

  **
  ** Memory map the region of the file specified by 'pos' and 'size'.
  ** If size is null, then use the file's size as a default.  The
  ** file is paged into virtual memory on demand.  Modes are:
  **   - "r": map the file for reading only.  Throws IOErr
  **     if file does not exist.
  **   - "rw": open the file for reading and writing; create
  **     if the file does not exist.
  **   - "p": private read/write mode will not propagate changes
  **     to other processes which have mapped the file.
  **
  abstract Buf mmap(Str mode := "rw", Int pos := 0, Int size := 0)

  **
  ** Open a new buffered InStream used to read from this file.  A
  ** bufferSize of null or zero will return an unbuffered input stream.
  ** Throw IOErr on error.
  **
  abstract InStream in(Int bufferSize := 4096)

  **
  ** Open a new buffered OutStream used to write to this file.  If append is
  ** true, then we open the file to append to the end, otherwise it is
  ** opened as an empty file.  A bufferSize of null or zero will return an
  ** unbuffered output stream.  Throw IOErr on error.
  **
  abstract OutStream out(Bool append := false, Int bufferSize := 4096)

  **
  ** Convenience for [in.readAllBuf]`File.readAllBuf`.
  ** The input stream is guaranteed to be closed.
  **
  Buf readAllBuf() { in.readAllBuf }

  **
  ** Convenience for [in.readAllLines]`File.readAllLines`.
  ** The input stream is guaranteed to be closed.
  **
  Str[] readAllLines() { in.readAllLines }

  **
  ** Convenience for [in.eachLine]`File.eachLine`.
  ** The input stream is guaranteed to be closed.
  **
  Void eachLine(|Str line| f) { in.eachLine(f) }

  **
  ** Convenience for [in.readAllStr]`File.readAllStr`.
  ** The input stream is guaranteed to be closed.
  **
  Str readAllStr(Bool normalizeNewlines := true) { in.readAllStr(normalizeNewlines) }

  **
  ** Convenience for [in.readProps()]`File.readProps`.
  ** The input stream is guaranteed to be closed.
  **
  //Str:Str readProps()

  **
  ** Convenience for [out.writeProps()]`File.writeProps`.
  ** The output stream is guaranteed to be closed.
  **
  //Void writeProps(Str:Str props)

  **
  ** Convenience for [in.readObj]`InStream.readObj`
  ** The input stream is guaranteed to be closed.
  **
  //Obj? readObj([Str:Obj]? options := null)

  **
  ** Convenience for [out.writeObj]`OutStream.writeObj`
  ** The output stream is guaranteed to be closed.
  **
  //Void writeObj(Obj? obj, [Str:Obj]? options := null)

  **
  ** Return the platform's separator for names within
  ** in a path: backslash on Windows, forward slash on Unix.
  **
  native static Str sep()

  **
  ** Return the platform's separator for a list of
  ** paths: semicolon on Windows, colon on Unix.
  **
  native static Str pathSep()

}

**************************************************************************
** LocalFile
**************************************************************************
@NoPeer
internal const class LocalFile : File
{
  protected const Obj? peer
  native private Void init()
  new make(Uri uri) : super.privateMake(uri) { init }

  native override FileStore? store()

  native override Bool exists()
  native override Int size()
  native override TimePoint? modified
  native override Str? osPath()
  native override File[] list()
  native override File normalize()
  native override File create()
  native override File moveTo(File to)
  native override Void delete()
  native override File deleteOnExit()

  override Buf open(Str mode := "rw") {
    FileBuf(this, mode)
  }
  override Buf mmap(Str mode := "rw", Int pos := 0, Int size := this.size) {
    NioBuf(this, mode, pos, size)
  }

  native override InStream in(Int bufferSize := 4096)
  native override OutStream out(Bool append := false, Int bufferSize := 4096)
}

**************************************************************************
** ZipEntryFile
**************************************************************************

internal const class ZipEntryFile : File
{
  native private Void init()
  new make(Uri uri) : super.privateMake(uri) { init }

  native override Bool exists()
  native override Int size()
  native override TimePoint? modified
  native override Str? osPath()
  native override File[] list()
  native override File normalize()
  native override File create()
  native override File moveTo(File to)
  native override Void delete()
  native override File deleteOnExit()
  native override Buf open(Str mode := "rw")
  native override Buf mmap(Str mode := "rw", Int pos := 0, Int size := this.size)
  native override InStream in(Int bufferSize := 4096)
  native override OutStream out(Bool append := false, Int bufferSize := 4096)
}


