//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Sep 08  Kevin McIntire  Creation
//   24 Mar 10  Brian Frank     json::JsonWriter to util::JsonOutStream
//

**
** JsonInStream reads objects from Javascript Object Notation (JSON).
**
** See [pod doc]`pod-doc#json` for details.
**
@Js
@NoDoc
class JsonInStream : ProxyInStream
{
  **
  ** Construct by wrapping given input stream.
  **
  new make(InStream in) : super(in) {}

  **
  ** Read a JSON object from this stream and return one
  ** of the follow types:
  **   - null
  **   - Bool
  **   - Int
  **   - Float
  **   - Str
  **   - Str:Obj?
  **   - Obj?[]
  **
  ** See [Str.in]`sys::Str.in` to read from an in-memory string.
  **
  Obj? readJson()
  {
    pos = 0
    consume
    skipWhitespace
    return parseVal
  }

  private Str:Obj? parseObj()
  {
    pairs := OrderedMap<Str,Obj?>()//[:] { ordered = true }

    skipWhitespace

    expect(JsonToken.objectStart)

    while (true)
    {
      skipWhitespace
      if (maybe(JsonToken.objectEnd)) return pairs

      // FIXIT would like pair to be a 2-tuple
      // OR a map with atom/symbol keys!
      // FIXIT what about empty object?
      parsePair(pairs)
      if (!maybe(JsonToken.comma)) break
    }

    expect(JsonToken.objectEnd)

    return pairs
  }

  private Void parsePair([Str:Obj?] obj)
  {
    skipWhitespace
    key := parseKey

    skipWhitespace

    expect(JsonToken.colon)
    skipWhitespace

    val := parseVal
    skipWhitespace

    obj[key] = val
  }

  private Obj? parseVal()
  {
    if (this.cur == JsonToken.quote) return parseStr
    else if (this.cur.isDigit || this.cur == '-') return parseNum
    else if (this.cur == JsonToken.objectStart) return parseObj
    else if (this.cur == JsonToken.arrayStart) return parseArray
    else if (this.cur == 't')
    {
      "true".size.times |->| { consume }
      return true
    }
    else if (this.cur == 'f')
    {
      "false".size.times |->| { consume }
      return false
    }
    else if (this.cur == 'n')
    {
      "null".size.times |->| { consume }
      return null
    }

    if (cur < 0) throw err("Unexpected end of stream")
    throw err("Unexpected token " + this.cur)
  }

  private Obj parseNum()
  {
    integral := StrBuf()
    fractional := StrBuf()
    exponent := StrBuf()
    if (maybe('-'))
      integral.add("-")

    while (this.cur.isDigit)
    {
      integral.addChar(this.cur)
      consume
    }

    if (this.cur == '.')
    {
      decimal := true
      consume
      while (this.cur.isDigit)
      {
        fractional.addChar(this.cur)
        consume
      }
    }

    if (this.cur == 'e' || this.cur == 'E')
    {
      exponent.addChar(this.cur)
      consume
      if (this.cur == '+') consume
      else if (this.cur == '-')
      {
        exponent.addChar(this.cur)
        consume
      }
      while (this.cur.isDigit)
      {
        exponent.addChar(this.cur)
        consume
      }
    }

    Num? num := null
    if (fractional.size > 0)
      num = Float.fromStr(integral.toStr+"."+fractional.toStr+exponent.toStr)
    else if (exponent.size > 0)
      num = Float.fromStr(integral.toStr+exponent.toStr)
    else num = Int.fromStr(integral.toStr)

    return num
  }

  private Str parseKey() {
    if (cur == JsonToken.quote) {
      return parseStr
    }
    s := StrBuf()
    while (cur.isAlphaNum || cur == '_' || cur == '$' || cur == '-' || cur == '.') {
      s.addChar(cur)
      consume
    }
    return s.toStr
  }

  private Str parseStr()
  {
    s := StrBuf()
    expect(JsonToken.quote)
    while( cur != JsonToken.quote )
    {
      if (cur < 0) throw err("Unexpected end of str literal")
      if (cur == '\\')
      {
        s.addChar(escape)
      }
      else
      {
        s.addChar(cur)
        consume
      }
    }
    expect(JsonToken.quote)
    return s.toStr
  }

  private Int escape()
  {
    // consume slash
    expect('\\')

    // check basics
    switch (cur)
    {
      case 'b':   consume; return '\b'
      case 'f':   consume; return '\f'
      case 'n':   consume; return '\n'
      case 'r':   consume; return '\r'
      case 't':   consume; return '\t'
      case '"':   consume; return '"'
      case '\\':  consume; return '\\'
      case '/':   consume; return '/'
    }

    // check for uxxxx
    if (cur == 'u')
    {
      consume
      n3 := cur.fromDigit(16); consume
      n2 := cur.fromDigit(16); consume
      n1 := cur.fromDigit(16); consume
      n0 := cur.fromDigit(16); consume
      if (n3 == null || n2 == null || n1 == null || n0 == null) throw err("Invalid hex value for \\uxxxx")
      return n3.shiftl(12).or(n2.shiftl(8)).or(n1.shiftl(4)).or(n0)
    }

    throw err("Invalid escape sequence")
  }

  private Obj?[] parseArray()
  {
    array := [,]
    expect(JsonToken.arrayStart)
    skipWhitespace
    if (maybe(JsonToken.arrayEnd)) return array

    while (true)
    {
      skipWhitespace
      val := parseVal
      array.add(val)
      skipWhitespace
      if (!maybe(JsonToken.comma)) break
    }
    skipWhitespace
    expect(JsonToken.arrayEnd)
    return array
  }

  private Void skipWhitespace()
  {
    while (this.cur.isSpace)
      consume
  }

  private Void expect(Int tt)
  {
    if (this.cur < 0) throw err("Unexpected end of stream, expected ${tt.toChar}")
    if (this.cur != tt) throw err("Expected ${tt.toChar}, got ${cur.toChar} at ${pos}")
    consume
  }

  private Bool maybe(Int tt)
  {
    if (this.cur != tt) return false
    consume
    return true
  }

  private Void consume()
  {
    this.cur = readChar
    pos++
  }

  private Err err(Str msg) { ParseErr(msg) }

  private Int cur := '?'
  private Int pos := 0
}

**
** JsonToken represents the tokens in JSON.
**
internal class JsonToken
{
  internal static const Int objectStart := '{'
  internal static const Int objectEnd := '}'
  internal static const Int colon := ':'
  internal static const Int arrayStart := '['
  internal static const Int arrayEnd := ']'
  internal static const Int comma := ','
  internal static const Int quote := '"'
  internal static const Int grave := '`'
}