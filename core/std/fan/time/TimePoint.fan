//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-26  Jed Young  Creation
//

**
** represents an absolute instance in time
**
@Serializable { simple = true }
const struct class TimePoint
{
  private const Int ticks

  private new make(Int ticks) {
  }

  static new fromMills(Int m) {
    make(m)
  }

  Int toMills() {
    ticks
  }
}