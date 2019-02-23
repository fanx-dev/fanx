//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 06  Brian Frank  Creation
//

**
** FileBufTest
**
class FileBufTest : Test
{

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
    verifyEq(fb.size, 6000)
    fb.sync
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
    verifyEq(b.read, -1)
    verifyEq(b.readChar, -1)
    b.close
    b = (dir + `foo.txt`).mmap("r", 0)
    m.clear
    verifyEq(b.readBuf(m, 100), 10)
    verifyEq(m.flip.readAllStr, "alpha\nbeta")
    //verifyEq(b.readBuf(m, 100), null)
    b.close

    dir.delete
  }

  Void verifyRegion(Buf a, Int apos, Buf b, Int bpos, Int len)
  {
    eq := true
    len.times |Int i|
    {
      eq = eq.and(a[apos+i] == b[bpos+i])
    }
    verify(eq)
  }

}