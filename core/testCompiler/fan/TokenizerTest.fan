//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    3 Sep 05  Brian Frank  Creation
//   31 May 06  Brian Frank  Ported from Java to Fan
//

using compiler

**
** TokenizerTest
**
class TokenizerTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Location
//////////////////////////////////////////////////////////////////////////

  Void testLo()
  {
    verifyEq(Loc("foo"), Loc("foo"))
    verifyEq(Loc("foo", 4), Loc("foo", 4))
    verifyEq(Loc("foo", 4, 6), Loc("foo", 4, 6))

    verifyNotEq(Loc("foo"), Loc("bar"))
    verifyNotEq(Loc("foo", 4), Loc("foo", 5))
    verifyNotEq(Loc("foo", 4, 6), Loc("foo", 4, 4))

    verify(Loc("foo") <= Loc("foo"))
    verify(Loc("foo", 5) <= Loc("foo", 5))
    verify(Loc("foo", 5, 7) >= Loc("foo", 5, 7))

    verify(Loc("foo") > Loc("bar"))
    verify(Loc("bar") < Loc("foo"))
    verify(Loc("foo", 10) > Loc("foo", 6))
    verify(Loc("foo", 99, 2) > Loc("foo", 9, 100))
    verify(Loc("foo", 5, 2) < Loc("foo", 5, 10))
  }

//////////////////////////////////////////////////////////////////////////
// Empty
//////////////////////////////////////////////////////////////////////////

  Void testEmpty()
  {
    // empty source
    verifyTokens("",         TokenVal[,])
    verifyTokens(" ",        TokenVal[,])
    verifyTokens("\n",       TokenVal[,])
    verifyTokens(" \n \n",   TokenVal[,])
    verifyTokens("# etc\n",  TokenVal[,])
  }

//////////////////////////////////////////////////////////////////////////
// Id
//////////////////////////////////////////////////////////////////////////

  Void testId()
  {
    // single tokens
    verifyId("a",       "a")
    verifyId(" a",      "a")
    verifyId("a ",      "a")
    verifyId(" a ",     "a")
    verifyId("ab",      "ab")
    verifyId("a\n",     "a")
    verifyId("a77",     "a77")
    verifyId("x9y",     "x9y")
    verifyId("_",       "_")
    verifyId("_foo_",   "_foo_")
    verifyId("For",     "For")
    verifyId("java",    "java")
    verifyId("net",     "net")
  }

  Void verifyId(Str src, Str id)
  {
    verifyToken(src, makeId(id))
  }

//////////////////////////////////////////////////////////////////////////
// Keywords
//////////////////////////////////////////////////////////////////////////

  Void testKeywords()
  {
    verifyToken("abstract",  makeToken(Token.abstractKeyword))
    verifyToken("as",        makeToken(Token.asKeyword))
    verifyToken("for",       makeToken(Token.forKeyword))
    verifyToken("internal",  makeToken(Token.internalKeyword))
    verifyToken("while",     makeToken(Token.whileKeyword))
  }

