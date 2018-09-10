//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the LGPL
// History:
//   2017-6-15  Jed Young  Creation
//

class ListExt {
  **
  ** Returns a new list with all duplicate items removed such that the
  ** resulting list is a proper set.  Duplicates are detected using hash()
  ** and the == operator (shortcut for equals method).  This method is
  ** readonly safe.
  **
  ** Example:
  **   ["a", "a", "b", "c", "b", "b"].unique => ["a", "b", "c"]
  **
  static extension Obj?[] unique(Obj?[] self) {
    if (self.size == 0) return self.dup
    map := HashMap<Obj?,Obj?> { keySafe = false }
    res := [,]
    self.each|v|{
      if (!map.containsKey(v)) {
        map[v] = 1
        res.add(v)
      }
    }
    return res
  }

  **
  ** Return a new list which is the union of this list and the given list.
  ** The union is defined as the unique items which are in *either* list.
  ** The resulting list is ordered first by this list's order, and secondarily
  ** by that's order.  The new list is guaranteed to be unique with no duplicate
  ** values.  Equality is determined using hash() and the == operator
  ** (shortcut for equals method).  This method is readonly safe.
  **
  ** Example:
  **   [1, 2].union([3, 2]) => [1, 2, 3]
  **
  static extension Obj?[] union(Obj?[] self, Obj?[] that) {
    map := HashMap<Obj?,Obj?> { keySafe = false }
    res := [,]
    self.each|v|{
      if (!map.containsKey(v)) {
        map[v] = 1
        res.add(v)
      }
    }
    that.each|v|{
      if (!map.containsKey(v)) {
        map[v] = 1
        res.add(v)
      }
    }
    return res
  }

  **
  ** Return a new list which is the intersection of this list and the
  ** given list.  The intersection is defined as the unique items which
  ** are in *both* lists.  The new list will be ordered according to this
  ** list's order.  The new list is guaranteed to be unique with no duplicate
  ** values.  Equality is determined using hash() and the == operator
  ** (shortcut for equals method).  This method is readonly safe.
  **
  ** Example:
  **   [0, 1, 2, 3].intersection([5, 3, 1]) => [1, 3]
  **   [0, null, 2].intersection([null, 0, 1, 2, 3]) => [0, null, 2]
  **
  static extension Obj?[] intersection(Obj?[] self, Obj?[] that) {
    map := HashMap<Obj?,Obj?> { keySafe = false }
    res := [,]
    that.each|v|{
      map[v] = 1
    }
    self.each|v|{
      if (map.containsKey(v)) {
        res.add(v)
        map.remove(v)
      }
    }
    return res
  }
}

