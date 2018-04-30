//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2011-4-2  Jed Young  Creation
//

native class ObjArray {
   new make(Int size)

   @Operator Obj? get(Int pos)

   @Operator Void set(Int pos, Obj? val)

   Int size()

   Bool realloc(Int newSize)

   This copyFrom(ObjArray that, Int thatOffset, Int thisOffset, Int length)

   protected override Void finalize()
}

