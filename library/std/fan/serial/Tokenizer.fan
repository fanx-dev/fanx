//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//  3 Sep 05  Brian Frank  Creation for Fan compiler
//   17 Aug 07  Brian    Rework for serialization parser
//


/**
 * Tokenizer inputs a stream of Unicode characters and
 * outputs tokens for the Fantom serialization grammar.
 */
internal class Tokenizer
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  /**
   * Construct for specified input stream.
   */
  new make(InStream in)
  {
    this.in = in
    consume
    consume
  }

////////////////////////////////////////////////////////////////
// Access
////////////////////////////////////////////////////////////////

  /**
   * Read the next token from the stream.  The token is
   * available via the 'type' and 'val' fields.  The line
   * of the current token is available in 'line' field.
   * Return the 'type' field or -1 if at end of stream.
   */
  Int next()
  {
    if (undo != null) { undo.reset(this); undo = null; return type }
    val = null
    type = doNext
    //echo("next: ${Token.toString(type)} '$val'")
    return type
  }

  /**
   * Read the next token, set the 'val' field but return
   * type without worrying setting the 'type' field.
   */
  private Int doNext()
  {
    while (true)
    {
      // skip whitespace
      while (curt == SPACE) consume
      if (cur < 0) return Token.EOF

      // alpha means identifier
      if (curt == ALPHA) return id

      // number
      if (curt == DIGIT) return number(false)

      // symbol
      switch (cur)
      {
      case '+':   consume; return number(false)
      case '-':   consume; return number(true)
      case '"':   return str
      case '\'':  return ch
      case '`':   return uri
      case '(':   consume; return Token.LPAREN
      case ')':   consume; return Token.RPAREN
      case ',':   consume; return Token.COMMA
      case ';':   consume; return Token.SEMICOLON
      case '=':   consume; return Token.EQ
      case '{':   consume; return Token.LBRACE
      case '}':   consume; return Token.RBRACE
      case '#':   consume; return Token.POUND
      case '?':   consume; return Token.QUESTION
      case '@':   consume; return Token.AT
      case '$':   consume; return Token.DOLLAR
      case '.':
        if (peekt == DIGIT) return number(false)
        consume
        return Token.DOT
      case '[':
        consume
        if (cur == ']') { consume; return Token.LRBRACKET }
        return Token.LBRACKET
      case ']':
        consume
        return Token.RBRACKET
      case ':':
        consume
        if (cur == ':') { consume; return Token.DOUBLE_COLON }
        return Token.COLON
      case '*':
        if (peek == '*') { skipCommentSL; continue }
        break
      case '/':
        if (peek == '/') { skipCommentSL; continue }
        if (peek == '*') { skipCommentML; continue }
        break
      }

      // invalid character
      throw err("Unexpected symbol: " + cur.toChar + " (0x" + cur.toHex() + ")")
    }
    throw err("unreachable")
  }

//////////////////////////////////////////////////////////////////////////
// Word
//////////////////////////////////////////////////////////////////////////

  /**
   * Parse an identifier: alpha (alpha|number)*
   */
  private Int id()
  {
    s := StrBuf()
    Int first := cur
    while ((curt == ALPHA || curt == DIGIT) && cur > 0)
    {
      s.addChar(cur)
      consume
    }

    val := s.toStr
    switch (first)
    {
      case 'a':
        if (val.equals("as")) { return Token.AS }

      case 'f':
        if (val.equals("false")) { this.val = false; return Token.BOOL_LITERAL }

      case 'n':
        if (val.equals("null")) { this.val = null; return Token.NULL_LITERAL }

      case 't':
        if (val.equals("true")) { this.val = true; return Token.BOOL_LITERAL }

      case 'u':
        if (val.equals("using")) { return Token.USING }

    }

    this.val = val
    return Token.ID
  }

