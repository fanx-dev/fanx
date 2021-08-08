//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

internal class FileBuf : Buf
{
  private Int handle

  new make(File file, Str mode) : super.privateMake() {
    if (!init(file, mode)) {
      throw IOErr("open file error: $file, $mode")
    }
  }

  protected native Bool init(File file, Str mode)

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

