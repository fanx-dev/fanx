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

  **
  ** Return a new list containing all the items which are an instance
  ** of the specified type such that item.type.fits(t) is true.  Any null
  ** items are automatically excluded.  If none of the items are instance
  ** of the specified type, then an empty list is returned.  The returned
  ** list will be a list of t.  This method is readonly safe.
  **
  ** Example:
  **   list := ["a", 3, "foo", 5sec, null]
  **   list.findType(Str#) => Str["a", "foo"]
  **
  static extension Obj?[] findType(Obj?[] self, Type t) {
    nlist := List<Obj?>.make(8)
    self.each |obj| {
      if (obj == null) return
      result := obj.typeof.fits(t)
      if (result) {
        nlist.add(obj)
      }
    }
    return nlist
  }
}

