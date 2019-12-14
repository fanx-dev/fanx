//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2011-4-2  Jed Young  Creation
//

@Extern
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

