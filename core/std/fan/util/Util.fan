

class Util {

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