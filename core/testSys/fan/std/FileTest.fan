//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 06  Brian Frank  Creation
//

**
** FileTest
**
class FileTest : Test
{
  File? tempDir

  override Void setup() {
    tempDir = `test_temp/`.toFile
    tempDir.delete
    tempDir.create
  }

  override Void teardown() {
    tempDir?.delete
  }

  Void testOsRoots()
  {
    verify(File.osRoots.size > 0)
    verify(File.osRoots.all |File f->Bool| { return f.isDir })
  }

  Void testTestDir()
  {
    // verify clean empty directory
    verify(tempDir.exists)
    verify(tempDir->exists)
    verify(tempDir.isDir)
    verify(tempDir.isEmpty)
    verify(tempDir.list.isEmpty)
    verify(tempDir->list->isEmpty)
    verify(tempDir.list.size == 0)
    verify(tempDir.listDirs.size == 0)
    verify(tempDir.listFiles.size == 0)
    //verifyEq(tempDir.parent.uri, tempDir.uri.parent)
    verifyEq((tempDir+`notfoundfoobar/`).isEmpty, true)
  }

  Void testWalk()
  {
    acc := File[,]
    single := Env.cur.homeDir + `etc/sys/config.props`
    single.walk { acc.add(it) }
    verifyEq(single, single)

    acc.clear
    lib := Env.cur.homeDir + `lib/`
    lib.walk { acc.add(it) }
    verify(acc.contains(lib))
    verify(acc.contains(lib + `fan/`))
    verify(acc.contains(lib + `fan/sys.pod`))
  }

