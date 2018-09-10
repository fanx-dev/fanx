//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

class Set<T> {
  private [T:Obj?] map := [:]

  new make() {
  }

  Void add(T k) { map[k] = null }

  Bool contains(T k) { map.containsKey(k) }

  Int size() { map.size }

  Void each(|T| f) {
    map.each |v,k| { f(k) }
  }
}

