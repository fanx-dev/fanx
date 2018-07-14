//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Feb 16  Matthew Giannini   Creation
//

abstract class AbstractBufTest : Test
{
  File? tempDir

  override Void setup() {
    tempDir = `test_temp/`.toFile
    tempDir.delete
    tempDir.create
  }

  override Void teardown() {
    bufs.each |Buf b| { verify(b.close) }
    tempDir?.delete
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
    if ("js" == Env.cur.runtime) return makeMem

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
  }

  Void verifyBufNotEq(Buf a, Buf b)
  {
    verify(!eq(a, b))
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