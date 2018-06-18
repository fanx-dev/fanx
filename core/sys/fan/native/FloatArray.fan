//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2011-4-2  Jed Young  Creation
//

native class FloatArray {
   new make(Int size, Int byteSize)

   @Operator Float get(Int pos)

   @Operator Void set(Int pos, Float val)

   Int size()

   Bool realloc(Int newSize)

   This copyFrom(FloatArray that, Int thatOffset, Int thisOffset, Int length)

   protected override Void finalize()
}

