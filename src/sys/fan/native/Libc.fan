

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
  static native Int getChar(Ptr str, Int at)

}