  Void testNormalize()
  {
    // this test really doesn't do anything other
    // than verify the method is there and does something
    f := File.make(`./`)
    verify(f.path.size < f.normalize.path.size)
    verifyEq(f.uri, f.uri.toFile.uri)
    verifyEq(f.normalize.uri.scheme, "file")

    f = File(`file:/ok/path`)
    verifyEq(f.uri.scheme, "file")
    verifyEq(f.uri.pathStr, "/ok/path")

    verifyErr(ArgErr#) { x := File(`c:/bad/windows/path`) }
  }

  Void testPlus()
  {
    f := File.make(`a/b/c/`);
    verifyEq(f + `d`,   File.make(`a/b/c/d`))
    verifyEq(f + `d/e`,  File.make(`a/b/c/d/e`))
    //verifyEq(f + `../d`, File.make(`a/b/d`))
    //verifyEq(f->plus(`../d`), File.make(`a/b/d`))

    f = File.make(`a/b/c`);
    verifyEq(f + `d`,   File.make(`a/b/d`))
    verifyEq(f + `d/e`,  File.make(`a/b/d/e`))
    //verifyEq(f + `../d`, File.make(`a/d`))
  }

  Void testCheckSlash()
  {
    dir := tempDir + `dir/`
    dir.create
    verify(dir.exists)

    slash := dir.uri
    noSlash := slash.toStr[0..-2].toUri

    verifyErr(IOErr#) { x := File.make(noSlash) }
    verifyErr(IOErr#) { x := this.tempDir + `dir`; echo("$x $x.exists") }

    x := File.make(noSlash, false)
    verifyEq(x.uri, slash)
    verifyEq(x.exists, true)

    x = tempDir->plus(`dir`, false)
    verifyEq(x.uri, slash)
    verifyEq(x.exists, true)
  }

  Void testCreateTemp()
  {
    file := File.createTemp.deleteOnExit
    verifyEq(file.size, 0)
    verify(file.exists)
    verify(file.name.startsWith("fan"))
    verify(file.name.endsWith(".tmp"))

    file = File.createTemp("f").deleteOnExit
    verifyEq(file.size, 0)
    verify(file.exists)
    verify(file.name.startsWith("f"))
    verify(file.name.endsWith(".tmp"))

    file = File.createTemp("fantest", ".fantest").deleteOnExit
    verifyEq(file.size, 0)
    verify(file.exists)
    verify(file.name.startsWith("fantest"))
    verify(file.name.endsWith(".fantest"))

    file = File.createTemp("fantest", ".fantest", Env.cur.tempDir).deleteOnExit
    verifyEq(file.size, 0)
    verify(file.exists)
    verify(file.name.startsWith("fantest"))
    verify(file.name.endsWith(".fantest"))
    verify(file.toStr.startsWith(Env.cur.tempDir.uri.relToAuth.toStr))

    verifyErr(IOErr#) { File.createTemp("xyz", ".tmp", file) }
    //verifyErr(IOErr#) { File.createTemp("xyz", ".tmp", FileTest#.pod.file(`/res/test.txt`)) }
  }

  Void testCreateAndDelete()
  {
    // create file - no extension
    f := tempDir.createFile("file")
    verify(!f.isDir)
    verify(f.isEmpty)
    verify(f.list.isEmpty)
    verify(f.listFiles.isEmpty)
    verify(f.listDirs.isEmpty)
    verifyEq(f.size, 0)
    verifyEq(f.name, "file")
    verifyEq(f.basename, "file")
    verifyEq(f.ext, null)
    verifyEq(f.uri.path.last, "file")
    verifyEq(f.path.last, "file")
    verifyEq(f.uri.relToAuth.toStr, f.pathStr)
    verifyEq(tempDir.list, [f])
    verifyEq(tempDir.listDirs, File[,])
    verifyEq(tempDir.listFiles, [f])

    // create file - with extension
    e := (tempDir + `file.txt`).create
    verify(!e.isDir)
    verify(e.list.isEmpty)
    verify(e.isEmpty)
    verifyEq(e.size, 0)
    verifyEq(e.name, "file.txt")
    verifyEq(e.basename, "file")
    verifyEq(e.ext, "txt")
    verifyEq(e.mimeType, MimeType.fromStr("text/plain; charset=utf-8"))
    verifyEq(e.uri.path.last, "file.txt")
    verifyEq(e.path.last, "file.txt")
    verifyEq(e.uri.relToAuth.toStr, e.pathStr)
    verifyEq(tempDir.isEmpty, false)
    verifyEq(tempDir.list.sort, [f, e])
    verifyEq(tempDir.listDirs, File[,])
    verifyEq(tempDir.listFiles.sort, [f, e])

    // create dir
    d := tempDir.createDir("dir")
    verify(d.isDir)
    verify(d.isEmpty)
    verify(d.list.isEmpty)
    verifyEq(d.name, "dir")
    verifyEq(d.basename, "dir")
    verifyEq(d.ext, null)
    verifyEq(d.uri.path.last, "dir")
    verifyEq(d.path.last, "dir")
    verifyEq(d.pathStr.endsWith("/dir/"), true)
    verifyEq(d.uri.relToAuth.toStr, d.pathStr)
    verifyEq(d.size, 0)
    verifyEq(tempDir.list.sort, [d, f, e])
    verifyEq(tempDir.listDirs, [d])
    verifyEq(tempDir.listFiles.sort, [f, e])

    // create another representation of "file"
    fx := tempDir + `file`
    verify(f == fx)
    verify(!(f != fx))
    verify(!(f === fx))
    verifyEq(f, fx)
    verifyEq(f.hash, fx.hash)

    // check create for existing
    verify(d.exists); d.create
    verify(f.exists); f.create

    // check errors
    verifyErr(IOErr#) { x := File.make((f.pathStr+"/").toUri) }
    verifyErr(IOErr#) { x := File.make(d.toStr[0..-2].toUri) }

    // delete
    d.delete; verifyFalse(d.exists)
    f.delete; verifyFalse(f.exists)

    // re-create and call deleteOnExit (can't really test this easily,
    // but you can manually look in test directory after running this
    // test to verify files deleted on exit)
    d.create.deleteOnExit; verify(d.exists)
    f.create.deleteOnExit; verify(f.exists)

    // test recursive create/delete
    x := (tempDir + `alpha/beta/gamma/file.txt`).create
    verify(x.exists)
    y := tempDir + `alpha/`
    y.delete
    verify(!y.exists)
  }

  Void testCopyTo()
  {
    dirA := (tempDir + `dirA/`).create
    a1 := (dirA+ `a1`)
    a1.out.print("hello world!").close

    // errors
    verifyErr(ArgErr#) { dirA.copyTo(this.tempDir + `bad`) }
    verifyErr(ArgErr#) { a1.copyTo(this.tempDir + `bad/`) }
    verifyErr(ArgErr#) { dirA.copyInto(this.tempDir + `bad`) }

    // copyTo file
    a2 := dirA + `a2`
    verifyEq(a2.exists, false)
    verifySame(a2, a1.copyTo(a2))
    verifyEq(a2.readAllStr, "hello world!")

    // copyInto file
    x := a1.copyInto(tempDir)
    verifyEq(x.uri, tempDir.uri + `a1`)
    verifyEq(x.readAllStr, "hello world!")

    // copyTo dir
    dirB := tempDir + `dirB/`
    verifySame(dirB, dirA.copyTo(dirB))
    verifyEq((dirB + `a1`).readAllStr, "hello world!")
    verifyEq((dirB + `a2`).readAllStr, "hello world!")

    // copyInto dir
    dirA.copyInto(dirB)
    verifyEq((dirB + `dirA/a1`).readAllStr, "hello world!")
    verifyEq((dirB + `dirA/a2`).readAllStr, "hello world!")

    // copy with exclude=Regex
    /*TODO
    dirC := dirB.copyTo(tempDir+`dirC/`, ["exclude":Regex.fromStr("(.?)+a2")])
    verifyEq((dirC + `a1`).readAllStr, "hello world!")
    verifyEq((dirC + `dirA/a1`).readAllStr, "hello world!")
    verifyEq((dirC + `a2`).exists, false)
    verifyEq((dirC + `dirA/a2`).exists, false)
    */
    // copy with exclude=Func
    dirD := dirB.copyTo(tempDir+`dirD/`, ["exclude":|File f->Bool| { return f.name == "dirA" }])
    verifyEq((dirD + `a1`).readAllStr, "hello world!")
    verifyEq((dirD + `a2`).readAllStr, "hello world!")
    verifyEq((dirD + `dirA/`).exists, false)

    // change dirX files
    dirX := (tempDir+`dirX/`).create;
    (dirX + `a1`).out.print("foo").close;
    (dirX + `a2`).out.print("bar").close;
    (dirX + `dirA/a1`).create.out.print("roo").close;

    // copy overwrite=true
    verifyErr(IOErr#) { dirB.copyTo(dirX) }
    dirB.copyTo(dirX, ["overwrite":false])
    verifyEq((dirX + `a1`).readAllStr, "foo")
    verifyEq((dirX + `a2`).readAllStr, "bar")
    verifyEq((dirX + `dirA/a1`).readAllStr, "roo")
    verifyEq((dirX + `dirA/a2`).exists, false)

    // copy overwrite=Func
    File? copyToFile
    File? copyFromFile
    dirB.copyTo(dirX, ["overwrite":|File to,File from->Bool| {
        if (copyToFile == null) { copyToFile = to; copyFromFile = from }
        return to.isDir || to.name=="a1"
      }])
    verifyEq(copyToFile, dirX)
    verifyEq(copyFromFile, dirB)
    verifyEq((dirX + `a1`).readAllStr, "hello world!")
    verifyEq((dirX + `a2`).readAllStr, "bar")
    verifyEq((dirX + `dirA/a1`).readAllStr, "hello world!")
    verifyEq((dirX + `dirA/a2`).readAllStr, "hello world!")

    // copy overwrite=false
    dirB.copyTo(dirX, ["overwrite":true])
    verifyEq((dirX + `a1`).readAllStr, "hello world!")
    verifyEq((dirX + `a2`).readAllStr, "hello world!")
    verifyEq((dirX + `dirA/a1`).readAllStr, "hello world!")
    verifyEq((dirX + `dirA/a2`).readAllStr, "hello world!")
  }

  Void testMoveTo()
  {
    dirA := (tempDir + `dirA/`).create
    dirB := (tempDir + `dirB/`).create
    a1 := (tempDir + `a1`)
    a1.out.print("hi").close

    // errors
    verifyErr(ArgErr#) { dirA.moveTo(this.tempDir + `bad`) }
    verifyErr(ArgErr#) { a1.moveTo(this.tempDir + `bad/`) }
    verifyErr(ArgErr#) { dirA.moveInto(this.tempDir + `bad`) }

    // moveTo file
    a1 = a1.moveTo(dirA+`a1`)
    verifyEq(dirA.isEmpty, false)
    verifyEq(dirA.list.size, 1)
    verifyEq(a1.parent, dirA)
    verifyEq(a1->parent, dirA)
    verifyEq(a1.readAllStr, "hi")
    verifyEq(a1->readAllStr, "hi")

    // moveInto dir
    dirA = dirA.moveInto(dirB)
    verifyEq(dirA.parent, dirB)

    // rename
    dirA = dirA.rename("foo")
    verifyEq(dirA.name, "foo")
    verifyEq(dirB.list[0].name, "foo")

    // move to existing
    verifyErr(IOErr#) { dirA.moveTo(this.tempDir) }
    verifyErr(IOErr#) { dirA.rename("foo") }
  }

  Void testStreamConvenience()
  {
    f := tempDir + `testfile.txt`

    out := f.out.writeChars("alpha\nbeta\rgamma").close
    verifyEq(f.in.readAllStr, "alpha\nbeta\ngamma")
    verifyEq(f->in->readAllStr, "alpha\nbeta\ngamma")

    out = f.out(false, 0).writeChars("alpha\nbeta\rgamma").close
    verifyEq(f.in(0).readAllStr, "alpha\nbeta\ngamma")

    out = f.out(true, 0).writeChars("\ndelta").close
    verifyEq(f.in(10).readAllStr, "alpha\nbeta\ngamma\ndelta")

    out = f.out(false, 4).writeChars("alpha\nbeta\rgamma").close
    verifyEq(f.in(1024).readAllStr, "alpha\nbeta\ngamma")

    //TODO
    //buf := f.readAllBuf
    //verifyEq(buf.readAllStr, "alpha\nbeta\ngamma")

    lines := f.readAllLines
    verifyEq(lines, ["alpha", "beta", "gamma"])

    lines.clear
    f.eachLine |Str line| { lines.add(line) }
    verifyEq(lines, ["alpha", "beta", "gamma"])

    all := f.readAllStr
    verifyEq(all, "alpha\nbeta\ngamma")

    allNoNorm := f.readAllStr(false)
    verifyEq(allNoNorm, "alpha\nbeta\rgamma")
/*
    f.writeObj([1, 2, 3])
    verifyEq(f.readObj, [1, 2, 3])
    f.writeObj(Version.make([1,5]), ["indent":2])
    verifyEq(f.readObj, Version.make([1,5]))

    props := ["a":"alpha","b":"betal"]
    f.writeProps(props)
    verifyEq(f.readProps, props)
   */
  }

  Void testAvail()
  {
    f := tempDir + `testfile.txt`
    f.out.print("1234567890").close
    in := f.in
    verifyEq(in.avail, 10)
    in.read
    verifyEq(in.avail, 9)
    in.readChar
    verifyEq(in.avail, 8)
    in.readLine
    verifyEq(in.avail, 0)
    in.close
  }

  Void testReadAllLinesNL()
  {
    f := tempDir + `testfile.txt`
    f.out.print("a\nb").close
    verifyEq(f.readAllLines, ["a", "b"])
    f.out.print("a\nb\n").close
    verifyEq(f.readAllLines, ["a", "b"])
    f.out.print("a\nb\n\n").close
    verifyEq(f.readAllLines, ["a", "b", ""])
    f.out.print("a\nb\n\n\n").close
    verifyEq(f.readAllLines, ["a", "b", "", ""])
  }

  Void testModifyTime()
  {
    start := TimePoint.now
    f := tempDir + `testfile.txt`
    verifyEq(f.modified, TimePoint.epoch)

    f.create
    verify(start+(-1sec) <= f.modified && f.modified <= TimePoint.now+1sec)

    yesterday := TimePoint.now - 1day
    f.modified = yesterday
    verifyEq(f.modified , yesterday)
  }

  Void testOsPath()
  {
    // abs
    f := tempDir
    g := File.os(f.osPath)
    verifyEq(f.uri.relToAuth, g.uri)
    verifyEq(f.osPath, g.osPath)

    // relative
    f = File.make(`foo/file.txt`)
    g = File.os(f.osPath)
    verifyEq(f.uri, g.uri)
    verifyEq(f.osPath, g.osPath)
/*
    // escaped files
    f = File.make(`file \#2`)
    g = File.os(f.osPath)
    verifyEq(f.uri, g.uri)
    verifyEq(f.osPath, g.osPath)

    // create
    f = tempDir + `dir\#1/`
    f.create
    verify(f.osPath.endsWith("dir#1"))
    verify(f.pathStr.endsWith("/dir\\#1/"))
    verifyEq(f.name, "dir\\#1")

    // list
    verifyEq(tempDir.list[0].name, "dir\\#1")

    // plus
    g = f + Uri.fromStr("cool \\#5")
    verify(g.osPath.endsWith("dir#1" + File.sep + "cool #5"))
    verify(g.pathStr.endsWith("/dir\\#1/cool \\#5"))
    verifyEq(g.path[-2], "dir\\#1")
    verifyEq(g.path[-1], "cool \\#5")

    // backup
    d1 := tempDir+`alpha\#1/`; d1.plus(`foo.txt`).out.print("alpha").close
    d2 := d1+`bravo\#2/`;      d2.plus(`foo.txt`).out.print("bravo").close
    d3 := d2+`charlie\#3/`;    d3.plus(`foo.txt`).out.print("charlie").close

    // backup should work
    verifyEq((d3+`foo.txt`).readAllStr, "charlie")
    verifyEq((d3+`../foo.txt`).readAllStr, "bravo")
    verifyEq((d3+`../../foo.txt`).readAllStr, "alpha")
    verifyEq((d1+`bravo\#2/../foo.txt`).readAllStr, "alpha")
    verifyEq((d1+`ignore/../foo.txt`).readAllStr, "alpha")

    // should not work
    verifyErr(IOErr#) { (d3+`\\../foo.txt`).readAllStr }
    verifyErr(IOErr#) { (d3+`.\\./foo.txt`).readAllStr }
    verifyErr(IOErr#) { (d3+`..\\/foo.txt`).readAllStr }
    verifyErr(IOErr#) { (d3+`../\\../foo.txt`).readAllStr }
    verifyErr(IOErr#) { (d3+Uri.decode("%5c../foo.txt")).readAllStr }
    verifyErr(IOErr#) { (d3+Uri.decode(".%5c./foo.txt")).readAllStr }
    verifyErr(IOErr#) { (d3+Uri.decode("..%5c/foo.txt")).readAllStr }

    // extra Windoze testing
    if (Env.cur.os == "win32")
    {
      f = File.make(`/a/b/c.txt`)
      verifyEq(f.uri.toStr.replace("/", "\\"), f.osPath)
      f = f.normalize
      verifyEq(f.uri.pathOnly.toStr.replace("/", "\\")[1..-1], f.osPath)
      verifyEq(File.pathSep, ";")
    }
    */
  }
/*TODO
  Void testOpen()
  {
    // most FileBuf stuff tested in BufTest

    f := tempDir + `foobar`

    b := f.open("rw")
    b.print("hello world")
    b.close
    verifyEq(f.readAllStr, "hello world")

    b = f.open("r")
    verifyErr(IOErr#) { b.write('x') }
    verifyEq(b.read, 'h')
    verifyEq(b.read, 'e')
    b.seek(6)
    verifyEq(b.read, 'w')
    b.close
  }

  Void testMmap()
  {
    // we have to use a special directory b/c f***ing Java
    // doesn't let us close the file so we can delete it until
    // after the process exits and we re-run this test
    dir := tempDir + `../test-mmap/`
    dir.delete
    dir.create
    b := (dir + `mmaptest.hex`).mmap("rw", 0, 20_000)

    // verify initial state
    verifyEq(b.pos, 0)
    verifyEq(b.size, 20_000)
    verifyEq(b.capacity, 20_000)
    verifyEq(b[0], 0)
    verifyEq(b[19_999], 0)
    verifyEq(b[-1], 0)

    // write some bytes
    b.write('a').write('b').write('c')
    verifyEq(b.pos, 3)
    verifyEq(b.size, 20_000)
    verifyEq(b.capacity, 20_000)
    verifyEq(b[0], 'a')
    verifyEq(b[1], 'b')
    verifyEq(b[2], 'c')
    verifyEq(b[-1], 0)
    verifyEq(b[-20_000], 'a')
    verifyEq(b[-19_999], 'b')
    verifyEq(b[-19_998], 'c')

    // read
    b.seek(0)
    verifyEq(b.peek, 'a')
    verifyEq(b.read, 'a')
    verifyEq(b.read, 'b')
    verifyEq(b.peek, 'c')
    verifyEq(b.read, 'c')
    verifyEq(b.read, 0)

    // slice
    verifyEq(b[0..0].readAllStr, "a")
    b[1] = 'x'
    verifyEq(b[0..2].readAllStr, "axc")
    verifyEq(b[0..<2].readAllStr, "ax")

    // binary
    b.seek(0)
    StreamTest.writeBinary(b.out)
    b.seek(0)
    StreamTest.readBinary(this, b.in, false)

    // test transfer matrix
    x := Buf.make
    x.size = 10_000
    x.size.times |Int i| { x[i] = Int.random(0..255) }

    // MemBuf -> MmapBuf
    b.seek(0)
    b.writeBuf(x)
    b.writeBuf(x.seek(400), 10)
    verifyRegion(b, 0, x, 0, 10_000)
    verifyRegion(b, 10_000, x, 400, 10)

    // MmapBuf -> MemBuf
    m := Buf.make
    b.seek(77)
    b.readBuf(m, 5000)
    verifyRegion(b, 77, m, 0, 5000)
    b.readBuf(m, 33)
    verifyRegion(b, 5077, m, 5000, 33)

    // MmapBuf -> FileBuf
    f := dir + `filebuf.hex`
    fb := f.open("rw")
    b.seek(0)
    fb.writeBuf(b, 4000)
    b.seek(6000).readBuf(fb, 2000)
    fb.close
    m = f.readAllBuf
    verifyRegion(b, 0, m, 0, 4000)
    verifyRegion(b, 6000, m, 4000, 2000)

    // FileBuf -> MmapBuf (fb same as m)
    fb = f.open("r")
    b.seek(12_000)
    fb.readBuf(b, 1200)
    fb.seek(300)
    b.writeBuf(fb, 4000)
    fb.close
    verifyRegion(b, 12_000, m, 0,  1200)
    verifyRegion(b, 13_200, m, 300, 4000)

    // MmapBuf -> OutStream
    out := f.out
    b.seek(3)
    out.writeBuf(b, 7000)
    out.close
    m = f.readAllBuf
    verifyRegion(b, 3, m, 0, 7000)

    // InStream -> MmapBuf
    in := f.in
    in.skip(7)
    b.seek(12_000)
    in.readBuf(b, 6000)
    in.close
    verifyRegion(b, 12_000, m, 7, 6000)

    // MmapBuf -> MmapBuf
    fb = f.mmap("rw", 0, 20_000)
    b.seek(3)
    fb.writeBuf(b, 10_000)
    verifyEq(b.pos, 10_003)
    verifyEq(fb.pos, 10_000)
    b.seek(66)
    fb.writeBuf(b, 400)
    verifyRegion(b, 3, fb, 0, 10_000)
    verifyRegion(b, 66, fb, 10_000, 400)
    fb.seek(100)
    b.seek(200)
    fb.readBuf(b, 7000)
    verifyRegion(b, 200, fb, 100, 7000)

    b.close
    fb.close

    // write a file of known size
    (dir + `foo.txt`).out.print("alpha\nbeta").close
    b = (dir + `foo.txt`).mmap("r", 0)
    verifyEq(b.read, 'a')
    verifyEq(b.readChar, 'l')
    verifyEq(b.readLine, "pha")
    verifyEq(b.readLine, "beta")
    verifyEq(b.readLine, null)
    verifyEq(b.read, null)
    verifyEq(b.readChar, null)
    b.close
    b = (dir + `foo.txt`).mmap("r", 0)
    m.clear
    verifyEq(b.readBuf(m, 100), 10)
    verifyEq(m.flip.readAllStr, "alpha\nbeta")
    verifyEq(b.readBuf(m, 100), null)
    b.close
  }
*/
  Void verifyRegion(Buf a, Int apos, Buf b, Int bpos, Int len)
  {
    eq := true
    len.times |Int i|
    {
      eq = eq.and(a[apos+i] == b[bpos+i])
    }
    verify(eq)
  }

  Void testSync()
  {
    f := tempDir + `testsync`
    out := f.out
    out.print("hello there!")
    out.sync
    verifyEq(f.readAllStr, "hello there!")
    out.close
  }

  Void testStore()
  {
    f := tempDir
    s := f.store
    verify(s.totalSpace > 0)
    verify(s.totalSpace > s.availSpace)
    verify(s.totalSpace > s.freeSpace)
    //verifyEq(s.typeof.qname, "sys::LocalFileStore")
  }

  Void testList()
  {
    f := tempDir
    a := (f+`a.txt`).create
    b := (f+`b.txt`).create
    c := (f+`c.foo`).create
    x := (f+`x-dir/`).create
    y := (f+`y-dir/`).create
    z := (f+`z/`).create

    //reAll := Regex.glob("*")

    verifyList(f.list, [a, b, c, x, y, z])
    /*TODO
    verifyList(f.list(null), [a, b, c, x, y, z])
    verifyList(f.list(reAll), [a, b, c, x, y, z])
    verifyList(f.list(Regex.glob("*.txt")), [a, b])
    verifyList(f.list(Regex.glob("c*")), [c])
    verifyList(f.list(Regex.glob("?-dir")), [x, y])
    verifyList(f.list(Regex.glob("none")), File[,])
    */

    verifyList(f.listFiles, [a, b, c])
    /*
    verifyList(f.listFiles(null), [a, b, c])
    verifyList(f.listFiles(reAll), [a, b, c])
    verifyList(f.listFiles(Regex.glob("*.txt")), [a, b])
    verifyList(f.listFiles(Regex.glob("c*")), [c])
    verifyList(f.listFiles(Regex.glob("?-dir")), File[,])
    verifyList(f.listFiles(Regex.glob("none")), File[,])
    */
    verifyList(f.listDirs, [x, y, z])
    /*
    verifyList(f.listDirs(null), [x, y, z])
    verifyList(f.listDirs(reAll), [x, y, z])
    verifyList(f.listDirs(Regex.glob("*.txt")), File[,])
    verifyList(f.listDirs(Regex.glob("c*")), File[,])
    verifyList(f.listDirs(Regex.glob("?-dir")), [x, y])
    verifyList(f.listDirs(Regex.glob("none")), File[,])
    */
  }

  Void verifyList(File[] actual, File[] expected)
  {
    actual.sort |a, b| { a.name <=> b.name }
    verifyEq(actual, expected)
  }

}