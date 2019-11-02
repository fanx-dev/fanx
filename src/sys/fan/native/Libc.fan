

**
** C runtime library
**
@NoDoc
class Libc {

  static native Int toId(Obj self)

  static native Int32 strlen(Ptr cstr)
  static native Ptr strdup(Ptr cstr)
  static native Void free(Ptr str)
  static native Int8 getByte(Ptr cstr, Int at)

  static native Ptr malloc(Int size)
  static native Ptr realloc(Ptr old, Int size)

  static native Void memcpy(Ptr dst, Ptr src, Int len)
  static native Void memmove(Ptr dst, Ptr src, Int len)

  static native Int charSize()
  static native Int getChar(Ptr str, Int at)
  static native Void setChar(Ptr str, Int at, Int val)

  static native Ptr toUtf8(Ptr charPtr, Int len)
  static native Ptr fromUtf8(Ptr cstr, Int len)
}