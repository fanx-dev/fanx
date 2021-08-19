using sys::Int32 as WChar
using sys::Int32 as NInt
using sys::Int64 as Size_t

**
** C runtime library
**
@NoDoc
class NativeC {

  static native Int toId(Obj self)
  static native Str typeName(Obj self)
  
  static native Void print(Array<Int8> utf8)
  static native Void printErr(Array<Int8> utf8)
  static native Str stackTrace()

}

@NoDoc @Extern
class Libc {

  static native Size_t strlen(Ptr<Int8> cstr)
  static native Ptr<Int8> strdup(Ptr<Int8> cstr)
  
  static native Ptr<Int8> malloc(Size_t size)
  static native Ptr<Int8> realloc(Ptr<Int8> old, Size_t size)
  static native Void free(Ptr<Int8> str)

  static native Void memcpy(Ptr<Int8> dst, Ptr<Int8> src, Size_t len)
  static native Void memmove(Ptr<Int8> dst, Ptr<Int8> src, Size_t len)

  static native Void puts(Ptr<Int8> cstr)

}
