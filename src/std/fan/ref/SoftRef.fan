//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

**
** Soft reference objects, which are cleared at the discretion of the garbage collector in response to memory demand.
**
/*
final native class SoftRef<T>
{
  ** Creates a new soft reference that refers to the given object.
  new make(T val)

  ** Returns this reference object's referent.
  ** If this reference object has been cleared, either by the program or by the garbage collector, then this method returns null.
  T? get()
}
*/
