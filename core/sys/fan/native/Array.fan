//
// Copyright (c) 2010, chunquedong
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
   new make(Int size, Int byteSize)

   @Operator Float get(Int pos)

   @Operator Void set(Int pos, Float val)

   Int size()

   FloatArray realloc(Int newSize)

   This fill(Float val, Int times)

   This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length)

   protected override Void finalize()
}

native class IntArray {
   new make(Int size, Int byteSize)

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

   This copyFrom(ByteArray that, Int thatOffset, Int thisOffset, Int length)

   protected override Void finalize()
}