//////////////////////////////////////////////////////////////////////////
// Number
//////////////////////////////////////////////////////////////////////////

  private Int parseDuration() {
    dur := -1
    if (cur == 'n' && peek == 's') { consume; consume; dur = 1 }
    if (cur == 'm' && peek == 's') { consume; consume; dur = 1000000 }
    if (cur == 's' && peek == 'e') { consume; consume; if (cur != 'c') throw err("Expected 'sec' in Duration literal"); consume; dur = 1000000000 }
    if (cur == 'm' && peek == 'i') {
      consume; consume;
      if (cur != 'n') throw err("Expected 'min' in Duration literal");
      else consume;
      if (cur == 's') consume
      dur = 60000000000
    }
    if (cur == 'h' && peek == 'r') { consume; consume; dur = 3600000000000 }
    if (cur == 'd' && peek == 'a') { consume; consume; if (cur != 'y') throw err("Expected 'day' in Duration literal"); consume; dur = 86400000000000 }
    return dur
  }

  /**
   * Parse a number literal token.
   */
  private Int number(Bool neg)
  {
    // check for hex value
    if (cur == '0' && peek == 'x')
      return hex

    // read whole part
    StrBuf? s := null
    Int whole := 0
    Int wholeCount := 0
    while (curt == DIGIT)
    {
      if (s != null)
      {
        s.addChar(cur)
      }
      else
      {
        whole = whole*10 + (cur - '0')
        wholeCount++
        if (wholeCount >= 18) { s = StrBuf(32); if (neg) s.addChar('-'); s.add(whole) }
      }
      consume
      if (cur == '_') consume
    }

    // fraction part
    Bool floating := false
    if (cur == '.' && peekt == DIGIT)
    {
      floating = true
      if (s == null) { s = StrBuf(32); if (neg) s.addChar('-'); s.add(whole) }
      s.addChar('.')
      consume
      while (curt == DIGIT)
      {
        s.addChar(cur)
        consume
        if (cur == '_') consume
      }
    }

    // exponent
    if (cur == 'e' || cur == 'E')
    {
      floating = true
      if (s == null) { s = StrBuf(32); if (neg) s.addChar('-'); s.add(whole) }
      s.addChar('e')
      consume
      if (cur == '-' || cur == '+') { s.addChar(cur); consume }
      if (curt != DIGIT) throw err("Expected exponent digits")
      while (curt == DIGIT)
      {
        s.addChar(cur)
        consume
        if (cur == '_') consume
      }
    }

    // check for suffixes
    Bool floatSuffix  := false
    Bool decimalSuffix := false
    Int dur := -1
    if ('d' <= cur && cur <= 's')
    {
      dur = parseDuration()
    }
    if (cur == 'f' || cur == 'F')
    {
      consume
      floatSuffix = true
    }
    else if (cur == 'd' || cur == 'D')
    {
      consume
      decimalSuffix = true
    }
    if (dur == -1 && cur == '.' && 'd' <= peek && peek <= 's') {
      consume
      dur = parseDuration()
    }

    if (neg) whole = -whole

    try
    {
      // decimal literal
      if (decimalSuffix)
      {
        num := (s == null) ? Decimal.toDecimal(whole) : Decimal.fromStr(s.toStr)
        this.val = num
        return Token.DECIMAL_LITERAL
      }

      // Float literal (or duration)
      if (floatSuffix || floating)
      {
        Float num := (s == null) ? whole.toFloat : Float.fromStr(s.toStr)
        if (dur > 0)
        {
          this.val = Duration.fromNanos((num * dur).toInt)
          return Token.DURATION_LITERAL
        }
        else
        {
          this.val = num
          return Token.FLOAT_LITERAL
        }
      }

      // Int literal (or duration)
      Int num := (s == null) ? whole : Int.fromStr(s.toStr)
      if (dur > 0)
      {
        this.val = Duration.fromNanos(num*dur)
        return Token.DURATION_LITERAL
      }
      else
      {
        this.val = num
        return Token.INT_LITERAL
      }
    }
    catch (Err e)
    {
      throw err("Invalid numeric literal: " + s)
    }
  }

  /**
   * Process hex int/Int literal starting with 0x
   */
  Int hex()
  {
    consume // 0
    consume // x

    // read first hex
    Int type := Token.INT_LITERAL
    Int val := hexChar(cur)
    if (val < 0) throw err("Expecting hex number")
    consume
    Int nibCount := 1
    while (true)
    {
      Int nib := hexChar(cur)
      if (nib < 0)
      {
        if (cur == '_') { consume; continue }
        break
      }
      nibCount++
      if (nibCount > 16) throw err("Hex literal too big")
      val = (val.shiftl(4)) + nib
      consume
    }

    this.val = val
    return type
  }

  static Int hexChar(Int c)
  {
    if ('0' <= c && c <= '9') return c - '0'
    if ('a' <= c && c <= 'f') return c - 'a' + 10
    if ('A' <= c && c <= 'F') return c - 'A' + 10
    return -1
  }