//////////////////////////////////////////////////////////////////////////
// Int Literals
//////////////////////////////////////////////////////////////////////////

  Void testIntLiterals()
  {
    verifyInt("3",           3)
    verifyInt("73",          73)
    verifyInt("123456",      123456)
    verifyInt("07",          07)
    verifyInt("1_234",       1234)
    verifyInt("1_234_567",   1234567)
    verifyInt("0x3",         0x3)
    verifyInt("0x03",        0x03)
    verifyInt("0x123",       0x123)
    verifyInt("0xabcdef",    0xabcdef)
    verifyInt("0xABCDEF",    0xABCDEF)
    verifyInt("0x3aF7cE",    0x3aF7cE)
    verifyInt("0x12345678",  0x12345678)
    verifyInt("0xffffffff",  0xffffffff)
    verifyInt("0xfedcba98",  0xfedcba98)
    verifyInt("0xfedcba9812345678",    0xfedcba9812345678)
    verifyInt("0xFFFFFFFFFFFFFFFF",    0xFFFFFFFFFFFFFFFF)
    verifyInt("0xffff_ffff",           0xffffffff)
    verifyInt("0xFFFF_FFFF_FFFF_FFFF", 0xFFFFFFFFFFFFFFFF)
    verifyInt("2147483647",            2147483647)
    verifyInt("9223372036854775807",   9223372036854775807)
    verifyInt("9_223_372_036_854_775_807",9223372036854775807)

    verifyInvalid("0x")
    verifyInvalid("0xG")
    verifyInvalid("0x1FFFFFFFFFFFFFFFF")
    verifyInvalid("92233720368547758070")
    verifyInvalid("92233720368547758070")
    verifyInvalid("-92233720368547758080")
    verifyInvalid("-92233720368547758080")

    // these are not caught right now (20+ digits is caught)
    // verifyInt("-9223372036854775808",  -9223372036854775808)
    // verifyInt ("9223372036854775807",   9223372036854775807)
  }

  Void testCharLiterals()
  {
    verifyInt("'a'",      'a')
    verifyInt("'X'",      'X')
    verifyInt("' '",      ' ')
    verifyInt("'\"'",     '"')
    verifyInt("'\\n'",    '\n')
    verifyInt("'\\r'",    '\r')
    verifyInt("'\\''",    '\'')
    verifyInt("'\\uabcd'",'\uabcd')
    verifyInvalid("'a")
    verifyInvalid("'ab'")
    verifyInvalid("'\\q'")
    verifyInvalid("'\\ug000'")
  }

  Void verifyInt(Str src, Int val)
  {
    verifyToken(src, makeInt(val))
  }

//////////////////////////////////////////////////////////////////////////
// Float Literals
//////////////////////////////////////////////////////////////////////////

  Void testFloatLiterals()
  {
    verifyFloat("3f",           3f)
    verifyFloat("3F",           3F)
    verifyFloat("3.0f",         3.0f)
    verifyFloat("73f",          73f)
    verifyFloat("73F",          73F)
    verifyFloat("73.0f",        73.0f)
    verifyFloat("123456f",      123456f)
    verifyFloat("123456F",      123456F)
    verifyFloat("123456.0f",    123456.0f)
    verifyFloat("7f",           7f)
    verifyFloat("07.0f",        07f)
    verifyFloat(".2f",          .2f)
    verifyFloat("0.2f",         0.2f)
    verifyFloat("0.007f",       0.007f)
    verifyFloat(".12345f",      .12345f)
    verifyFloat("0.12345f",     .12345f)
    verifyFloat("12345.6789f",  12345.6789f)
    verifyFloat("3e6f",         3e6f)
    verifyFloat("3E6f",         3E6f)
    verifyFloat("3.0e6f",       3.0e6f)
    verifyFloat("3.0E6f",       3.0E6f)
    verifyFloat("3e-6f",        3e-6f)
    verifyFloat("3E-6f",        3E-6f)
    verifyFloat(".2e+6f",       .2e+6f)
    verifyFloat(".2E+6f",       .2E+6f)
    verifyFloat(".2e-03f",      .2e-03f)
    verifyFloat(".2E-03f",      .2E-03f)
    verifyFloat("1.234_567F",   1.234567f)
    verifyFloat("1.2e3_00f",    1.2e300f)
    verifyFloat("1_2.3_7e5_6f", 12.37e56f)
    verifyFloat("1.5E-45f",               1.5E-45f)
    verifyFloat("3.402E77f",              3.402E77f)
    verifyFloat("1.4E-100f",              1.4E-100f)
    verifyFloat("1.7976931348623157E38f", 1.7976931348623157E38f)
    verifyInvalid("3e")
    verifyInvalid("-3e")
    verifyInvalid("-.3e")
    verifyInvalid("+0.3e")
  }

  Void verifyFloat(Str src, Float val)
  {
    verifyToken(src, makeFloat(val))
  }

