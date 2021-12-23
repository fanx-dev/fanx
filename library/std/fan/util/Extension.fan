

class Extension {

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
  static extension Obj? readObj(InStream in, [Str:Obj]? options := null, Bool close := true) {
    try {
      return ObjDecoder.make(in, options).readRootObj
    }
    finally {
      if (close) in.close
    }
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
  static extension OutStream writeObj(OutStream out, Obj? obj, [Str:Obj]? options := null, Bool close := true) {
    try {
      ObjEncoder.make(out, options).writeObj(obj)
    }
    finally {
      if (close) out.close
    }
    return out
  }

  **
  ** Dump the stack trace of this exception to the specified
  ** output stream (or 'Env.cur.err' by default).  Return this.
  **
  ** The options may be used to specify the format of the output:
  **   - "indent": Int for initial number of indentation spaces
  **   - "maxDepth": Int specifies how many methods in each
  **        exception of chain to include.  If unspecified the
  **        default is configured from the "errTraceMaxDepth" prop
  **        in etc/sys/config.props.
  **
  static extension Err traceTo(Err self, OutStream out := Env.cur.out, [Str:Obj]? options := null) {
    out.printLine(self.traceToStr)
    return self
  }

}