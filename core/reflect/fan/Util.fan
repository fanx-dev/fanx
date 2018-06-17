
class Util {
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
  static extension List findType(List self, Type t) {
    nlist := List.make(8)
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