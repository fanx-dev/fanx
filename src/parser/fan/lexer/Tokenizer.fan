//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    3 Sep 05  Brian Frank  Creation
//   18 May 06  Brian Frank  Ported from Java to Fan
//

**
** Tokenizer inputs a Str and output a list of Tokens
**
class Tokenizer
{
  CompilerLog log
//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with characters of source file.  The buffer
  ** passed must be normalized in that all newlines must be
  ** represented strictly as \n and not \r or \r\n (see
  ** File.readAllStr).  If isDoc is false, we skip all star-star
  ** Fandoc comments.
  **
  new make(CompilerLog log, Loc loc, Str buf, Bool isDoc, Bool isComment, Bool paseStrInterpolation := true)
  {
    this.log = log
    this.buf      = buf
    this.filename = loc.file
    this.isDoc    = isDoc
    this.isComment= isComment
    this.paseStrInterpolation = paseStrInterpolation
    
    this.tokens   = TokenVal[,]
    this.inStrLiteral = false
    this.posOfLine = 0
    this.whitespace = false

    // initialize cur and peek
    cur = peek = ' '
    if (buf.size > 0) cur  = buf[0]
    if (buf.size > 1) peek = buf[1]
    pos = 0

    // if first line starts with #, then treat it like an end of
    // line, so that Unix guys can specify the executable to run
    if (cur == '#')
    {
      while (true)
      {
        if (cur == '\n') { consume; break }
        if (cur == 0) break
        consume
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Tokenize the entire input into a list of tokens.
  **
  TokenVal[] tokenize()
  {
    while (true)
    {
      tok := next
      tokens.add(tok)
      if (tok.kind === Token.eof) break
    }
    return tokens
  }

  **
  ** Return the next token in the buffer.
  **
  TokenVal? next()
  {
    while (true)
    {
      // save current line
      curLine = this.line
      col := this.col
      offset := pos

      // find next token
      TokenVal? tok
      try {
        tok = find
        if (tok == null) continue
      }
      catch (CompilerErr e) {
        continue
      }
      
      // fill in token's location
      tok.loc = Loc.make(filename, curLine, col, offset)
      tok.len = this.pos - offset
      tok.newline = lastLine < line
      tok.whitespace = whitespace

      // save last line, clear whitespace flag
      lastLine = line
      whitespace = false

      return tok
    }
    return null // TODO - shouldn't need this
  }

  **
  ** Find the next token or return null.
  **
  private TokenVal? find()
  {
    // skip whitespace
    if (cur.isSpace) { consume; whitespace = true; return null }

    // alpha means keyword or identifier
    if (isIdentifierStart(cur)) return word

    // number or .number (note that + and - are handled as unary operator)
    if (cur.isDigit) return number
    if (cur == '.' && peek.isDigit) return number

    // str literal
    if (cur == '"' && peek == '"' && peekPeek == '"') return quoted(Quoted.triple)
    if (cur == '"') return quoted(Quoted.normal)
    if (cur == '`') return quoted(Quoted.uri)
    if (cur == '\'') return ch

    // comments
    if (cur == '*' && peek == '*') return docComment
    if (cur == '/' && peek == '/') return readCommentSL
    if (cur == '/' && peek == '*') return readCommentML

    // DSL
    if (cur == '<' && peek == '|') return dsl

    // symbols
    return symbol
  }

//////////////////////////////////////////////////////////////////////////
// Word
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a word token: alpha (alpha|number)*
  ** Words are either keywords or identifiers
  **
  private TokenVal word()
  {
    // store starting position of word
    start := pos

    // find end of word to compute length
    while (cur.isAlphaNum || cur == '_') consume

    // create Str (gc note this string might now reference buf)
    word := buf[start..<pos]

    // check keywords
    keyword := Token.keywords[word]
    if (keyword != null)
      return TokenVal(keyword)

    // otherwise this is a normal identifier
    return TokenVal(Token.identifier, word)
  }

  private static Bool isIdentifierStart(Int c) { c.isAlpha || c == '_' }

//////////////////////////////////////////////////////////////////////////
// Number
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a number literal token: int, float, decimal, or duration.
  **
  private TokenVal number()
  {
    // check for hex value
    if (cur == '0' && peek == 'x')
      return hex

    // find end of literal
    start := pos
    dot   := false
    exp   := false

    // whole part
    while (cur.isDigit || cur == '_') consume

    // fraction part
    if (cur == '.' && peek.isDigit)
    {
      dot = true
      consume
      while (cur.isDigit || cur == '_') consume
    }

    // exponent
    if (cur == 'e' || cur == 'E')
    {
      consume
      exp = true
      if (cur == '-' || cur == '+') consume
      if (!cur.isDigit) throw err("Expected exponent digits")
      while (cur.isDigit || cur == '_') consume
    }

    // string value of literal
    str := buf[start..<pos].replace("_", "")

    // check for suffixes
    floatSuffix   := false
    decimalSuffix := false
    Int? dur      := null
    if (cur.isLower && peek.isLower)
    {
      //if (cur == 'n' && peek == 's') { consume; consume; dur = 1 }
      if (cur == 'm' && peek == 's') { consume; consume; dur = 1000000 }
      if (cur == 's' && peek == 'e') { consume; consume; if (cur != 'c') throw err("Expected 'sec' in Duration literal"); consume; dur = 1_000_000_000 }
      if (cur == 'm' && peek == 'i') { consume; consume; if (cur != 'n') throw err("Expected 'min' in Duration literal"); consume; dur = 60_000_000_000 }
      if (cur == 'h' && peek == 'r') { consume; consume; dur = 3_600_000_000_000 }
      if (cur == 'd' && peek == 'a') { consume; consume; if (cur != 'y') throw err("Expected 'day' in Duration literal"); consume; dur = 86_400_000_000_000 }
    }
    else if (cur == 'f' || cur == 'F')
    {
      consume
      floatSuffix = true
    }
    else if (cur == 'd' || cur == 'D')
    {
      consume
      decimalSuffix = true
    }

    try
    {
      // decimal literal
      if (decimalSuffix) {
        num := Decimal.fromStr(str)
        return TokenVal(Token.decimalLiteral, num)
      }

      // float literal
      if (floatSuffix || dot || exp)
      {
        num := Float.fromStr(str)
        if (dur != null) {
          return TokenVal(Token.durationLiteral, Duration.fromNanos((num*dur.toFloat).toInt))
        }
        else {
          return TokenVal(Token.floatLiteral, num)
        }
      }

      // int literal
      num := Int.fromStr(str)
      if (dur != null)
        return TokenVal(Token.durationLiteral, Duration.fromNanos(num*dur))
      else
        return TokenVal(Token.intLiteral, num)
    }
    catch (ParseErr e)
    {
      throw err("Invalid numeric literal '$str'")
    }
  }

  **
  ** Process hex int/long literal starting with 0x
  **
  TokenVal hex()
  {
    consume // 0
    consume // x

    // read first hex
    val := cur.fromDigit(16)
    if (val == null) throw err("Expecting hex number")
    consume
    Int nibCount := 1
    while (true)
    {
      nib := cur.fromDigit(16)
      if (nib == null)
      {
        if (cur == '_') { consume; continue }
        break
      }
      nibCount++
      if (nibCount > 16) throw err("Hex literal too big")
      val = val.shiftl(4) + nib;
      consume
    }

    return TokenVal(Token.intLiteral, val)
  }

//////////////////////////////////////////////////////////////////////////
// Quoted Literals
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a quoted literal token: normal, triple, or uri
  ** Opening quote must already be consumed.
  **
  private TokenVal? quoted(Quoted q)
  {
    inStrLiteral = true
    try
    {
      // opening quote
      line := this.line
      col := this.col
      offset := this.pos
      consume
      if (q.isTriple) { consume; consume }

      // init starting position
      openLine := posOfLine
      openPos  := pos
      multiLineOk := true
      s := StrBuf()
      interpolated := false

      // loop until we find end of string
      while (true)
      {
        if (cur == 0) throw err("Unexpected end of $q")

        if (endOfQuoted(q)) break

        if (cur == '\n')
        {
          if (!q.multiLine) throw err("Unexpected end of $q")
          s.addChar(cur)
          consume
          if (multiLineOk) multiLineOk = skipStrWs(openLine, openPos)
          continue
        }

        if (cur == '$' && paseStrInterpolation)
        {
          // if we have detected an interpolated string, then
          // insert opening paren to treat whole string atomically
          if (!interpolated)
          {
            interpolated = true
            tokens.add(makeVirtualToken(line, col, offset, Token.lparenSynthetic, null))
          }

          // process interpolated string, it returns null
          // if at end of string literal
          if (!interpolation(line, col, offset, s.toStr, q))
          {
            line = this.line; col = this.col - 1;  // before quote
            offset = this.pos -1
            tokens.add(makeVirtualToken(line, col, offset, Token.rparen, null))
            if (q.isUri)
            {
              tokens.add(makeVirtualToken(line, col, offset, Token.dot))
              tokens.add(makeVirtualToken(line, col, offset, Token.identifier, "toUri"))
            }
            return null
          }
          line = this.line; col = this.col; offset = this.pos

          s.clear
        }
        else if (cur == '\\')
        {
          if (q.isUri)
          {
            switch (peek)
            {
              case ':': case '/': case '?': case '#':
              case '[': case ']': case '@': case '\\':
              case '&': case '=': case ';':
                s.addChar(cur).addChar(peek)
                consume
                consume
              default:
                s.addChar(escape)
            }
          }
          else
          {
            s.addChar(escape)
          }
        }
        else
        {
          s.addChar(cur)
          consume
        }
      }

      // if interpolated then we add rparen to treat whole atomically,
      // and if URI, then add call to Uri
      if (interpolated)
      {
        tokens.add(makeVirtualToken(line, col, offset, Token.strLiteral, s.toStr))
        line = this.line; col = this.col - 1;  // before quote
        tokens.add(makeVirtualToken(line, col, offset, Token.rparen, null))
        if (q.isUri)
        {
          tokens.add(makeVirtualToken(line, col, offset, Token.dot, null))
          tokens.add(makeVirtualToken(line, col, offset, Token.identifier, "toUri"))
        }
        return null
      }
      else
      {
        if (q.isUri)
          return TokenVal(Token.uriLiteral, s.toStr)
        else
          return TokenVal(Token.strLiteral, s.toStr)
      }
    }
    finally
    {
      inStrLiteral = false
    }
  }

  **
  ** Leading white space in a multi-line string is assumed
  ** to be outside of the string literal.  If there is an
  ** non-whitespace char, then it is an compile time error.
  ** Return true if ok, false on error.
  **
  private Bool skipStrWs(Int openLine, Int openPos)
  {
    for (i:=openLine; i<openPos; ++i)
    {
      a := buf[i]
      if ((a == '\t' && cur != '\t') || (a != '\t' && cur != ' '))
      {
        if (cur == '\n') return true
        numTabs := 0; numSpaces := 0
        for (j:=openLine; j<openPos; ++j)
          { if (buf[j] == '\t') ++numTabs; else ++numSpaces }
        if (numTabs == 0)
          err("Leading space in multi-line Str must be $numSpaces spaces")
        else
          err("Leading space in multi-line Str must be $numTabs tabs and $numSpaces spaces")
        return false
      }
      consume
    }
    return true
  }

  **
  ** When we hit a $ inside a string it indicates an embedded
  ** expression.  We make this look like a stream of tokens
  ** such that:
  **   "a ${b} c" -> "a " + b + " c"
  **   "a $<b> c" -> "a " + LocaleExpr("b") + " c"
  ** Return true if more in the string literal.
  **
  private Bool interpolation(Int line, Int col, Int offset, Str s, Quoted q)
  {
    consume // $
    tokens.add(makeVirtualToken(line, col, offset, Token.strLiteral, s))
    line = this.line; col = this.col; offset = this.pos
    tokens.add(makeVirtualToken(line, col, offset, Token.plus))

    // if { we allow an expression b/w {...}
    if (cur == '{')
    {
      line = this.line; col = this.col; offset = this.pos
      tokens.add(makeVirtualToken(line, col, offset, Token.lparenSynthetic))
      consume
      while (true)
      {
        if (endOfQuoted(q) || cur == 0) throw err("Unexpected end of $q, missing }")
        tok := next
        if (tok.kind === Token.strLiteral) throw err("Cannot nest Str literal within interpolation", tok.loc)
        if (tok.kind === Token.uriLiteral) throw err("Cannot nest Uri literal within interpolation", tok.loc)
        if (tok.kind === Token.rbrace) break
        tokens.add(tok)
      }
      line = this.line; col = this.col; offset = this.pos
      tokens.add(makeVirtualToken(line, col, offset, Token.rparen))
    }

    // if < this is a localized literal <xxxx>
    else if (cur == '<')
    {
      line = this.line; col = this.col; offset = this.pos
      tokens.add(makeVirtualToken(line, col, offset, Token.lparenSynthetic))
      consume
      buf := StrBuf()
      while (true)
      {
        if (endOfQuoted(q) || cur == 0) throw err("Unexpected end of $q, missing >")
        if (cur == '\n') throw err("Unexpected newline, missing >")
        if (cur == '>') break
        buf.addChar(cur)
        consume
      }
      consume

      tok := TokenVal(Token.localeLiteral, buf.toStr)
      tok.loc = Loc.make(filename, line, col, offset)
      tok.len = this.pos - offset
      tokens.add(tok)

      line = this.line; col = this.col; offset = this.pos
      tokens.add(makeVirtualToken(line, col, offset, Token.rparen))
    }

    // else also allow a single identifier with
    // dotted accessors x, x.y, x.y.z
    else
    {
      tok := next
      if (tok.kind !== Token.identifier &&
          tok.kind !== Token.thisKeyword &&
          tok.kind !== Token.superKeyword &&
          tok.kind !== Token.itKeyword)
        throw err("Expected identifier after \$ but $tok")
      tokens.add(tok)
      while (true)
      {
        if (cur != '.') break
        if (!isIdentifierStart(peek)) throw err("Expected identifier after dot")
        tokens.add(next) // dot
        tok = next
        tokens.add(tok)
      }
    }

    // if at end of string, all done
    if (endOfQuoted(q)) return false

    // add plus and return true to keep chugging
    line = this.line; col = this.col; offset = this.pos
    tokens.add(makeVirtualToken(line, col, offset, Token.plus))
    return true
  }

  **
  ** If at end of quoted literal consume the
  ** ending token(s) and return true.
  **
  private Bool endOfQuoted(Quoted q)
  {
    switch (q)
    {
      case Quoted.normal:
        if (cur != '"') return false
        consume; return true

      case Quoted.triple:
        if (cur != '"' || peek != '"' || peekPeek != '"') return false
        consume; consume; consume; return true

      case Quoted.uri:
        if (cur != '`') return false
        consume; return true

      default:
        throw err(q.toStr)
    }
  }

  **
  ** Create a virtual token for string interpolation.
  **
  private TokenVal makeVirtualToken(Int line, Int col, Int offset, Token kind, Obj? value := null)
  {
    tok := TokenVal(kind, value)
    tok.loc = Loc.make(filename, line, col, offset)
    tok.len = this.pos - offset
    return tok
  }

//////////////////////////////////////////////////////////////////////////
// Char
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a char literal token.
  **
  private TokenVal ch()
  {
    // consume opening quote
    consume

    // if \ then process as escape
    c := -1
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

    return TokenVal(Token.intLiteral, c)
  }

  **
  ** Parse an escapse sequence which starts with a \
  **
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
      case '"':   consume; return '"'
      case '$':   consume; return '$'
      case '\'':  consume; return '\''
      case '`':   consume; return '`'
      case '\\':  consume; return '\\'
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

//////////////////////////////////////////////////////////////////////////
// DSL
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a domain specific language <| ... |>
  **
  private TokenVal dsl()
  {
    consume // <
    consume // |

    // compute leading tabs/spaces
    leadingTabs := 0
    leadingSpaces := 0
    for (i:=posOfLine; i<pos; ++i)
      if (buf[i] == '\t') leadingTabs++; else leadingSpaces++

    // loop until we find end of DSL
    s := StrBuf()
    while (true)
    {
      if (cur == '|' && peek == '>') break
      if (cur == 0) throw err("Unexpected end of DSL")
      s.addChar(cur)
      consume
    }

    consume // |
    consume // >

    return TokenValDsl(Token.dsl, s.toStr, leadingTabs, leadingSpaces)
  }

//////////////////////////////////////////////////////////////////////////
// Comments
//////////////////////////////////////////////////////////////////////////

  //code from F4 IDE
  
  **
  ** Skip a single line // comment
  **
  private TokenVal? readCommentSL()
  {
    start := pos
    end := start
    line := this.line
    consume  // first slash
    consume  // next slash
    s := StrBuf()
    while (true)
    {
      if (cur == '\n') { end = pos - 1; consume; break }
      if (cur == 0) { end = pos; break }
      s.addChar(cur)
      consume
    }
    if (isComment) {
      return TokenVal(Token.slComment, s.toStr)
    }
    return null
  }

  **
  ** Skip a multi line /* comment.  Note unlike C/Java,
  ** slash/star comments can be nested.
  **
  private TokenVal? readCommentML()
  {
    start := pos
    end := start
    line := this.line
    consume   // first slash
    consume   // next slash
    depth := 1
    s := StrBuf()
    while (true)
    {
      if (cur == '*' && peek == '/') {
        consume;
        consume;
        depth--;
        if (depth <= 0) {
          end = pos - 1
          break
        }
      }
      if (cur == '/' && peek == '*') { consume; consume; depth++; continue }
      if (cur == 0) break
      s.addChar(cur)
      consume
    }
    if (isComment) {
      return TokenVal(Token.mlComment, s.toStr)
    }
    return null
  }

  **
  ** Parse a Javadoc style comment into a documentation comment token.
  **
  private TokenVal? docComment()
  {
    // if doc is off, then just skip the line and be done
    if (!isDoc) { readCommentSL; return null }

    while (cur == '*') consume
    if (cur == ' ') consume

    // parse comment
    lines := Str[,]
    s := StrBuf()
    while (cur > 0)
    {
      // add to buffer and advance
      c := cur
      consume

      // if not at newline, then loop
      if (c != '\n')
      {
        s.addChar(c)
        continue
      }

      // add line and reset buffer
      // if leading empty lines then skip them and update this.curLine to
      // ensure location starts at first non-empty line
      line := s.toStr
      if (!lines.isEmpty || !line.trim.isEmpty) lines.add(line)
      else this.curLine++
      s.clear

      // we at a newline, check for leading whitespace(0+)/star(2+)/whitespace(1)
      while (cur == ' ' || cur == '\t') consume
      if (cur != '*' || peek != '*') break
      while (cur == '*') consume
      if (cur == ' ' || cur == '\t') consume
    }
    lines.add(s.toStr)

    // strip trailing empty lines
    while (!lines.isEmpty)
      if (lines.last.trim.isEmpty) lines.removeAt(-1)
      else break

    return TokenVal(Token.docComment, lines)
  }

//////////////////////////////////////////////////////////////////////////
// Symbol
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a symbol token (typically into an operator).
  **
  private TokenVal symbol()
  {
    c := cur
    consume
    switch (c)
    {
      case '\r':
        throw err("Carriage return \\r not allowed in source")
      case '!':
        if (cur == '=')
        {
          consume
          if (cur == '=') { consume; return TokenVal(Token.notSame) }
          return TokenVal(Token.notEq)
        }
        return TokenVal(Token.bang)
      case '#':
        return TokenVal(Token.pound)
      case '%':
        if (cur == '=') { consume; return TokenVal(Token.assignPercent) }
        return TokenVal(Token.percent)
      case '&':
        if (cur == '&') { consume; return TokenVal(Token.doubleAmp) }
        return TokenVal(Token.amp)
      case '(':
        return TokenVal(Token.lparen)
      case ')':
        return TokenVal(Token.rparen)
      case '*':
        if (cur == '=') { consume; return TokenVal(Token.assignStar) }
        return TokenVal(Token.star)
      case '+':
        if (cur == '=') { consume; return TokenVal(Token.assignPlus) }
        if (cur == '+') { consume; return TokenVal(Token.increment) }
        return TokenVal(Token.plus)
      case ',':
        return TokenVal(Token.comma)
      case '-':
        if (cur == '>') { consume; return TokenVal(Token.arrow) }
        if (cur == '-') { consume; return TokenVal(Token.decrement) }
        if (cur == '=') { consume; return TokenVal(Token.assignMinus) }
        return TokenVal(Token.minus)
      case '.':
        if (cur == '.')
        {
          consume
          if (cur == '<') { consume; return TokenVal(Token.dotDotLt) }
          return TokenVal(Token.dotDot)
        }
        return TokenVal(Token.dot)
      case '/':
        if (cur == '=') { consume; return TokenVal(Token.assignSlash) }
        return TokenVal(Token.slash)
      case ':':
        if (cur == ':') { consume; return TokenVal(Token.doubleColon) }
        if (cur == '=') { consume; return TokenVal(Token.defAssign) }
        return TokenVal(Token.colon)
      case ';':
        return TokenVal(Token.semicolon)
      case '<':
        if (cur == '=')
        {
          consume
          if (cur == '>') { consume; return TokenVal(Token.cmp) }
          return TokenVal(Token.ltEq)
        }
        return TokenVal(Token.lt)
      case '=':
        if (cur == '=')
        {
          consume
          if (cur == '=') { consume; return TokenVal(Token.same) }
          return TokenVal(Token.eq)
        }
        return TokenVal(Token.assign)
      case '>':
        if (cur == '=') { consume; return TokenVal(Token.gtEq) }
        return TokenVal(Token.gt)
      case '?':
        if (cur == ':') { consume; return TokenVal(Token.elvis) }
        if (cur == '.') { consume; return TokenVal(Token.safeDot) }
        if (cur == '-' && peek == '>') { consume; consume; return TokenVal(Token.safeArrow) }
        if (cur == '~' && peek == '>') { consume; consume; return TokenVal(Token.safeTildeArrow) }
        return TokenVal(Token.question)
      case '@':
        return TokenVal(Token.at)
      case '[':
        return TokenVal(Token.lbracket)
      case ']':
        return TokenVal(Token.rbracket)
      case '^':
        return TokenVal(Token.caret)
      case '{':
        return TokenVal(Token.lbrace)
      case '|':
        if (cur == '|') { consume; return TokenVal(Token.doublePipe) }
        return TokenVal(Token.pipe)
      case '}':
        return TokenVal(Token.rbrace)
      case '~':
        if (cur == '>') { consume; return TokenVal(Token.tildeArrow) }
        return TokenVal(Token.tilde)
      case '$':
        return TokenVal(Token.dollar)
    }

    if (c == 0)
      return TokenVal(Token.eof)

    throw err("Unexpected symbol: " + c.toChar + " (0x" + c.toHex + ")")
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Return a CompilerException for current location in source.
  **
  CompilerErr err(Str msg, Loc? loc := null)
  {
    if (loc == null) loc = Loc(filename, line, col, pos)
    return log.err(msg, loc);
  }

////////////////////////////////////////////////////////////////
// Consume
////////////////////////////////////////////////////////////////

  **
  ** Peek at the character after peek
  **
  private Int peekPeek()
  {
    pos+2 < buf.size ? buf[pos+2] : 0
  }

  **
  ** Consume the cur char and advance to next char in buffer:
  **  - updates cur and peek fields
  **  - updates the line and col count
  **  - end of file, sets fields to 0
  **
  private Void consume()
  {
    // if cur is a line break, then advance line number,
    // because the char we are getting ready to make cur
    // is the first char on the next line
    if (cur == '\n')
    {
      line++
      col = 1
      posOfLine = pos+1
    }
    else
    {
      col++
    }

    // get the next character from the buffer, any
    // problems mean that we have read past the end
    cur = peek
    pos++
    if (pos+1 < buf.size)
      peek = buf[pos+1] // next peek is cur+1
    else
      peek = 0
  }

//////////////////////////////////////////////////////////////////////////
// Test
//////////////////////////////////////////////////////////////////////////

  /*
  static Void main()
  {
    t1 := Duration.now
    files := File(`/dev/fan/src/testSys/fan/`).list
    files.each |File f|
    {
      tok := Tokenizer(null, Loc(f.name), f.readAllStr, false).tokenize
      echo("-- " + f + " [" + tok.size + "]")
    }
    t2 := Duration.now
    echo("Time: " + (t2-t1).toMillis)
    echo("Time: " + (t2-t1))
  }
  */

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Str buf           // buffer
  private Int pos           // index into buf for cur
  private Bool isDoc        // return documentation comments or if false ignore them
  private Bool isComment
  private Str filename      // source file name
  private Int line := 1     // pos line number
  private Int col := 1      // pos column number
  private Int curLine       // line number of current token
  private Int cur           // current char
  private Int peek          // next char
  private Int lastLine      // line number of last token returned from next()
  private Int posOfLine     // index into buf for start of current line
  private TokenVal[] tokens // token accumulator
  private Bool inStrLiteral // return if inside a string literal token
  private Bool whitespace   // was there whitespace before current token
  private Bool paseStrInterpolation
}

**************************************************************************
** Quoted
**************************************************************************

internal enum class Quoted
{
  normal("Str literal", true),
  triple("Str literal", true),
  uri("Uri literal", false)

  Bool isUri() { this === uri }
  Bool isTriple() { this === triple }

  private new make(Str s, Bool ml) { toStr = s; multiLine = ml }

  const override Str toStr
  const Bool multiLine
}