//////////////////////////////////////////////////////////////////////////
// String
//////////////////////////////////////////////////////////////////////////

  /**
   * Parse a string literal token.
   */
  private Int str()
  {
    //if (cur != '"') throw err("cur not \"")
    consume  // opening quote
    StrBuf s := StrBuf()
    while (true)
    {
      switch (cur)
      {
      case '"':   consume; break
      case -1:  throw err("Unexpected end of string")
      case '$':   throw err("Interpolated strings unsupported")
      case '\\':  s.addChar(escape);
      case '\r':  s.addChar('\n'); consume;
      default:  s.addChar(cur); consume;
      }
    }
    this.val = s.toStr
    return Token.STR_LITERAL
  }

//////////////////////////////////////////////////////////////////////////
// Character
//////////////////////////////////////////////////////////////////////////

  /**
   * Parse a char literal token (as Int literal).
   */
  private Int ch()
  {
    // consume opening quote
    consume

    // if \ then process as escape
    Int c := 0
    if (cur == '\\')
    {
      c = escape
    }
    else
    {
      c = cur
      consume
    }

    // expecting ' quote
    if (cur != '\'') throw err("Expecting ' close of char literal")
    consume

    this.val = c
    return Token.INT_LITERAL
  }

  /**
   * Parse an escapse sequence which starts with a \
   */
  Int escape()
  {
    // consume slash
    if (cur != '\\') throw err("Internal error")
    consume

    // check basics
    switch (cur)
    {
      case 'b':   consume; return '\b'
      case 'f':   consume; return '\f'
      case 'n':   consume; return '\n'
      case 'r':   consume; return '\r'
      case 't':   consume; return '\t'
      case '$':   consume; return '$'
      case '"':   consume; return '"'
      case '\'':  consume; return '\''
      case '`':   consume; return '`'
      case '\\':  consume; return '\\'
    }

    // check for uxxxx
    if (cur == 'u')
    {
      consume
      Int n3 := hexChar(cur); consume
      Int n2 := hexChar(cur); consume
      Int n1 := hexChar(cur); consume
      Int n0 := hexChar(cur); consume
      if (n3 < 0 || n2 < 0 || n1 < 0 || n0 < 0) throw err("Invalid hex value for \\uxxxx")
      return (n3.shiftl(12)).or(n2.shiftl(8)).or(n1.shiftl(4)).or(n0)
    }

    throw err("Invalid escape sequence")
  }

//////////////////////////////////////////////////////////////////////////
// Uri
//////////////////////////////////////////////////////////////////////////

  /**
   * Parse a uri literal token.
   */
  private Int uri()
  {
    // consume opening tick
    consume

    // store starting position
    StrBuf s := StrBuf()

    // loop until we find end of string
    while (true)
    {
      if (cur < 0) throw err("Unexpected end of uri")
      if (cur == '\\')
      {
        s.addChar(escape)
      }
      else
      {
        if (cur == '`') { consume; break }
        s.addChar(cur)
        consume
      }
    }

    this.val = Uri.fromStr(s.toStr)
    return Token.URI_LITERAL
  }