//////////////////////////////////////////////////////////////////////////
// Decimal Literals
//////////////////////////////////////////////////////////////////////////

  Void testDecimalLiterals()
  {
    verifyDecimal("3d",           3d)
    verifyDecimal("3D",           3d)
    verifyDecimal("3.0d",         3.0d)
    verifyDecimal("73d",          73d)
    verifyDecimal("73D",          73D)
    verifyDecimal("73.0d",        73.0d)
    verifyDecimal("123456d",      123456d)
    verifyDecimal("123456D",      123456D)
    verifyDecimal("123456.0d",    123456.0d)
    verifyDecimal("7d",           7D)
    verifyDecimal("07.0d",        07.0D)
    verifyDecimal(".2d",          .2D)
    verifyDecimal("0.2d",         0.2D)
    verifyDecimal("0.007d",       0.007d)
    verifyDecimal(".12345d",      .12345d)
    verifyDecimal("0.12345d",     .12345d)
    verifyDecimal("12345.6789d",  12345.6789d)
    verifyDecimal("3e6d",         3e6d)
    verifyDecimal("3E6D",         3E6d)
    verifyDecimal("3.0E6d",       3.0E6d)
    verifyDecimal("3E-6D",        3E-6d)
    verifyDecimal(".2E+6d",       .2E+6d)
    verifyDecimal(".2E-03d",      .2E-03d)
    verifyDecimal("1.234_567D",   1.234567d)
    verifyDecimal("1.2e2_5d",     1.2e25d)
    verifyDecimal("1_2.3_7e1_1d",  12.37e11d)
    verifyDecimal("1.5E-4d",      1.5E-4d)
    verifyDecimal("3.402E15d",     3.402E15d)
    verifyDecimal("1.4E-12D",    1.4E-12d)
    verifyDecimal("1.7976931348623157E26d", 1.7976931348623157E26d)
    verifyInvalid("3.0")
    verifyInvalid("3e2")
    verifyInvalid("3e")
    verifyInvalid("3ed")
    verifyInvalid("-3e")
    verifyInvalid("-3ed")
    verifyInvalid("-.3e")
    verifyInvalid("-.3ed")
    verifyInvalid("+0.3e")
    verifyInvalid("+0.3ed")
  }

  Void verifyDecimal(Str src, Decimal val)
  {
    verifyToken(src, makeDecimal(val))
  }

//////////////////////////////////////////////////////////////////////////
// Duration Literals
//////////////////////////////////////////////////////////////////////////

  Void testDurationLiterals()
  {
    verifyDuration("0ns",       0)
    verifyDuration("5ns",       5)
    verifyDuration("1ms",       1000*1000)
    verifyDuration("1sec",      1000*1000*1000)
    verifyDuration("1min",      60*1000*1000*1000)
    verifyDuration("1hr",       60*60*1000*1000*1000)
    verifyDuration("0.5ms",     500*1000)
    verifyDuration("3.2ms",     3200*1000)
    verifyDuration("0.001sec",  1000*1000)
    verifyDuration("0.25min",   15*1000*1000*1000)
    verifyDuration("24hr",      24*60*60*1000*1000*1000)
    verifyDuration("876000hr",  876000*60*60*1000*1000*1000)  // 100yr
    verifyDuration("1day",      24*60*60*1000*1000*1000) // 1day
    verifyDuration("0.5day",    12*60*60*1000*1000*1000) // 1/2yr
    verifyDuration("30day",     30*24*60*60*1000*1000*1000) // 1day
    verifyDuration("36500day",  876000*60*60*1000*1000*1000)  // 100yr
  }

  Void verifyDuration(Str src, Int ns)
  {
    verifyToken(src, makeToken(Token.durationLiteral, Duration.make(ns)))
  }

