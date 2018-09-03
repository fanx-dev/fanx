//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

**
** Fantom props file format
**
internal class Props {
  /////////////////////////////////////////////////////////////////////////////
  // read
  /////////////////////////////////////////////////////////////////////////////

  static Str:Str readProps(InStream in) { doReadProps(in, false) }
  static Str:Str[] readPropsListVals(InStream in) { doReadProps(in, true) }

  private static [Str:Obj] doReadProps(InStream in, Bool listVals := false)  // listVals is Str:Str[]
  {
    Charset? origCharset := null;
    if (in.charset != Charset.utf8) {
      origCharset = in.charset
      in.charset = Charset.utf8
    }
    try
    {
      [Str:Obj] props := OrderedMap<Str,Obj>()
      //props.ordered(true)

      StrBuf name := StrBuf()
      StrBuf? val := null
      Int inBlockComment := 0
      Bool inEndOfLineComment := false
      Int c :=  ' '; Int last := ' '
      Int lineNum := 1
      Int colNum := 0

      while (true)
      {
        last = c
        c = in.readChar
        ++colNum
        if (c < 0) break

        // end of line
        if (c == '\n' || c == '\r')
        {
          colNum = 0
          inEndOfLineComment = false
          if (last == '\r' && c == '\n') continue
          Str n := name.toStr.trim//FanStr.makeTrim(name)
          if (val != null)
          {
            addProp(props, n, val.toStr.trim, listVals)
            name.clear()// = StrBuf()
            val = null
          }
          else if (n.size > 0)
            throw IOErr.make("Invalid name/value pair [Line " + lineNum + "]")
          lineNum++
          continue
        }

        // if in comment
        if (inEndOfLineComment) continue

        // block comment
        if (inBlockComment > 0)
        {
          if (last == '/' && c == '*') inBlockComment++
          if (last == '*' && c == '/') inBlockComment--
          continue
        }

        // equal
        if (c == '=' && val == null)
        {
          val = StrBuf()
          continue
        }

        // line comment
        if (c == '#' && colNum == 1)
        {
          inEndOfLineComment = true
          continue
        }

        // end of line comment
        if (c == '/' && (last.isSpace))
        {
          Int peek := in.readChar
          if (peek < 0) break
          if (peek == '/') { inEndOfLineComment = true; continue }
          if (peek == '*') { inBlockComment++; continue }
          in.unreadChar(peek)
        }

        // escape or line continuation
        if (c == '\\')
        {
          Int peek := in.readChar
          if (peek < 0) break
          else if (peek == 'n')  c = '\n'
          else if (peek == 'r')  c = '\r'
          else if (peek == 't')  c = '\t'
          else if (peek == '\\') c = '\\'
          else if (peek == '\r' || peek == '\n')
          {
            // line continuation
            lineNum++
            if (peek == '\r')
            {
              peek = in.readChar
              if (peek != '\n') in.unreadChar(peek)
            }
            while (true)
            {
              peek = in.readChar
              if (peek == ' ' || peek == '\t') continue
              in.unreadChar(peek)
              break
            }
            continue
          }
          else if (peek == 'u')
          {
            Int n3 := hex(in.readChar)
            Int n2 := hex(in.readChar)
            Int n1 := hex(in.readChar)
            Int n0 := hex(in.readChar)
            if (n3 < 0 || n2 < 0 || n1 < 0 || n0 < 0) throw IOErr.make("Invalid hex value for \\uxxxx [Line " +  lineNum + "]")
            c = n3.shiftl(12).or(n2.shiftl(8)).or(n1.shiftl(4)).or(n0)
          }
          else throw IOErr.make("Invalid escape sequence [Line " + lineNum + "]")
        }

        // normal character
        if (val == null)
          name.addChar(c)
        else
          val.addChar(c)
      }

      Str n := name.toStr.trim
      if (val != null)
        addProp(props, n, val.toStr.trim, listVals)
      else if (n.size > 0)
        throw IOErr.make("Invalid name/value pair [Line " + lineNum + "]")

      return props
    }
    finally
    {
      try { in.close } catch (Err e) { e.trace }
      if (origCharset != null) in.charset = origCharset
    }
  }

  private static Void addProp([Str:Obj] props, Str n, Str v, Bool listVals)
  {
    if (listVals)
    {
      Str[]? list := props.get(n)
      if (list == null) { list = [,]; props.add(n, list) }
      list.add(v)
    }
    else
    {
      props.add(n, v)
    }
  }

  private static Int hex(Int c)
  {
    if ('0' <= c && c <= '9') return c - '0';
    if ('a' <= c && c <= 'f') return c - 'a' + 10;
    if ('A' <= c && c <= 'F') return c - 'A' + 10;
    return -1;
  }

  /////////////////////////////////////////////////////////////////////////////
  // write
  /////////////////////////////////////////////////////////////////////////////

  static OutStream writeProps(OutStream out, [Str:Str] props, Bool close := true)
  {
    Charset? origCharset := null
    if (out.charset != Charset.utf8) {
      origCharset = out.charset
      out.charset = Charset.utf8
    }
    try
    {
      props.each |val, key| {
        writePropStr(out, key)
        out.writeChar('=')
        writePropStr(out, val)
        out.writeChar('\n')
      }
      return out
    }
    finally
    {
      try { if (close) out.close } catch (Err e) { e.trace }
      if (origCharset != null) out.charset = origCharset
    }
  }

  private static Void writePropStr(OutStream out, Str s)
  {
    Int len := s.size
    for (Int i:=0; i<len; ++i)
    {
      Int ch := s.get(i)
      Int peek := i+1<len ? s.get(i+1) : -1

      // escape special chars
      switch (ch)
      {
        case '\n': out.writeChar('\\').writeChar('n'); continue
        case '\r': out.writeChar('\\').writeChar('r'); continue
        case '\t': out.writeChar('\\').writeChar('t'); continue
        case '\\': out.writeChar('\\').writeChar('\\'); continue
      }

      // escape control chars, comments, and =
      if ((ch < ' ') || (ch == '/' && (peek == '/' || peek == '*')) || (ch == '='))
      {
        Int nib1 := ch.shiftr(4).and(0xf).toDigit(16)
        Int nib2 := ch.and(0xf).toDigit(16)

        out.writeChar('\\').writeChar('u')
          .writeChar('0').writeChar('0')
          .writeChar(nib1).writeChar(nib2)
        continue
      }

      // normal character
      out.writeChar(ch)
    }
  }
}

