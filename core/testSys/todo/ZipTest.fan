//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Aug 06  Brian Frank  Creation
//

**
** ZipTest
**
class ZipTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Open
//////////////////////////////////////////////////////////////////////////

  Void testOpen()
  {
    // open a known zip file, for testing we can use a pod file
    f := Env.cur.homeDir + `lib/fan/sys.pod`
    z := Zip.open(f)
    verifySame(z.file, f)
    verifyEq(z.toStr, f.uri.toStr)
    verify(z.contents.isRO)

    // open known file
    sys := z.contents[`/meta.props`]
    verifyEq(sys.uri, `/meta.props`)
    verifyEq(sys.in.readProps["pod.name"], "sys")

    // copy to local file
    x := sys.copyInto(tempDir)
    verifyEq(x.name, "meta.props")
    verifyEq(x.size, sys.size)
    verifyEq(x.in.readProps["pod.name"], "sys")

    // verify errors
    verifyErr(IOErr#) { Zip.open(sys) }
    verifyErr(IOErr#) { Zip.open(Env.cur.homeDir) }
    verifyErr(IOErr#) { Zip.open(Env.cur.homeDir + `notfound.txt`) }
    verifyErr(IOErr#) { sys.out }
    verifyErr(IOErr#) { sys.create }
    verifyErr(IOErr#) { sys.delete }
    verifyErr(IOErr#) { sys.deleteOnExit }
    verifyErr(IOErr#) { sys.moveTo(this.tempDir) }
    verifyErr(UnsupportedErr#) { z.readNext() }
    verifyErr(UnsupportedErr#) { z.writeNext(`/foo.txt`) }
    verifyErr(UnsupportedErr#) { z.finish }

    // cleanup
    z.close
  }

//////////////////////////////////////////////////////////////////////////
// Create
//////////////////////////////////////////////////////////////////////////

  Void testCreate()
  {
    // write to file
    f := tempDir + `test.zip`
    z := Zip.write(f.out)
    write(z)
    z.close

    // read from file
    z = Zip.read(f.in)
    read(z)
    z.close

    // write to Buf
    buf := Buf.make
    z = Zip.write(buf.out)
    write(z)
    z.finish
    buf.printLine("end")
    verifyEq(buf[-4], 'e')
    verifyEq(buf[-3], 'n')
    verifyEq(buf[-2], 'd')
    verifyEq(buf[-1], '\n')

    // read from buf
    buf.flip
    z = Zip.read(buf.in)
    read(z)

    // read from file into buf
    z = Zip.read(f.readAllBuf.in)
    read(z)

    // read from file into buf (without reading data)
    z = Zip.read(f.readAllBuf.in)
    while (true)
    {
      entry := z.readNext()
      if (entry == null) break
      verify([`/foo.txt`, `/path/bar.hex`].contains(entry.uri))
    }

    // read from file into buf (with reading data)
    z = Zip.read(f.readAllBuf.in)
    while (true)
    {
      entry := z.readNext()
      if (entry == null) break
      verify([`/foo.txt`, `/path/bar.hex`].contains(entry.uri))
      verify(entry.readAllBuf.size >= 8)
    }
  }

  Void write(Zip z)
  {
    // open for writing
    verify(z.file == null)
    verify(z.contents == null)

    // file 1
    out := z.writeNext(`/foo.txt`)
    out.printLine("hello zip!")
    out.close

    // file 2 (no leading slash)
    out = z.writeNext(`path/bar.hex`, yesterday)
    out.writeI8(0xabcd_0123_0000_ffff)
    out.close

    // errors
    verifyErr(UnsupportedErr#) { z.readNext() }
    verifyErr(ArgErr#) { z.writeNext(`/file.txt#frag`) }
    verifyErr(ArgErr#) { z.writeNext(`/file.txt?query`) }
  }

  Void read(Zip z)
  {
    // open for writing
    verify(z.file == null)
    verify(z.contents == null)

    // file 1
    f := z.readNext
    verifyEq(f.uri, `/foo.txt`)
    verifyEq(f.parent, null)
    verifyEq(f.osPath, null)
    if (f.size != null) verifyEq(f.size, 11); // doesn't work conistently in Java
    verify(start + -2sec <= f.modified && f.modified <= DateTime.now + 2sec)
    verifyEq(f.readAllStr, "hello zip!\n")

    // file 2
    f = z.readNext
    verifyEq(f.uri, `/path/bar.hex`)
    verifyEq(f.parent, null)
    verifyEq(f.osPath, null)
    if (f.size != null) verifyEq(f.size, 8); // doesn't work consistently in Java
    verify(yesterday + -2sec <= f.modified && f.modified <= yesterday + 2sec)
    verifyEq(f.in.readS8, 0xabcd_0123_0000_ffff)

    // errors
    verifyErr(UnsupportedErr#) { z.writeNext(`/relative.txt`) }
    verifyErr(UnsupportedErr#) { z.finish }
  }

  DateTime start := DateTime.now
  DateTime yesterday := DateTime.now + (-1day)

//////////////////////////////////////////////////////////////////////////
// GZIP
//////////////////////////////////////////////////////////////////////////

  Void testGzip()
  {
    // generate string with lots of duplicate text
    s := StrBuf()
    100.times { s.add("hello world!\n") }
    text := s.toStr

    // check size if we write raw
    buf := Buf()
    buf.out.print(text)
    rawSize := buf.size

    // write to buffer with gzip
    buf = Buf()
    Zip.gzipOutStream(buf.out).print(text).close
    gzipSize := buf.size

    // verify gzip is smaller than raw size
    verify(gzipSize < rawSize)

    // verify we can read it back out
    x := Zip.gzipInStream(buf.flip.in).readAllStr
    verifyEq(text, x)
  }

//////////////////////////////////////////////////////////////////////////
// Deflate/Inflate
//////////////////////////////////////////////////////////////////////////

  Void testDeflate()
  {
    verifyDeflate(null)
    verifyDeflate(["nowrap":true])
  }

  private Void verifyDeflate([Str:Obj]? opts)
  {
    // generate string with lots of duplicate text
    s := StrBuf()
    100.times { s.add("hello deflate!\n") }
    text := s.toStr

    // check size if we write raw
    buf := Buf()
    buf.out.print(text)
    rawSize := buf.size

    // write to buffer with deflate
    buf = Buf()
    if (opts == null)
      Zip.deflateOutStream(buf.out).print(text).close
    else
      Zip.deflateOutStream(buf.out, opts).print(text).close
    deflateSize := buf.size

    // verify gzip is smaller than raw size
    verify(deflateSize < rawSize)

    // verify we can read it back out
    x := Zip.deflateInStream(buf.flip.in, opts).readAllStr
    verifyEq(text, x)
  }

}