//////////////////////////////////////////////////////////////////////////
// String Literals
//////////////////////////////////////////////////////////////////////////

  Void testStringLiterals()
  {
    verifyStr("\"\"",        "")
    verifyStr("\"a\"",       "a")
    verifyStr("\"ab\"",      "ab")
    verifyStr("\"abc\"",     "abc")
    verifyStr("\"a b\"",     "a b")
    verifyStr("\"a\\nb\"",   "a\nb")
    verifyStr("\"ab\\ncd\"", "ab\ncd")
    verifyStr("\"\\b\"",     "\b")
    verifyStr("\"\\t\"",     "\t")
    verifyStr("\"\\n\"",     "\n")
    verifyStr("\"\\f\"",     "\f")
    verifyStr("\"\\r\"",     "\r")
    verifyStr("\"\\\"\"",    "\"")
    verifyStr("\"''\"",      "''")
    verifyStr("\"\\r\\n\"",  "\r\n")
    verifyStr("\"\\u0001\"", "\u0001")
    verifyStr("\"\\u0010\"", "\u0010")
    verifyStr("\"\\u0100\"", "\u0100")
    verifyStr("\"\\u1000\"", "\u1000")
    verifyStr("\"\\uF000\"", "\uF000")
    verifyStr("\"\\uFFFF\"", "\uFFFF")
    verifyStr("\"\\uabcd\"", "\uabcd")
    verifyStr("\"\\uABCD\"", "\uABCD")
    verifyStr("\"a\n b\"",     "a\nb")      // with newline
    verifyStr("\"a\n b\n  c\"", "a\nb\n c")  // with newline
    verifyInvalid("\"")
    verifyInvalid("\"a")
    verifyInvalid("\"a\n")
    verifyInvalid("\"\\u000g\"")
    verifyInvalid("\"\\u00g0\"")
    verifyInvalid("\"\\u0g00\"")
    verifyInvalid("\"\\ug000\"")
  }

  Void verifyStr(Str src, Str val)
  {
    verifyToken(src, makeToken(Token.strLiteral, val))
  }

//////////////////////////////////////////////////////////////////////////
// String Interpolation
//////////////////////////////////////////////////////////////////////////

  Void testStringInterpolation()
  {
    lparen := makeToken(Token.lparenSynthetic)

    verifyTokens("\"\\\$x\"", [makeStr("\$x")])

    verifyTokens("\"\$x\"",   [lparen, makeStr(""), plus, makeId("x"), rparen])

    verifyTokens("\"\$r\"",   [lparen, makeStr(""), plus, makeId("r"), rparen])

    verifyTokens("\"\$x\".toUri",   [lparen, makeStr(""), plus, makeId("x"),
      rparen, dot, makeId("toUri")])

    verifyTokens("\"<\$x>\"", [lparen, makeStr("<"), plus, makeId("x"),
      plus, makeStr(">"), rparen])

    verifyTokens("\"\$x.y\"", [lparen, makeStr(""), plus, makeId("x"), dot, makeId("y"), rparen])

    verifyTokens("\"<\$x.y>\"", [lparen, makeStr("<"), plus, makeId("x"), dot, makeId("y"),
      plus, makeStr(">"), rparen])

    verifyTokens("\"a\$x-\$y\"", [lparen, makeStr("a"), plus, makeId("x"),
      plus, makeStr("-"), plus, makeId("y"), rparen])

    verifyTokens("\"\${x}\"", [lparen, makeStr(""), plus, lparen,
      makeId("x"), rparen, rparen])

    verifyTokens("\"\${x-y}\"", [lparen, makeStr(""), plus, lparen, makeId("x"),
      makeToken(Token.minus), makeId("y"), rparen, rparen])

    verifyTokens("\"foo\${x-y}bar\"", [lparen, makeStr("foo"), plus, lparen, makeId("x"),
      makeToken(Token.minus), makeId("y"), rparen, plus, makeStr("bar"), rparen])

    verifyTokens("\"foo\${x-y}bar\$roo\"", [lparen, makeStr("foo"), plus, lparen, makeId("x"),
      makeToken(Token.minus), makeId("y"), rparen, plus, makeStr("bar"), plus, makeId("roo"), rparen])

    verifyInvalid("\"\$x")
  }

  TokenVal plus()   { return makeToken(Token.plus) }
  TokenVal minus()  { return makeToken(Token.minus) }
  TokenVal dot()    { return makeToken(Token.dot) }
  TokenVal lparen() { return makeToken(Token.lparen) }
  TokenVal rparen() { return makeToken(Token.rparen) }