//////////////////////////////////////////////////////////////////////////
// Comments
//////////////////////////////////////////////////////////////////////////

  /**
   * Skip a single line // comment
   */
  private Token? skipCommentSL()
  {
    consume // first slash
    consume // next slash
    while (true)
    {
      if (cur == '\n' || cur == '\r') { consume; break }
      if (cur < 0) break
      consume
    }
    return null
  }

  /**
   * Skip a multi line /'*' comment.  Note unlike C/Java,
   * slash/star comments can be nested.
   */
  private Token? skipCommentML()
  {
    consume // first slash
    consume // next slash
    Int depth := 1
    while (true)
    {
      if (cur == '*' && peek == '/') { consume; consume; depth--; if (depth <= 0) break }
      if (cur == '/' && peek == '*') { consume; consume; depth++; continue }
      if (cur < 0) break
      consume
    }
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  /**
   * Return a IOErr for current location in source.
   */
  Err err(Str msg)
  {
    //return ObjDecoder.err(msg, line)
    return IOErr(msg + " [Line " + line + "]")
  }

////////////////////////////////////////////////////////////////
// Read
////////////////////////////////////////////////////////////////

  /**
   * Consume the cur char and advance to next char in buffer:
   *  - updates cur, curt, peek, and peekt fields
   *  - updates the line and col count
   *  - end of file, sets fields to 0
   */
  private Void consume()
  {
    // check for newline
    if (cur == '\n' || cur == '\r') line++

    // get the next character from the
    // stream normalize \r\n newlines
    Int c := in.readChar
    if (c == '\n' && peek == '\r') c = in.readChar

    // roll cur to peek, and peek to char
    cur   = peek
    curt  = peekt
    peek  = c
    //echo("$charMap $c")
    peekt = 0 < c && c < 128 ? charMap[c] : ALPHA
  }

////////////////////////////////////////////////////////////////
// Char Map
////////////////////////////////////////////////////////////////

  private static const Int SPACE := 1
  private static const Int ALPHA := 2
  private static const Int DIGIT := 3

  private static const Int[] charMap
  static {
    //Int[] cmap := List<Int>.make(128)
    //cmap.size = 128
    cmap := Int[,].fill(0, 128)
    // space characters note \r is error in symbol
    cmap[' ']  = SPACE
    cmap['\n'] = SPACE
    cmap['\r'] = SPACE
    cmap['\t'] = SPACE

    // alpha characters
    for (Int i:='a'; i<='z'; ++i) cmap[i] = ALPHA
    for (Int i:='A'; i<='Z'; ++i) cmap[i] = ALPHA
    cmap['_'] = ALPHA

    // digit characters
    for (Int i:='0'; i<='9'; ++i) cmap[i] = DIGIT
    charMap = cmap
  }

//////////////////////////////////////////////////////////////////////////
// Undo
//////////////////////////////////////////////////////////////////////////

  /**
   * Pushback a token which will be the next read.
   */
  Void pushUndo(Int type, Obj? val, Int line)
  {
    if (undo != null) throw Err("only one pushback supported")
    undo = Undo(type, val, line)
  }

  /**
   * Reset the current token state.
   */
  Int reset(Int type, Obj? val, Int line)
  {
    this.type = type
    this.val  = val
    this.line = line
    return type
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private InStream in        // input stream
  Int type := -1     // current Token type constant
  Obj? val           // Str for id, Obj for literal
  Int line := 1       // current line number
  private Undo? undo         // if we've pushed back a token
  private Int cur := -1      // current char
  private Int curt := -1     // current charMap type
  private Int peek := -1     // next char
  private Int peekt := -1    // next charMap type

}

internal class Undo {
  new make(Int t, Obj? v, Int l)  { type = t; val = v; line = l }
  Void reset(Tokenizer t) { t.reset(type, val, line) }
  Int type
  Obj? val
  Int line
}