using sys::Int32 as WChar
using sys::Int32 as NInt
using sys::Int64 as Size_t

**
** C runtime library
**
@NoDoc
native class NativeC {

  static native Int toId(Obj self)

  static native Size_t strlen(Ptr<Int8> cstr)
  static native Ptr<Int8> strdup(Ptr<Int8> cstr)
  
  static native Ptr<Int8> malloc(Size_t size)
  static native Ptr<Int8> realloc(Ptr<Int8> old, Size_t size)
  static native Void free(Ptr<Int8> str)

  static native Void memcpy(Ptr<Int8> dst, Ptr<Int8> src, Size_t len)
  static native Void memmove(Ptr<Int8> dst, Ptr<Int8> src, Size_t len)

  static native Ptr<Int8> toUtf8(Ptr<WChar> charPtr, Size_t len, Ptr<Size_t> utf8Size)
  static native Ptr<WChar> fromUtf8(Ptr<Int8> cstr, Size_t len, Ptr<Size_t> charBufSize)
  static native Size_t utf8Size(Ptr<Int8> cstr, Size_t len)

  static native Void puts(Ptr<Int8> cstr)
}