//////////////////////////////////////////////////////////////////////////
// Uri Literals
//////////////////////////////////////////////////////////////////////////

  Void testUriLiterals()
  {
    verifyUri("``",          "");
    verifyUri("`.`",         ".");
    verifyUri("`http://f/`", "http://f/");
    verifyUri("`;/?:@&=+,-_.~'()`",  ";/?:@&=+,-_.~'()");  // reserved+unreserved

    // escape sequences
    verifyUri("`\u1234 '\\`\\u0abc\\`' \\n\\t`", "\u1234 '`\u0abc`' \n\t");

    // gen-delim escape sequences
    verifyUri("`\\: \\/ \\? \\# \\[ \\]`", "\\: \\/ \\? \\# \\[ \\]");
    verifyUri("`\\\\foo`", "\\\\foo");

    verifyInvalid("`off end\n`")
    verifyInvalid("`off end")
    verifyInvalid(Str<|`\..`|>)
    verifyInvalid(Str<|`.\.`|>)
    verifyInvalid(Str<|`\x`|>)
  }

  Void verifyUri(Str src, Str val)
  {
    verifyToken(src, makeToken(Token.uriLiteral, val))
  }

//////////////////////////////////////////////////////////////////////////
// DSLs
//////////////////////////////////////////////////////////////////////////

  Void testDsl()
  {
    verifyDsl("<||>", "")
    verifyDsl("<|x|>", "x")
    verifyDsl("<|xy|>", "xy")
    verifyDsl("<|\\|>", "\\")
    verifyDsl("<|\$|>", "\$")
    verifyDsl("<||||>", "||")
    verifyInvalid("<||")
  }

  Void verifyDsl(Str src, Str val)
  {
    verifyToken(src, makeToken(Token.dsl, val))
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    verifyToken(".",       makeToken(Token.dot))
    verifyToken(";",       makeToken(Token.semicolon))
    verifyToken(",",       makeToken(Token.comma))
    verifyToken("+",       makeToken(Token.plus))
    verifyToken("-",       makeToken(Token.minus))
    verifyToken("*",       makeToken(Token.star))
    verifyToken("/",       makeToken(Token.slash))
    verifyToken("%",       makeToken(Token.percent))
    verifyToken("++",      makeToken(Token.increment))
    verifyToken("--",      makeToken(Token.decrement))
    verifyToken("!",       makeToken(Token.bang))
    verifyToken("?",       makeToken(Token.question))
    verifyToken("~",       makeToken(Token.tilde))
    verifyToken("|",       makeToken(Token.pipe))
    verifyToken("&",       makeToken(Token.amp))
    verifyToken("^",       makeToken(Token.caret))
    verifyToken("@",       makeToken(Token.at))
    verifyToken("||",      makeToken(Token.doublePipe))
    verifyToken("&&",      makeToken(Token.doubleAmp))
    verifyToken("==",      makeToken(Token.eq))
    verifyToken("!=",      makeToken(Token.notEq))
    verifyToken("===",     makeToken(Token.same))
    verifyToken("!==",     makeToken(Token.notSame))
    verifyToken("<",       makeToken(Token.lt))
    verifyToken("<=",      makeToken(Token.ltEq))
    verifyToken(">",       makeToken(Token.gt))
    verifyToken(">=",      makeToken(Token.gtEq))
    verifyToken("=",       makeToken(Token.assign))
    verifyToken("+=",      makeToken(Token.assignPlus))
    verifyToken("-=",      makeToken(Token.assignMinus))
    verifyToken("*=",      makeToken(Token.assignStar))
    verifyToken("/=",      makeToken(Token.assignSlash))
    verifyToken("%=",      makeToken(Token.assignPercent))
    verifyToken("->",      makeToken(Token.arrow))
    verifyToken("{",       makeToken(Token.lbrace))
    verifyToken("}",       makeToken(Token.rbrace))
    verifyToken("(",       makeToken(Token.lparen))
    verifyToken(")",       makeToken(Token.rparen))
    verifyToken("[",       makeToken(Token.lbracket))
    verifyToken("]",       makeToken(Token.rbracket))
    verifyToken(":",       makeToken(Token.colon))
    verifyToken("::",      makeToken(Token.doubleColon))
    verifyToken(":=",      makeToken(Token.defAssign))
    verifyToken("..",      makeToken(Token.dotDot))
    verifyToken("..<",     makeToken(Token.dotDotLt))
    verifyToken("<=>",     makeToken(Token.cmp))
    verifyInvalid("`")
  }

