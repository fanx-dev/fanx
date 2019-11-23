//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2011-4-2  Jed Young  Creation
//

@NoDoc
native class ObjArray {
  new make(Int size)

  @Operator Obj? get(Int pos)

  @Operator Void set(Int pos, Obj? val)

  Int size()

  ObjArray realloc(Int newSize)

  This fill(Obj? obj, Int times) {
    for (i := 0; i < times; ++i) {
      this[i] = obj
    }
    return this
  }

  This copyFrom(ObjArray that, Int thatOffset, Int thisOffset, Int length) {
    for (i := 0; i<length; ++i) {
      this[i+thisOffset] = that[i+thatOffset]
    }
    return this
  }

  protected override Void finalize()

  @NoDoc
  static ObjArray? fromJava(Obj array) { null }

  @NoDoc
  Obj toJava(Obj clz) { clz }
}

native class ByteArray {
  new make(Int size)

  @Operator Int get(Int pos)

  @Operator Void set(Int pos, Int val)

  Int size()

  ByteArray realloc(Int newSize)

  This fill(Int byte, Int times) {
    for (i := 0; i < times; ++i) {
      this[i] = byte
    }
    return this
  }

  This copyFrom(ByteArray that, Int thatOffset, Int thisOffset, Int length) {
    for (i := 0; i<length; ++i) {
      this[i+thisOffset] = that[i+thatOffset]
    }
    return this
  }

  protected override Void finalize()
}

native class Array<T> {
  new make(Int size)
  Int size()
  @Operator T get(Int pos)
  @Operator Void set(Int pos, T val)

  static Obj realloc(Obj array, Int newSize)
  static Void arraycopy(Obj src, Int srcOffset, Obj dest, Int destOffset, Int length)
  static Void fill(Obj array, Obj? val, Int times)
  protected override Void finalize()
}

