//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

**
** call initial when val is null
**
@Extern
final native const class Lazy<T>
{
  new make(|->T| initial)

  T get()
}