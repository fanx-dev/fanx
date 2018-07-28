//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2011-4-2  Jed Young  Creation
//

native class ObjArray {
  new make(Int size, Type? type)

  @Operator Obj? get(Int pos)

  @Operator Void set(Int pos, Obj? val)

  Int size()

  ObjArray realloc(Int newSize)

  This fill(Obj? obj, Int times)

  This copyFrom(ObjArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}

native class FloatArray {

  ** Create a 32-bit float array.
  static FloatArray makeF4(Int size)

  ** Create a 64-bit float array.
  static FloatArray makeF8(Int size)

  ** Protected constructor for implementation classes
  internal new make()

  @Operator Float get(Int pos)

  @Operator Void set(Int pos, Float val)

  Int size()

  FloatArray realloc(Int newSize)

  This fill(Float val, Int times)

  This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}

native class IntArray {
  ** Create a signed 8-bit, 1-byte integer array (-128 to 127).
  static IntArray makeS1(Int size)

  ** Create a unsigned 8-bit, 1-byte integer array (0 to 255).
  static IntArray makeU1(Int size)

  ** Create a signed 16-bit, 2-byte integer array (-32_768 to 32_767).
  static IntArray makeS2(Int size)

  ** Create a unsigned 16-bit, 2-byte integer array (0 to 65_535).
  static IntArray makeU2(Int size)

  ** Create a signed 32-bit, 4-byte integer array (-2_147_483_648 to 2_147_483_647).
  static IntArray makeS4(Int size)

  ** Create a unsigned 32-bit, 4-byte integer array (0 to 4_294_967_295).
  static IntArray makeU4(Int size)

  ** Create a signed 64-bit, 8-byte integer array.
  static IntArray makeS8(Int size)

  ** Protected constructor for implementation classes
  internal new make()

  @Operator Int get(Int pos)

  @Operator Void set(Int pos, Int val)

  Int size()

  IntArray realloc(Int newSize)

  This fill(Int val, Int times)

  This copyFrom(IntArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}

native class ByteArray {
  new make(Int size)

  @Operator Int get(Int pos)

  @Operator Void set(Int pos, Int val)

  Int size()

  ByteArray realloc(Int newSize)

  This fill(Int byte, Int times)

  This copyFrom(ByteArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}

native class BoolArray {
  new make(Int size)

  @Operator Bool get(Int pos)

  @Operator Void set(Int pos, Bool val)

  Int size()

  BoolArray realloc(Int newSize)

  This fill(Bool val, Int times)

  This copyFrom(BoolArray that, Int thatOffset, Int thisOffset, Int length)

  protected override Void finalize()
}