//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

class NioBuf : Buf
{
  new fromFile(File file, Str mode, Int pos, Int? size) : super.privateMake() {
    init(file, mode, pos, size)
  }

  new makeMem(Int size) : super.privateMake() {
    alloc(size)
  }

  protected new make() {}

  protected native Void init(File file, Str mode, Int pos, Int? size)

  protected native Void alloc(Int size)

  native override Int size
  native override Int capacity
  native override Int pos

  native override Int getByte(Int index)
  native override Void setByte(Int index, Int byte)

  native override Int getBytes(Int pos, Array<Int8> dst, Int off, Int len)
  native override Void setBytes(Int pos, Array<Int8> src, Int off, Int len)

  native override Bool close()
  native override This sync()

  override Endian endian {
    set { in.endian = it; out.endian = it }
    get { out.endian }
  }
  override Charset charset {
    set { in.charset = it; out.charset = it }
    get { out.charset }
  }
}