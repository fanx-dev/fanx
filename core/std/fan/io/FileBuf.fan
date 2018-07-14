
internal class FileBuf : Buf
{
  new make(File file, Str mode) : super.privateMake() {
    init(file, mode)
  }

  protected native Void init(File file, Str mode)

  native override Int size
  native override Int capacity
  native override Int pos

  native override Int getByte(Int index)
  native override Void setByte(Int index, Int byte)

  native override Int getBytes(Int pos, ByteArray dst, Int off, Int len)
  native override Void setBytes(Int pos, ByteArray src, Int off, Int len)

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


internal class NioBuf : Buf
{
  new make(File file, Str mode, Int pos, Int? size) : super.privateMake() {
    init(file, mode, pos, size)
  }

  protected native Void init(File file, Str mode, Int pos, Int? size)

  native override Int size
  native override Int capacity
  native override Int pos

  native override Int getByte(Int index)
  native override Void setByte(Int index, Int byte)

  native override Int getBytes(Int pos, ByteArray dst, Int off, Int len)
  native override Void setBytes(Int pos, ByteArray src, Int off, Int len)

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