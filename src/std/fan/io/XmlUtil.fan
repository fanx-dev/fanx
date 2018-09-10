//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

@NoDoc
class XmlUtil
{
  **
  ** Write a string to this output stream using XML escape sequences.
  ** By default only the '< > &' characters are escaped. You can
  ** use the following flags to escape additional characters:
  **   - `xmlEscNewlines`: escape the '\n' and '\r' characters
  **   - `xmlEscQuotes`: escape the single and double quote characters
  **   - `xmlEscUnicode`: escape any character greater than 0x7f
  **
  ** Any control character less than 0x20 which is not '\t', '\n' or
  ** '\r' is always escaped with a numeric reference.  Return this.
  **
  static extension OutStream writeXml(OutStream out, Str s, Int mask := 0) {
    Bool escNewlines  := mask.and(xmlEscNewlines) != 0
    Bool escQuotes  := mask.and(xmlEscQuotes) != 0
    Bool escUnicode   := mask.and(xmlEscUnicode) != 0
    Int len := s.size
    Str hex := "0123456789abcdef"

    for (Int i:=0; i<len; ++i)
    {
      ch := s.get(i)
      switch (ch)
      {
        // table switch on control chars
        case  0: case  1: case  2: case  3: case  4: case  5: case  6:
        case  7: case  8: /*case  9: case 10:*/ case 11: case 12: /*case 13:*/
        case 14: case 15: case 16: case 17: case 18: case 19: case 20:
        case 21: case 22: case 23: case 24: case 25: case 26: case 27:
        case 28: case 29: case 30: case 31:
          writeXmlEsc(out, ch)
          //break

        // newlines
        case '\n': case '\r':
          if (!escNewlines) out.writeChar(ch)
          else writeXmlEsc(out, ch)
          //break

        // space
        case ' ':
          out.writeChar(' ')
          //break

        // table switch on common ASCII chars
        case '!': case '#': case '$': case '%': case '(': case ')': case '*':
        case '+': case ',': case '-': case '.': case '/': case '0': case '1':
        case '2': case '3': case '4': case '5': case '6': case '7': case '8':
        case '9': case ':': case ';': case '=': case '?': case '@': case 'A':
        case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H':
        case 'I': case 'J': case 'K': case 'L': case 'M': case 'N': case 'O':
        case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U': case 'V':
        case 'W': case 'X': case 'Y': case 'Z': case '[': case '\\': case ']':
        case '^': case '_': case '`': case 'a': case 'b': case 'c': case 'd':
        case 'e': case 'f': case 'g': case 'h': case 'i': case 'j': case 'k':
        case 'l': case 'm': case 'n': case 'o': case 'p': case 'q': case 'r':
        case 's': case 't': case 'u': case 'v': case 'w': case 'x': case 'y':
        case 'z': case '{': case '|': case '}': case '~':
          out.writeChar(ch)
          //break

        // XML control characters
        case '<':
          out.writeChar('&').writeChar('l').writeChar('t').writeChar(';')
          //break
        case '>':
          if (i > 0 && s.get(i-1) != ']') out.writeChar('>')
          else out.writeChar('&').writeChar('g').writeChar('t').writeChar(';')
          //break
        case '&':
          out.writeChar('&').writeChar('a').writeChar('m').writeChar('p').writeChar(';')
          //break
        case '"':
          if (!escQuotes) out.writeChar(ch)
          else out.writeChar('&').writeChar('q').writeChar('u').writeChar('o').writeChar('t').writeChar(';')
          //break
        case '\'':
          if (!escQuotes) out.writeChar(ch)
          else out.writeChar('&').writeChar('#').writeChar('3').writeChar('9').writeChar(';')
          //break

        // default
        default:
          if (ch <= 0xf7 || !escUnicode)
            out.writeChar(ch)
          else
            writeXmlEsc(out, ch)
      }
    }
    return out
  }

  private static Void writeXmlEsc(OutStream out, Int ch)
  {
    enc := out.charset
    Str hex := "0123456789abcdef"

    enc.encode('&', out)
    enc.encode('#', out)
    enc.encode('x', out)
    if (ch > 0xff)
    {
      enc.encode(hex.get(ch.shiftr(12).and(0xf)), out)
      enc.encode(hex.get(ch.shiftr(8).and(0xf)), out)
    }
    enc.encode(hex.get(ch.shiftr(4).and(0xf)), out)
    enc.encode(hex.get(ch.and(0xf)), out)
    enc.encode(';', out)
  }

  ** XML escape newline characters.  See `writeXml`.
  static const Int xmlEscNewlines := 0x01

  ** XML escape single and double quotes.  See `writeXml`.
  static const Int xmlEscQuotes := 0x02

  ** XML escape any character greater then 0x7f.  See `writeXml`.
  static const Int xmlEscUnicode := 0x04
}