//////////////////////////////////////////////////////////////////////////
// Complex
//////////////////////////////////////////////////////////////////////////

  Void testComplex()
  {
    verifyTokens("a b",       [makeId("a"),   makeId("b")])
    verifyTokens("a\nb",      [makeId("a"),   makeId("b")])
    verifyTokens("a3\n_f",    [makeId("a3"),  makeId("_f")])
    verifyTokens("a*b",       [makeId("a"),   makeToken(Token.star),  makeId("b")])
    verifyTokens("for For",   [makeToken(Token.forKeyword),           makeId("For")])
    verifyTokens("1 2",       [makeInt(1),    makeInt(2)])
    verifyTokens("70 * 12",   [makeInt(70),   makeToken(Token.star),  makeInt(12)])
    verifyTokens("70f / 3.5f",[makeFloat(70f), makeToken(Token.slash), makeFloat(3.5f)])
    verifyTokens("7.toHex",   [makeInt(7),    makeToken(Token.dot),   makeId("toHex")])
  }

//////////////////////////////////////////////////////////////////////////
// Position
//////////////////////////////////////////////////////////////////////////

  Void testPosition()
  {
    tok := tokenize("\nfoo")
    verifyPos(tok[0], 2, 1);  verify(tok[0] == makeId("foo"))
    tok = tokenize("\n\n bar")
    verifyPos(tok[0], 3, 2);  verify(tok[0] == makeId("bar"))
    tok = tokenize("a\nb\nc")
    verifyPos(tok[0], 1, 1);  verify(tok[0] == makeId("a"))
    verifyPos(tok[1], 2, 1);  verify(tok[1] == makeId("b"))
    verifyPos(tok[2], 3, 1);  verify(tok[2] == makeId("c"))

    tok = tokenize(
    /*         123456789_123456789_1234 */
    /*  1 */  "foo bar\n" +
    /*  2 */  "here*\"there\"//junk\n" +
    /*  3 */  " 308 10d 55 8f\n" +
    /*  4 */  "/* a b /*c*/ d \n" +
    /*  5 */  "*/ +=;\n" +
    /*  6 */  "  a\n" +
    /*  7 */  " /*/* /*f*/ */!** */  b\n" +
    /*  8 */  " !\n" +
    /*  9 */  "\n" +
    /* 10 */  "     bear\n" +
    /* 11 */  "}")
    verifyPos(tok[0],   1, 1)  // foo
    verifyPos(tok[1],   1, 5)  // bar
    verifyPos(tok[2],   2, 1)  // here
    verifyPos(tok[3],   2, 5)  // *
    verifyPos(tok[4],   2, 6)  // "there"
    verifyPos(tok[5],   3, 2)  // 308
    verifyPos(tok[6],   3, 6)  // 1.0
    verifyPos(tok[7],   3, 10) // 55
    verifyPos(tok[8],   3, 13) // 8f
    verifyPos(tok[9],   5, 4)  // +=
    verifyPos(tok[10],  5, 6)  // ;
    verifyPos(tok[11],  6, 3)  // a
    verifyPos(tok[12],  7, 23) // b
    verifyPos(tok[13],  8, 2)  // !
    verifyPos(tok[14], 10, 6)  // bear
    verifyPos(tok[15], 11, 1)  // }
  }

  Void verifyPos(TokenVal t, Int line, Int col)
  {
    //echo(" pos " + t.line + ":" + t.col + " ?= " + line + ":" + col + "  " + t)
    verify(t.line == line)
    verify(t.col  == col)
  }

