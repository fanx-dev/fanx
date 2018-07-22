
using std

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
  static extension Obj[] findType(Obj?[] self, Type t) {
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

  **
  ** Read a serialized object from the stream according to
  ** the Fantom [serialization format]`docLang::Serialization`.
  ** Throw IOErr or ParseErr on error.  This method may consume
  ** bytes/chars past the end of the serialized object (we may
  ** want to add a "full stop" token at some point to support
  ** compound object streams).
  **
  ** The options may be used to specify additional decoding
  ** logic:
  **   - "makeArgs": Obj[] arguments to pass to the root
  **     object's make constructor via 'Type.make'
  **
  static extension Obj? readObj(InStream in, [Str:Obj]? options := null) {
    return ObjDecoder.make(in, options).readRootObj
  }

  **
  ** Write a serialized object from the stream according to
  ** the Fantom [serialization format]`docLang::Serialization`.
  ** Throw IOErr on error.  Return this.
  **
  ** The options may be used to specify the format of the output:
  **   - "indent": Int specifies how many spaces to indent
  **     each level.  Default is 0.
  **   - "skipDefaults": Bool specifies if we should skip fields
  **     at their default values.  Field values are compared according
  **     to the 'equals' method.  Default is false.
  **   - "skipErrors": Bool specifies if we should skip objects which
  **     aren't serializable. If true then we output null and a comment.
  **     Default is false.
  **
  static extension OutStream writeObj(OutStream out, Obj? obj, [Str:Obj]? options := null) {
    ObjEncoder.make(out, options).writeObj(obj)
    return out
  }
}