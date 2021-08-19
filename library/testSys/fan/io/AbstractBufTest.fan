//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Feb 16  Matthew Giannini   Creation
//

abstract class AbstractBufTest : Test
{

  override Void teardown() {
    bufs.each |Buf b| { verify(b.close) }
  }

//////////////////////////////////////////////////////////////////////////
// Setup
//////////////////////////////////////////////////////////////////////////

  Buf makeMem()
  {
    b := Buf.make;
    bufs.add(b);
    return b
  }

  Buf makeFile()
  {
    // js doesn't support files
    if (isJs) return makeMem

    name := "buf" + bufs.size
    file := tempDir + name.toUri
    b := file.open("rw")
    bufs.add(b)
    return b
  }

  Buf[] bufs := Buf[,]

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Buf ascii(Str ascii)
  {
    return Buf.make.print(ascii)
  }

  Void verifyBufEq(Buf a, Buf b)
  {
    verify(eq(a, b))
    verify(a.bytesEqual(b))
  }

  Void verifyBufNotEq(Buf a, Buf b)
  {
    verify(!eq(a, b))
    verify(!a.bytesEqual(b))
  }

  Bool eq(Buf a, Buf b)
  {
    if (a.size != b.size) return false
    for (i := 0; i<a.size; ++i)
      if (a[i] != b[i]) return false
    return true
  }

  Void verifyBufEqStr(Buf buf, Str ascii)
  {
    verifyEq(buf.size, ascii.size)
    for (i := 0; i<buf.size; ++i)
      verifyEq(buf[i], ascii[i])
  }
}