//////////////////////////////////////////////////////////////////////////
// Comments
//////////////////////////////////////////////////////////////////////////

  Void testComments()
  {
    verifyImpl("// foo bar",           TokenVal[,])
    verifyImpl("/* foo bar */",        TokenVal[,])
    verifyImpl("a// /* */",            [ makeId("a") ])
    verifyImpl("a// /* */more...",     [ makeId("a") ])
    verifyImpl("a// /* */more\n",      [ makeId("a") ])
    verifyImpl("a// /* */more\nx",     [ makeId("a"), makeId("x") ])
    verifyImpl("a/* foo bar */",       [ makeId("a") ])
    verifyImpl("a// blah blah\nb",     [ makeId("a"), makeId("b") ])
    verifyImpl("a/* blah blah*/b",     [ makeId("a"), makeId("b") ])
    verifyImpl("a/* 33 // 33 */b",     [ makeId("a"), makeId("b") ])
    verifyImpl("a/* /*33*/ // 33 */b", [ makeId("a"), makeId("b") ])

    verifyComment("** foo", ["foo"])
    verifyComment("*** foo", ["foo"])
    verifyComment("**  foo", [" foo"])
    verifyComment("**\n** foo\n **", ["foo"])
    verifyComment("**\n*** foo\n **\n **  \n", ["foo"])
    verifyComment("**\n**** foo\n++", ["foo"])
    verifyComment("** foo\n** bar", ["foo", "bar"])
    verifyComment("** foo\n ** bar", ["foo", "bar"])
    verifyComment("** foo\n **  bar", ["foo", " bar"])
    verifyComment("** foo\n **   bar", ["foo", "  bar"])
    verifyComment("**  foo\n ** bar", [" foo", "bar"])
    verifyComment(" **\n ** foo\n ** bar\n **\n public", ["foo", "bar"])
    verifyComment(" **\n ** foo\n ** bar\n **\n ** cool", ["foo", "bar", "", "cool"])
    verifyComment(" **\n ** foo\n ** bar\n **\n  **  cool", ["foo", "bar", "", " cool"])
  }

  Void verifyComment(Str src, Str[] comment)
  {
    t := tokenize(src)
    verify(t.size >= 1)
    verify(t[0].kind == Token.docComment)
    // echo("\"" + comment.replace("\n", "\\n") + "\" ?= \"" + t[0].val.toStr.replace("\n", "\\n") + "\"")
    verifyEq(t[0].val, comment)
  }

