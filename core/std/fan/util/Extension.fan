

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
  static extension Obj? readObj(InStream in, Bool close := true, [Str:Obj]? options := null) {
    try {
      return ObjDecoder.make(in, options).readRootObj
    }
    finally {
      in.close
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
  static extension OutStream writeObj(OutStream out, Obj? obj, Bool close := true, [Str:Obj]? options := null) {
    try {
      ObjEncoder.make(out, options).writeObj(obj)
    }
    finally {
      out.close
    }
    return out
  }

  native static extension Err traceTo(Err self, OutStream out := Env.cur.out, [Str:Obj]? options := null)

  **
  ** split by any char
  **
  extension static Str[] splitAny(Str str, Str sp, Bool normalize := true) {
    res := Str[,]
    buf := StrBuf()
    for (i:=0; i<str.size; ++i) {
      c := str[i]
      if (sp.containsChar(c)) {
        part := buf.toStr
        if (normalize) part = part.trim
        if (part.size > 0 || !normalize) {
          res.add(part)
          buf.clear()
        }
      }
      else {
        buf.addChar(c)
      }
    }
    return res
  }

  **
  ** split by Str
  **
  extension static Str[] splitBy(Str str, Str sp, Int max := Int.maxVal) {
    if (sp.size == 0) {
      return [str]
    }
    res := Str[,]
    while (true) {
      if (res.size == max-1) {
        res.add(str)
        break
      }
      i := str.index(sp)
      if (i == null) {
        res.add(str)
        break
      }

      part := str[0..<i]
      res.add(part)

      start := i + sp.size
      if (start < str.size) {
        str = str[start..-1]
      } else {
        str = ""
      }
    }

    return res
  }

  **
  ** get the sub string between begin and end
  **
  extension static Str? extract(Str str, Str? begin, Str? end) {
    s := 0
    if (begin != null) {
      p0 := str.index(begin)
      if (p0 == null) {
        return null
      }
      s = p0 + begin.size
    }

    e := str.size
    if (end != null) {
      p0 := str.index(end, s)
      if (p0 == null) {
        return null
      }
      e = p0
    }
    return str[s..<e]
  }

}