//////////////////////////////////////////////////////////////////////////
// Comments
//////////////////////////////////////////////////////////////////////////

  Void testInterpolationLoc()
  {
    verifyInterpolationLoc(
      Str<|"foo"|>,
      [[1, 1, "foo"]])

    verifyInterpolationLoc(
      //   12345678901234
      Str<|"foo|$bar"|>,
      [[1,  1, "("],
       [1,  1, "foo|"],
       [1,  7, "+"],
       [1,  7, "bar"],
       [1, 10, ")"]])

    verifyInterpolationLoc(
      //   12345678901234567890
      Str<|"foo|$bar.x.y|baz"|>,
      [[1,  1, "("],
       [1,  1, "foo|"],
       [1,  7, "+"],
       [1,  7, "bar"],
       [1, 10, "."],
       [1, 11, "x"],
       [1, 12, "."],
       [1, 13, "y"],
       [1, 14, "+"],
       [1, 14, "|baz"],
       [1, 18, ")"]])

    verifyInterpolationLoc(
      //   12345678901234567890
      Str<|"${x}_"|>,
      [[1,  1, "("],
       [1,  1, ""],
       [1,  3, "+"],
       [1,  3, "("],
       [1,  4, "x"],
       [1,  6, ")"],
       [1,  6, "+"],
       [1,  6, "_"],
       [1,  7, ")"]])

    verifyInterpolationLoc(
      //   12345678901234567890
      Str<|"123
            ${foo}
            456"|>,
      [[1,  1, "("],
       [1,  1, "123\n"],
       [2,  3, "+"],
       [2,  3, "("],
       [2,  4, "foo"],
       [2,  8, ")"],
       [2,  8, "+"],
       [2,  8, "\n456"],
       [3,  5, ")"]])
  }

  Void verifyInterpolationLoc(Str src, Obj[][] expected)
  {
    toks := tokenize(src)
    /*
    echo("================")
    echo("12345678901234")
    echo(src)
    toks.each |t| { echo(t.toLocationStr + ": " + t) }
    */
    verifyEq(toks.size, expected.size)
    toks.each |tok, i|
    {
      str := tok.toStr
      if (tok.kind === Token.strLiteral) str = tok.val

      verifyEq(tok.line, expected[i][0])
      verifyEq(tok.col,  expected[i][1])
      verifyEq(str,      expected[i][2])
    }
  }

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

  TokenVal[] tokenize(Str src)
  {
    // strip trailing eof
    c := Compiler(CompilerInput())
    c.log.level = LogLevel.silent
    r := Tokenizer.make(c, Loc("test"), src, true).tokenize[0..-2]
    if (c.errs.size > 0) throw c.errs.first
    return r
  }

  Void verifyToken(Str src, TokenVal want)
  {
    verifyTokens(src, [want])
  }

  Void verifyTokens(Str src, TokenVal[] want)
  {
    // try exact
    verifyImpl(src, want)

    // try with trailing semi colon to ensure
    // tokenizer  left in correct state
    verifyImpl(src+";", want.add(makeToken(Token.semicolon)))
  }

  Void verifyImpl(Str src, TokenVal[] want)
  {
    got := tokenize(src)

    /*
    echo("-- Tokenize \"" + src.replace("\n", "\\n") + "\" -> " + got.size)
    for (Int i:=0; i<got.size; ++i)
      echo("got[" + i + "] =" + got[i])
    */

    verifyEq(got, want)
  }

  Void verifyInvalid(Str src)
  {
    verifyErr(CompilerErr#) { tokenize(src) }
  }

//////////////////////////////////////////////////////////////////////////
// Token Factory
//////////////////////////////////////////////////////////////////////////

  TokenVal makeToken(Token kind, Obj? val := null)
  {
    return TokenVal(kind, val)
  }

  TokenVal makeId(Str id)           { return makeToken(Token.identifier, id); }
  TokenVal makeInt(Int val)         { return makeToken(Token.intLiteral, val); }
  TokenVal makeFloat(Float val)     { return makeToken(Token.floatLiteral, val); }
  TokenVal makeStr(Str val)         { return makeToken(Token.strLiteral, val); }
  TokenVal makeDecimal(Decimal val) { return makeToken(Token.decimalLiteral, val); }

}