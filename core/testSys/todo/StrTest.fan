//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 Mar 06  Brian Frank  Creation
//

**
** StrTest
**
@Js
class StrTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Def Val
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifyEq(Str.defVal, "")
    verifyEq(Str#.make, "")
  }

//////////////////////////////////////////////////////////////////////////
// Str Literals
//////////////////////////////////////////////////////////////////////////

  Void testLiterals()
  {
    x := "foo"
    y := "bar"

    verifyEq(
     "$x
       $y.upper
        baz", "foo\n BAR\n  baz")

    verifyEq(
      Str<|\$foo
            \bar

             \baz
           !|>, "\\\$foo\n \\bar\n\n  \\baz\n!")

    verifyEq(
      """foo
          bar

         "$y.upper"
         !""", "foo\n bar\n\n\"BAR\"\n!")

    verifyEq(""" ""foo"" """, Str<| ""foo"" |>)
    verifyEq("""$x "$x\" $x""", Str<|foo "foo" foo|>)
    verifyEq("""$x ""\$x"" $x""", Str<|foo ""$x"" foo|>)
  }

//////////////////////////////////////////////////////////////////////////
// Str Interpolation
//////////////////////////////////////////////////////////////////////////

  Void testInterpolation()
  {
    hello := "hello"
    five  := 5
    x     := 0xab
    f     := File.make(`./temp/test/`)

    verifyEq("\$"[0], '$')
    verifyEq("\$".size, 1)
    verifyEq("$hello",   "hello")
    verifyEq("$five",    "5")
    verifyEq("$x",       "171")
    verifyEq("$x.toHex", "ab")
    verifyEq("$x.toHex.size",   "2")
    verifyEq("$x.toHex.size()", "2()")
    verifyEq("${Type.of(this)}", "testSys::StrTest")
    verifyEq("x$five",   "x5")
    verifyEq("$five^",   "5^")
    verifyEq("x$five*",  "x5*")
    verifyEq("$five$hello",    "5hello")
    verifyEq("$five $hello",   "5 hello")
    verifyEq("<$five $hello>", "<5 hello>")
    verifyEq("${five}",  "5")
    verifyEq("${hello}", "hello")
    verifyEq("${five + 3}",   "8")
    verifyEq("${hello.size}", "5")
    verifyEq("${(five + 1) * 3 - 3}", "15")
    verifyEq("${((five + 1) * 3 - 3).toHex}", "f")
    verifyEq("$foo", "foo")
    verifyEq("${foo()}", "foo")
    verifyEq("$this.foo", "foo")
    verifyEq("$this.foo.size", "3")
    verifyEq("$f", f.toStr)

    y := "$five".toInt
    verifyType(y, Int#)
    verifyEq(y, 5)
  }

  Str foo() { return "foo" }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    Obj? x := ""
    verify("" == "")
    verify("a" == "a")
    verify("aB" == "aB")
    verify("" != "a")
    verify("bad" != "ass")
    verify(x != null)
    verify(null != x)
    verify("wow" as Obj != 4)

    verifySame("foo".toStr, "foo")
    verifySame("foo".toLocale, "foo")
  }

  Void testEqualsIgnoreCase()
  {
    verifyEq("a".equalsIgnoreCase("a"),  true)
    verifyEq("a".equalsIgnoreCase("A"),  true)
    verifyEq("a".equalsIgnoreCase("b"),  false)
    verifyEq("a".equalsIgnoreCase(""),   false)
    verifyEq("".equalsIgnoreCase("A"),   false)
    verifyEq("a".equalsIgnoreCase("aa"), false)
    verifyEq("aa".equalsIgnoreCase("a"), false)

    verifyEq("xyz".equalsIgnoreCase("xyz"), true)
    verifyEq("xyz".equalsIgnoreCase("xyzz"), false)
    verifyEq("xyz".equalsIgnoreCase("Xyz"), true)
    verifyEq("xyz".equalsIgnoreCase("xYz"), true)
    verifyEq("xyz".equalsIgnoreCase("xyZ"), true)

    verifyEq("apple 1234567890-=~!@#%^&*()_+[]{}|<>,./?".equalsIgnoreCase(
             "apple 1234567890-=~!@#%^&*()_+[]{}|<>,./?"), true)
    verifyEq("apple 1234567890-=~!@#%^&*()_+[]{}|<>,./?".equalsIgnoreCase(
             "ApPlE 1234567890-=~!@#%^&*()_+[]{}|<>,./?"), true)
    verifyEq("apple 1234567890-=~!@#%^&*()_+[]{}|<>,./?".equalsIgnoreCase(
             "APPLE 1234567890-=~!@#%^&*()_+[]{}|<>,./?"), true)
    verifyEq("apple 1234567890-=~!@#%^&*()_+[]{}|<>,./?".equalsIgnoreCase(
             "apple 1234567890-=~!`#%^&*()_+[]{}|<>,./?"), false)
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  Void testCompare()
  {
    verify("a" < "b")
    verify(null < "")
    verify(null < " ")
    verifyFalse("abc" < "abc")
    verifyFalse("a" < "A")
    verifyFalse("a" < null)

    verify("3" <= "3")
    verify("3" <= "3")
    verify(null <= "3")
    verifyFalse("6" <= "5")
    verifyFalse("5" <= null)

    verify("abcd" > "abc")
    verify("a" > "")
    verify("ABX" > "ABS")
    verifyFalse(null > "cool")
    verifyFalse("A" > "B")

    verify("ab" >= "aa")
    verify("abc" >= "abc")
    verify("anything" >= null)
    verifyFalse(null >= "")
    verifyFalse(null >= " x ")
    verifyFalse("y" >= "z")

    verifyEq("a" <=> "b", -1)
    verifyEq("a" <=> "a", 0)
    verifyEq("b" <=> "a", 1)
  }

  Void testCompareIgnoreCase()
  {
    verifyEq("a".compareIgnoreCase("b"), -1)
    verifyEq("a".compareIgnoreCase("a"), 0)
    verifyEq("b".compareIgnoreCase("a"), 1)

    verifyEq("a".compareIgnoreCase("B"), -1)
    verifyEq("a".compareIgnoreCase("A"), 0)
    verifyEq("b".compareIgnoreCase("A"), 1)

    verifyEq("A".compareIgnoreCase("b"), -1)
    verifyEq("A".compareIgnoreCase("a"), 0)
    verifyEq("B".compareIgnoreCase("a"), 1)

    verifyEq("a".compareIgnoreCase("aa"), -1)
    verifyEq("aaa".compareIgnoreCase("a"), 1)
    verifyEq("a".compareIgnoreCase("Aa"), -1)
    verifyEq("Aaa".compareIgnoreCase("aA"), 1)

    verifyEq("apple".compareIgnoreCase("Ape"), 1)
    verifyEq("abc 012".compareIgnoreCase("ABC 012"), 0)
    verifyEq("@".compareIgnoreCase("`"), -1)

    // Check the Turkish I: U+0130 dotted I and
    // U+0131 is the lowercase undotted i;  in Java
    // these expressions would not necessarily yield 1
    Locale.fromStr("tr").use
    {
      verifyEq("\u0130".compareIgnoreCase("I"), 1)
      verifyEq("\u0130".compareIgnoreCase("i"), 1)
      verifyEq("\u0131".compareIgnoreCase("I"), 1)
      verifyEq("\u0131".compareIgnoreCase("i"), 1)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Intern
//////////////////////////////////////////////////////////////////////////

  Void testIntern()
  {
    s := StrBuf.make.addChar('a').addChar('b').addChar('c').toStr
    verifySame("abc".intern, "abc")
    verifyNotSame(s, "abc")
    verifySame(s.intern, "abc".intern)
  }

//////////////////////////////////////////////////////////////////////////
// Size
//////////////////////////////////////////////////////////////////////////

  Void testSize()
  {
    verifyEq("".size, 0)
    verifyEq("".isEmpty, true)
    verifyEq("a".size, 1)
    verifyEq("a".isEmpty, false)
    verifyEq("ab".size, 2)
    verifyEq("ab".isEmpty, false)
  }

//////////////////////////////////////////////////////////////////////////
// Concat
//////////////////////////////////////////////////////////////////////////

  Void testConcat()
  {
    s := "hello number " + 5
    verifyEq(s, "hello number 5");

    s += "!"
    verifyEq(s, "hello number 5!");

    s += null
    verifyEq(s, "hello number 5!null");

    s += ""
    verifyEq(s, "hello number 5!null");

    s = s + " all done"
    verifyEq(s, "hello number 5!null all done");

    e := ""
    x := "foo".upper
    verifySame(e.plus(x), x)
    verifySame(x.plus(e), x)
  }

//////////////////////////////////////////////////////////////////////////
// Get
//////////////////////////////////////////////////////////////////////////

  Void testGet()
  {
    s := "abc\u00fb"
    verifyEq(s.size, 4)

    verifyGet(s, 0, 97)
    verifyGet(s, 1, 98)
    verifyGet(s, 2, 99)
    verifyGet(s, 3, 0xfb)
    verifyGet(s, 4, -1)

    verifyGet(s, -1, 0xfb)
    verifyGet(s, -2, 'c')
    verifyGet(s, -3, 'b')
    verifyGet(s, -4, 'a')
    verifyGet(s, -5, -1)
  }

  Void verifyGet(Str s, Int i, Int expected)
  {
    if (expected > 0)
    {
      verifyEq(s[i], expected)
      verifyEq(s.get(i), expected)
    }
    else
    {
      verifyErr(IndexErr#) { x := s[i] }
      verifyEq(s.getSafe(i), 0)
      verifyEq(s.getSafe(i, ' '), ' ')
    }
  }

//////////////////////////////////////////////////////////////////////////
// Slice
//////////////////////////////////////////////////////////////////////////

  Void testSlice()
  {
    /* Ruby
    irb(main):001:0> "abcd"[0..1]    => "ab"
    irb(main):002:0> "abcd"[0..2]    => "abc"
    irb(main):003:0> "abcd"[0..3]    => "abcd"
    irb(main):004:0> "abcd"[0..4]    => "abcd"
    irb(main):005:0> "abcd"[0..5]    => "abcd"
    irb(main):006:0> "abcd"[1..1]    => "b"
    irb(main):007:0> "abcd"[1..2]    => "bc"
    irb(main):008:0> "abcd"[1..3]    => "bcd"
    irb(main):009:0> "abcd"[1..4]    => "bcd"
    irb(main):010:0> "abcd"[0...1]   => "a"
    irb(main):011:0> "abcd"[0...2]   => "ab"
    irb(main):012:0> "abcd"[0...3]   => "abc"
    irb(main):013:0> "abcd"[0...4]   => "abcd"
    irb(main):014:0> "abcd"[0...5]   => "abcd"
    irb(main):015:0> "abcd"[0..-1]   => "abcd"
    irb(main):016:0> "abcd"[0..-2]   => "abc"
    irb(main):017:0> "abcd"[0..-3]   => "ab"
    irb(main):018:0> "abcd"[0..-4]   => "a"
    irb(main):019:0> "abcd"[0..-5]   => ""
    irb(main):020:0> "abcd"[0...-1]  => "abc"
    irb(main):021:0> "abcd"[0...-2]  => "ab"
    irb(main):022:0> "abcd"[0...-3]  => "a"
    irb(main):023:0> "abcd"[1...-3]  => ""
    irb(main):024:0> "abcd"[1...-1]  => "bc"
    irb(main):025:0> "abcd"[-3...-1] => "bc"
    irb(main):026:0> "abcd"[-2...-1] => "c"
    irb(main):027:0> "abcd"[-3...-1] => "bc"
    irb(main):028:0> "abcd"[-1...-1] => ""
    */

    // TODO: not clear how error handling should work...

    s := "abcd"
    verifyEq(s[0..1],    "ab")
    verifyEq(s[0..<0],   "")
    verifyEq(s[0..2],    "abc")
    verifyEq(s[0..3],    "abcd")
    verifyEq(s[1..1],    "b")
    verifyEq(s[1..2],    "bc")
    verifyEq(s[1..3],    "bcd")
    verifyEq(s[3..2],    "")
    verifyEq(s[3..3],    "d")
    verifyEq(s[4..-1],   "")
    verifyEq(s[0..<1],   "a")
    verifyEq(s[0..<2],   "ab")
    verifyEq(s[0..<3],   "abc")
    verifyEq(s[0..<4],   "abcd")
    verifyEq(s[0..-1],   "abcd")
    verifyEq(s[0..-2],   "abc")
    verifyEq(s[0..-3],   "ab")
    verifyEq(s[0..-4],   "a")
    verifyEq(s[0..-5],   "")
    verifyEq(s[0..<-1],  "abc")
    verifyEq(s[0..<-2],  "ab")
    verifyEq(s[0..<-3],  "a")
    verifyEq(s[1..<-3],  "")
    verifyEq(s[1..<-1],  "bc")
    verifyEq(s[-3..<-1], "bc")
    verifyEq(s[-2..<-1], "c")
    verifyEq(s[-3..<-1], "bc")
    verifyEq(s[-1..<-1], "")

    // examples
    verifyEq("abcd"[0..2],   "abc")
    verifyEq("abcd"[3..3],   "d")
    verifyEq("abcd"[-2..-1], "cd")
    verifyEq("abcd"[0..<2],  "ab")
    verifyEq("abcd"[1..-2],  "bc")


    verifyErr(IndexErr#) { x:=s[0..4] }
    verifyErr(IndexErr#) { x:=s[1..4] }
    verifyErr(IndexErr#) { x:=s[3..1] }
    verifyErr(IndexErr#) { x:=s[3..<2] }
    verifyErr(IndexErr#) { x:=s[0..<5] }
  }

//////////////////////////////////////////////////////////////////////////
// StartsWith, EndsWith
//////////////////////////////////////////////////////////////////////////

  Void testStartsWith()
  {
    verify("".startsWith(""))

    verify("x".startsWith(""))
    verify("x".startsWith("x"))
    verifyFalse("x".startsWith("xy"))

    verify("foo".startsWith(""))
    verify("foo".startsWith("f"))
    verify("foo".startsWith("fo"))
    verify("foo".startsWith("foo"))
    verifyFalse("foo".startsWith("fool"))
    verifyFalse("foo".startsWith("F"))
    verifyFalse("foo".startsWith("xyz"))
  }

  Void testEndsWith()
  {
    verify("".endsWith(""))

    verify("x".endsWith(""))
    verify("x".endsWith("x"))
    verifyFalse("x".endsWith("yx"))
    verifyFalse("x".endsWith("!"))

    verify("xyz".endsWith(""))
    verify("xyz".endsWith("z"))
    verify("xyz".endsWith("yz"))
    verify("xyz".endsWith("xyz"))
    verifyFalse("x".endsWith("!"))
    verifyFalse("x".endsWith("wxyz"))
  }

//////////////////////////////////////////////////////////////////////////
// Index
//////////////////////////////////////////////////////////////////////////

  Void testIndex()
  {
    verifyIndex("abcd", "a", null, 0)
    verifyIndex("abcd", "b", null, 1)
    verifyIndex("abcd", "c", null, 2)
    verifyIndex("abcd", "d", null, 3)
    verifyIndex("abcd", "e", null, null)
    verifyIndex("abcd", "ab", null, 0)
    verifyIndex("abcd", "bcd", null, 1)
    verifyIndex("abcd", "cd", null, 2)
    verifyIndex("abcd", "cdx", null, null)
    verifyIndex("abcd", "a", 1, null)
    verifyIndex("abcd", "a", -1, null)
    verifyIndex("abcd", "a", -3, null)
    verifyIndex("abcd", "a", -4, 0)
    verifyIndex("xx@`", "@`", 0, 2)
    verifyIndex("````", "@`", 0, null)

    verifyIndex("billy bob", "b", null, 0)
    verifyIndex("billy bob", "b", 1, 6)
    verifyIndex("billy bob", "b", 7, 8)
    verifyIndex("billy bob", "b", 9, null)

    verifyIndex("billy bob", "b", -1, 8)
    verifyIndex("billy bob", "b", -2, 8)
    verifyIndex("billy bob", "b", -4, 6)

    // fandoc examples
    verifyIndex("abcabc", "b", null, 1)
    verifyIndex("abcabc", "b", 1, 1)
    verifyIndex("abcabc", "b", 3, 4)
    verifyIndex("abcabc", "b", -3, 4)
    verifyIndex("abcabc", "x", null, null)
  }

  Void verifyIndex(Str base, Str sub, Int? off, Int? expected)
  {
    if (off == null)
    {
      verifyEq(base.index(sub), expected)
      verifyEq(base.lower.indexIgnoreCase(sub.upper), expected)
      verifyEq(base.upper.indexIgnoreCase(sub.lower), expected)
    }
    else
    {
      verifyEq(base.index(sub, off), expected)
      verifyEq(base.lower.indexIgnoreCase(sub.upper, off), expected)
      verifyEq(base.upper.indexIgnoreCase(sub.lower, off), expected)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Indexr
//////////////////////////////////////////////////////////////////////////

  Void testIndexr()
  {
    verifyIndexr("abcd", "a", null, 0)
    verifyIndexr("abcd", "b", null, 1)
    verifyIndexr("abcd", "c", null, 2)
    verifyIndexr("abcd", "d", null, 3)
    verifyIndexr("abcd", "e", null, null)
    verifyIndexr("abcd", "ab", null, 0)
    verifyIndexr("abcd", "bcd", null, 1)
    verifyIndexr("abcd", "cd", null, 2)
    verifyIndexr("abcd", "cdx", null, null)
    verifyIndexr("abcd", "a", 1, 0)
    verifyIndexr("abcd", "a", -1, 0)
    verifyIndexr("abcd", "a", -3, 0)
    verifyIndexr("abcd", "a", -4, 0)
    verifyIndexr("xx@`", "@", null, 2)

    verifyIndexr("bee hee", "ee", -1, 5)
    verifyIndexr("bee hee", "ee", -2, 5)
    verifyIndexr("bee hee", "ee", -3, 1)

    // fandoc examples
    verifyIndexr("abcabc", "b", null, 4)
    verifyIndexr("abcabc", "b", -3, 1)
    verifyIndexr("abcabc", "b", 0, null)
  }

  Void verifyIndexr(Str base, Str sub, Int? off, Int? expected)
  {
    if (off == null)
    {
      verifyEq(base.indexr(sub), expected)
      verifyEq(base.lower.indexrIgnoreCase(sub.upper), expected)
      verifyEq(base.upper.indexrIgnoreCase(sub.lower), expected)
    }
    else
    {
      verifyEq(base.indexr(sub, off), expected)
      verifyEq(base.lower.indexrIgnoreCase(sub.upper, off), expected)
      verifyEq(base.upper.indexrIgnoreCase(sub.lower, off), expected)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Contains
//////////////////////////////////////////////////////////////////////////

  Void testContains()
  {
    verify("abcd".contains("a"))
    verify("abcd".contains('a'.toChar))
    verify("abcd".contains("bc"))
    verifyFalse("abcd".contains("x"))
    verifyFalse("abcd".contains("abx"))
  }

//////////////////////////////////////////////////////////////////////////
// ContainsChar
//////////////////////////////////////////////////////////////////////////

  Void testContainsChar()
  {
    verifyEq("ab CD".containsChar('a'), true)
    verifyEq("ab CD".containsChar(' '), true)
    verifyEq("ab CD".containsChar('D'), true)
    verifyEq("ab CD".containsChar('c'), false)
    verifyEq("ab CD".containsChar('B'), false)
  }

//////////////////////////////////////////////////////////////////////////
// Chars
//////////////////////////////////////////////////////////////////////////

  Void testChars()
  {
    verifyChars("", Int[,])
    verifyChars("a", ['a'])
    verifyChars("a b", ['a', ' ', 'b'])
    verifyChars("\u345F", [0x345F])
  }

  Void verifyChars(Str s, Int[] chars)
  {
    verifyEq(s.chars, chars)
    verifyEq(Str.fromChars(chars), s)
  }

//////////////////////////////////////////////////////////////////////////
// Each
//////////////////////////////////////////////////////////////////////////

  Void testEach()
  {
    chars   := Int[,]
    indices := Int[,]

    // empty with just char
    chars.clear; indices.clear
    "".each |Int c| { chars.add(c) }
    verifyEq(chars, Int[,])

    // empty with char and index
    chars.clear; indices.clear
    "".each |Int c, Int index| { chars.add(c); indices.add(index) }
    verifyEq(chars, Int[,])
    verifyEq(indices, Int[,])

    // "x" with just char
    chars.clear; indices.clear
    "x".each |Int c| { chars.add(c) }
    verifyEq(chars, ['x'])

    // "x" with char and index
    chars.clear; indices.clear
    "x".each |Int c, Int index| { chars.add(c); indices.add(index) }
    verifyEq(chars, ['x'])
    verifyEq(indices, [0])

    // "abc" with just char
    chars.clear; indices.clear
    "abc".each |Int c| { chars.add(c) }
    verifyEq(chars, ['a', 'b', 'c'])

    // "abc" with char and index
    chars.clear; indices.clear
    "abc".each |Int c, Int index| { chars.add(c); indices.add(index) }
    verifyEq(chars, ['a', 'b', 'c'])
    verifyEq(indices, [0, 1, 2])
  }

//////////////////////////////////////////////////////////////////////////
// Eachr
//////////////////////////////////////////////////////////////////////////

  Void testEachr()
  {
    chars   := Int[,]
    indices := Int[,]

    // empty with just char
    chars.clear; indices.clear
    "".eachr |Int c| { chars.add(c) }
    verifyEq(chars, Int[,])

    // empty with char and index
    chars.clear; indices.clear
    "".eachr |Int c, Int index| { chars.add(c); indices.add(index) }
    verifyEq(chars, Int[,])
    verifyEq(indices, Int[,])

    // "x" with just char
    chars.clear; indices.clear
    "x".eachr |Int c| { chars.add(c) }
    verifyEq(chars, ['x'])

    // "x" with char and index
    chars.clear; indices.clear
    "x".eachr |Int c, Int index| { chars.add(c); indices.add(index) }
    verifyEq(chars, ['x'])
    verifyEq(indices, [0])

    // "abc" with just char
    chars.clear; indices.clear
    "abc".eachr |Int c| { chars.add(c) }
    verifyEq(chars, ['c', 'b', 'a'])

    // "abc" with char and index
    chars.clear; indices.clear
    "abc".eachr |Int c, Int index| { chars.add(c); indices.add(index) }
    verifyEq(chars, ['c', 'b', 'a'])
    verifyEq(indices, [2, 1, 0])
  }

//////////////////////////////////////////////////////////////////////////
// Any/All
//////////////////////////////////////////////////////////////////////////

  Void testAny()
  {
    verifyEq("".any |Int ch->Bool| { return ch.isUpper }, false)
    verifyEq("Bar".any |Int ch->Bool| { return ch.isUpper }, true)
    verifyEq("baR".any |Int ch->Bool| { return ch.isUpper }, true)
    verifyEq("bar".any |Int ch->Bool| { return ch.isUpper }, false)

    chars := Int[,]
    indices := Int[,]
    "abc".any |Int ch, Int i->Bool| { chars.add(ch); indices.add(i); return false }
    verifyEq(chars, ['a', 'b', 'c'])
    verifyEq(indices, [0, 1, 2])
  }

  Void testAll()
  {
    verifyEq("".all |Int ch->Bool| { return ch.isUpper }, true)
    verifyEq("Bar".all |Int ch->Bool| { return ch.isUpper }, false)
    verifyEq("baR".all |Int ch->Bool| { return ch.isUpper }, false)
    verifyEq("bar".all |Int ch->Bool| { return ch.isUpper }, false)
    verifyEq("BAR".all |Int ch->Bool| { return ch.isUpper }, true)

    chars := Int[,]
    indices := Int[,]
    "abc".all |Int ch, Int i->Bool| { chars.add(ch); indices.add(i); return true }
    verifyEq(chars, ['a', 'b', 'c'])
    verifyEq(indices, [0, 1, 2])
  }

//////////////////////////////////////////////////////////////////////////
// Spaces
//////////////////////////////////////////////////////////////////////////

  Void testSpaces()
  {
    js := Env.cur.runtime == "js"
    x := ""
    for (Int i := 0; i < 100; ++i)
    {
      verifyEq(Str.spaces(i), x)
      x += " "
    }
    verify(Str.spaces(0)    === Str.spaces(0))
    verify(Str.spaces(4)    === Str.spaces(4))
    verify(Str.spaces(10)   === Str.spaces(10))
    if (js) verify(Str.spaces(1000) === Str.spaces(1000))
    else    verify(Str.spaces(1000) !== Str.spaces(1000))
  }

//////////////////////////////////////////////////////////////////////////
// Upper/Lower
//////////////////////////////////////////////////////////////////////////

  Void testCaseConv()
  {
    verifyEq("aBcDeFxyZ".upper, "ABCDEFXYZ")
    verifyEq("aBcDeFxyZ".lower, "abcdefxyz")

    // capitalize
    verifySame("".capitalize, "")
    verifySame("A".capitalize, "A")
    verifySame("Abc".capitalize, "Abc")
    verifySame("_brian".capitalize, "_brian")
    verifyEq("a".capitalize, "A")
    verifyEq("ab".capitalize, "Ab")
    verifyEq("brian".capitalize, "Brian")

    // decapitalize
    verifySame("".decapitalize, "")
    verifySame("x".decapitalize, "x")
    verifySame("?".decapitalize, "?")
    verifyEq("X".decapitalize, "x")
    verifyEq("Brian".decapitalize, "brian")
    verifyEq("BAR".decapitalize, "bAR")

    // include some Unicode chars - U+0130 is the infamous
    // Turkish dotted I and U+0131 is the lowercase undotted i
    Locale.fromStr("tr").use
    {
      verifyEq("Ab\u03D0\u03F4\u0130\u0131".upper, "AB\u03D0\u03F4\u0130\u0131")
      verifyEq("aB\u03D0\u03F4\u0130\u0131".lower, "ab\u03D0\u03F4\u0130\u0131")
      verifyEq("if".capitalize, "If")
      verifyEq("Ice".decapitalize, "ice")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Display Name
//////////////////////////////////////////////////////////////////////////

  Void testDisplayName()
  {
    // normalized round trippers
    verifyDisplayName("", "")
    verifyDisplayName("a", "A")
    verifyDisplayName("z", "Z")
    verifyDisplayName("foo", "Foo")
    verifyDisplayName("fooBar", "Foo Bar")
    verifyDisplayName("roomZ", "Room Z")
    verifyDisplayName("reallyLongNameHere", "Really Long Name Here")
    verifyDisplayName("point5", "Point 5")
    verifyDisplayName("point23", "Point 23")
    verifyDisplayName("p\u01fct23Here", "P\u01fct 23 Here")
    verifyDisplayName("2Days55F", "2 Days 55 F")
    verifyDisplayName("23Days5Foo", "23 Days 5 Foo")

    // un-normalized toDisplayName
    verifyEq("Zoo\u01fc".toDisplayName, "Zoo\u01fc")
    verifyEq("IO".toDisplayName,  "IO")
    verifyEq("XML".toDisplayName, "XML")
    verifyEq("XMLCode".toDisplayName, "XML Code")
    verifyEq("OATemp3".toDisplayName,  "OA Temp 3")
    verifyEq("thisPV".toDisplayName, "This PV")
    verifyEq("fileCSV".toDisplayName, "File CSV")
    verifyEq("2days5foo".toDisplayName, "2 Days 5 Foo")
    verifyEq("23days55foo".toDisplayName, "23 Days 55 Foo")
    verifyEq("f_b".toDisplayName, "F B")
    verifyEq("foo_bar".toDisplayName, "Foo Bar")
    verifyEq("foo_Bar_bazRoo".toDisplayName, "Foo Bar Baz Roo")

    // un-normalized fromDisplayName
    verifyEq("foo".fromDisplayName, "foo")
    verifyEq("foo bar".fromDisplayName, "fooBar")
    verifyEq("foo 3".fromDisplayName, "foo3")
    verifyEq("foo 3 baz".fromDisplayName, "foo3Baz")
    verifyEq("file XML".fromDisplayName, "fileXML")
    verifyEq("IO File".fromDisplayName, "IOFile")
  }

  Void verifyDisplayName(Str p, Str d)
  {
    verifyEq(p.toDisplayName, d)
    verifyEq(d.fromDisplayName, p)
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  Void testLocale()
  {
    // english/latin
    Locale.fromStr("en").use
    {
      verifyLocale("Ice", "ICE", "ice", "Ice", "ice")
      verifyLocale("ice", "ICE", "ice", "Ice", "ice")
      verifyLocale("XYZ", "XYZ", "xyz", "XYZ", "xYZ")

      // C acute (106/107) E ogonek (118/119)
      verifyLocale("\u0106\u0119", "\u0106\u0118", "\u0107\u0119", "\u0106\u0119", "\u0107\u0119")
    }

    // turkish
    Locale.fromStr("tr").use
    {
      verifyLocale("Ice", "ICE", "\u0131ce", "Ice", "\u0131ce")
      verifyLocale("ice", "\u0130CE", "ice", "\u0130ce", "ice")
    }

    // NOTE: really the localeCapitalize and localeDecapitalize
    // should work with title case conversions which isn't necessarily
    // what has been implemented (and has no tests for such)
  }

  Void verifyLocale(Str orig, Str upper, Str lower, Str cap, Str decap)
  {
    verifyEq(orig.localeUpper, upper)
    verifyEq(orig.localeLower, lower)
    verifyEq(orig.localeCapitalize, cap)
    verifyEq(orig.localeDecapitalize, decap)

    verifyEq(orig.localeCompare(upper), 0)
    verifyEq(orig.localeCompare(lower), 0)
    verifyEq(orig.localeCompare(cap),   0)
    verifyEq(orig.localeCompare(decap), 0)
  }

//////////////////////////////////////////////////////////////////////////
// Is Ascii/Space/Upper/Lower
//////////////////////////////////////////////////////////////////////////

  Void testIsAscii()
  {
    verifyEq("".isAscii, true)
    verifyEq("7 X ~".isAscii, true)
    verifyEq("\u00ff".isAscii, false)
    verifyEq("xy \u00ff".isAscii, false)
  }

  Void testIsSpace()
  {
    verifyEq("".isSpace, true)
    verifyEq(" ".isSpace, true)
    verifyEq("\t\n\r\f ".isSpace, true)
    verifyEq("\t\nx\r\f ".isSpace, false)
    verifyEq("p".isSpace, false)
  }

  Void testIsUpper()
  {
    verifyEq("".isUpper, true)
    verifyEq("AZ".isUpper, true)
    verifyEq("Az".isUpper, false)
    verifyEq("iJ".isUpper, false)
    verifyEq("A\u1234Z".isUpper, false)
  }

  Void testIsLower()
  {
    verifyEq("".isLower, true)
    verifyEq("h".isLower, true)
    verifyEq("h2".isLower, false)
    verifyEq("hello".isLower, true)
    verifyEq("Hello".isLower, false)
    verifyEq("\u01ff".isLower, false)
    verifyEq("a b".isLower, false)
  }

  Void testIsAlpha()
  {
    verifyEq("".isAlpha, true)
    verifyEq(".".isAlpha, false)
    verifyEq("3".isAlpha, false)
    verifyEq("x".isAlpha, true)
    verifyEq("Bad".isAlpha, true)
    verifyEq("Bad ass".isAlpha, false)
    verifyEq("Bad7".isAlpha, false)
    verifyEq("AbCdE".isAlpha, true)
  }

  Void testIsAlphaNum()
  {
    verifyEq("".isAlphaNum, true)
    verifyEq(".".isAlphaNum, false)
    verifyEq("3".isAlphaNum, true)
    verifyEq("2Y".isAlphaNum, true)
    verifyEq("G3x9P".isAlphaNum, true)
    verifyEq("a b".isAlphaNum, false)
  }

//////////////////////////////////////////////////////////////////////////
// Just
//////////////////////////////////////////////////////////////////////////

  Void testJust()
  {
    verifySame("abc".justl(2), "abc")
    verifySame("abc".justl(3), "abc")
    verifyEq("abc".justl(4), "abc ")
    verifyEq("abc".justl(5), "abc  ")

    verifySame("abc".justr(2), "abc")
    verifySame("abc".justr(3), "abc")
    verifyEq("abc".justr(4), " abc")
    verifyEq("abc".justr(5), "  abc")
  }

//////////////////////////////////////////////////////////////////////////
// Pad
//////////////////////////////////////////////////////////////////////////

  Void testPad()
  {
    verifySame("abc".padr(2), "abc")
    verifySame("abc".padr(3), "abc")
    verifyEq("abc".padr(4), "abc ")
    verifyEq("abc".padr(6, '#'), "abc###")

    verifySame("x".padl(1), "x")
    verifyEq("x".padl(3), "  x")
    verifyEq("x".padl(5, '.'), "....x")

    verifyEq(3.toStr.padl(3, '0'), "003")
  }

//////////////////////////////////////////////////////////////////////////
// Reverse
//////////////////////////////////////////////////////////////////////////

  Void testReverse()
  {
    verifySame("".reverse, "")
    verifySame("x".reverse, "x")
    verifyEq("ab".reverse, "ba")
    verifyEq("xyz\uabcd".reverse, "\uabcdzyx")
  }

//////////////////////////////////////////////////////////////////////////
// Trim
//////////////////////////////////////////////////////////////////////////

  Void testTrim()
  {
    verifySame("".trim, "")
    verifySame("x".trim, "x")
    verifySame("!!".trim, "!!")
    verifyEq(" ".trim, "")
    verifyEq(" x".trim, "x")
    verifyEq("x ".trim, "x")
    verifyEq(" x ".trim, "x")
    verifyEq(" \n x \r  ".trim, "x")
    verifyEq("\u0019\u0000|foo bar|\n\r\t \u0005\n".trim, "|foo bar|")
  }

  Void testTrimStart()
  {
    verifySame("".trimStart, "")
    verifySame("x".trimStart, "x")
    verifySame("x ".trimStart, "x ")
    verifyEq(" x".trimStart, "x")
    verifyEq(" x ".trimStart, "x ")
    verifyEq("  xy z".trimStart, "xy z")
    verifyEq("\u0019\u0000xxx\u0019\u0000".trimStart, "xxx\u0019\u0000")
    verifyEq(" ".trimStart, "")
    verifyEq("  ".trimStart, "")
    verifyEq("   ".trimStart, "")
  }

  Void testTrimEnd()
  {
    verifySame("".trimEnd, "")
    verifySame("x".trimEnd, "x")
    verifySame(" x".trimEnd, " x")
    verifyEq("x ".trimEnd, "x")
    verifyEq(" x ".trimEnd, " x")
    verifyEq("xy z  ".trimEnd, "xy z")
    verifyEq("\u0019\u0000xxx\u0019\u0000".trimEnd, "\u0019\u0000xxx")
    verifyEq(" ".trimEnd, "")
    verifyEq("  ".trimEnd, "")
    verifyEq("   ".trimEnd, "")
  }

  Void testTrimToNull()
  {
    verifyNull("".trimToNull)
    verifyNull(" ".trimToNull)
    verifyNull("   ".trimToNull)
    verifyNull("\u0019\u0000\n\r\t \u0005\n".trimToNull)
    verifyEq(" x ".trimToNull, "x")
    verifySame("foo".trimToNull, "foo")
  }

//////////////////////////////////////////////////////////////////////////
// Split
//////////////////////////////////////////////////////////////////////////

  Void testSplit()
  {
    // null
    verifyEq("".split, [""])
    verifyEq("\n\t".split, [""])
    verifyEq("xx".split, ["xx"])
    verifyEq("  xx".split, ["xx"])
    verifyEq("A\n".split, ["A"])
    verifyEq("x y".split, ["x", "y"])
    verifyEq("x  y".split, ["x", "y"])
    verifyEq(" x y".split, ["x", "y"])
    verifyEq("x y ".split, ["x", "y"])
    verifyEq("a b c".split, ["a", "b", "c"])
    verifyEq("a\tb\nc".split, ["a", "b", "c"])
    verifyEq(" a bb \n c\td\n\nelf  ".split, ["a", "bb", "c", "d", "elf"])

    // trim
    verifyEq("".split('|'), [""])
    verifyEq("x".split('|'), ["x"])
    verifyEq(" x  y\n".split('|'), ["x  y"])
    verifyEq("foo|bar".split('|'), ["foo", "bar"])
    verifyEq(" foo | bar ".split('|', true), ["foo", "bar"])
    verifyEq("foo||bar".split('|'), ["foo", "", "bar"])
    verifyEq("0; 1; 2; 3".split(';', true), ["0", "1", "2", "3"])
    verifyEq("0; 1; 2; 3; ".split(';', true), ["0", "1", "2", "3", ""])
    verifyEq("a,b,,d,,,g".split(',', true), ["a", "b", "", "d", "", "", "g"])
    verifyEq("a, b, , d, , , g".split(','), ["a", "b", "", "d", "", "", "g"])
    verifyEq("\n|  alpha|boo| | c|  ".split('|'), ["", "alpha", "boo", "", "c", ""])

    // no trim
    verifyEq("".split('|', false), [""])
    verifyEq("x".split('|', false), ["x"])
    verifyEq(" x  y\n".split('|', false), [" x  y\n"])
    verifyEq("x|y".split('|', false), ["x", "y"])
    verifyEq("x||y".split('|', false), ["x", "", "y"])
    verifyEq(" x|yoo".split('|', false), [" x", "yoo"])
    verifyEq("x|y ".split('|', false), ["x", "y "])
    verifyEq(" x ! |\ny".split('|', false), [" x ! ", "\ny"])
    verifyEq("foo=bar".split('=', false), ["foo", "bar"])
    verifyEq("a,b,,d,,,g".split(',', false), ["a", "b", "", "d", "", "", "g"])
    verifyEq("a, b, , d, , , g".split(',', false), ["a", " b", " ", " d", " ", " ", " g"])
  }

//////////////////////////////////////////////////////////////////////////
// Split Lines
//////////////////////////////////////////////////////////////////////////

  Void testSplitLines()
  {
    verifyEq("".splitLines, [""])
    verifyEq("x".splitLines, ["x"])
    verifyEq("foo".splitLines, ["foo"])
    verifyEq("x\n".splitLines, ["x", ""])
    verifyEq("\nx\n".splitLines, ["", "x", ""])
    verifyEq("1\n2\n3".splitLines, ["1", "2", "3"])
    verifyEq("x\r".splitLines, ["x", ""])
    verifyEq("\r\rx".splitLines, ["", "", "x"])
    verifyEq("\r\n".splitLines, ["", ""])
    verifyEq("a\r\n".splitLines, ["a", ""])
    verifyEq("\r\na".splitLines, ["", "a"])
    verifyEq("a\r\nb".splitLines, ["a", "b"])
    verifyEq("foo\r\nbar\nbaz\rroo".splitLines, ["foo", "bar", "baz", "roo"])
  }

//////////////////////////////////////////////////////////////////////////
// Replace
//////////////////////////////////////////////////////////////////////////

  Void testReplace()
  {
    verifyEq("".replace("x", "-"), "")
    verifyEq("x".replace("x", "-"), "-")
    verifyEq("xx".replace("x", "-"), "--")
    verifyEq("xbx".replace("x", "-"), "-b-")
    verifyEq("axb".replace("x", "-"), "a-b")
    verifyEq("axb".replace("", "-"), "axb")

    verifyEq("".replace("xy", "-"), "")
    verifyEq("x".replace("xy", "-"), "x")
    verifyEq("xx".replace("xy", "-"), "xx")
    verifyEq("xy".replace("xy", "-"), "-")
    verifyEq("xyxy".replace("xy", "-"), "--")
    verifyEq("xyx".replace("xy", "-"), "-x")
    verifyEq("axb".replace("xy", "-"), "axb")
    verifyEq("axyb".replace("xy", "-"), "a-b")

    verifyEq("aaa".replace("aaa", "a"), "a")
    verifyEq("aaaaa".replace("aaa", "a"), "aaa")
    verifyEq("aaaaaa".replace("aaa", "a"), "aa")

    verifyEq("one two three".replace("one", "ONE"), "ONE two three")
    verifyEq("one two three".replace("one", "1"), "1 two three")
    verifyEq("one two three".replace("two", "TWO"), "one TWO three")
    verifyEq("one two three".replace("three", "3"), "one two 3")
  }

//////////////////////////////////////////////////////////////////////////
// NumLines
//////////////////////////////////////////////////////////////////////////

  Void testNumLines()
  {
    verifyEq("".numNewlines, 0)
    verifyEq("x".numNewlines, 0)
    verifyEq("foobar".numNewlines, 0)
    verifyEq("\n".numNewlines, 1)
    verifyEq("\r".numNewlines, 1)
    verifyEq("\r\n".numNewlines, 1)
    verifyEq("\nxx\nx\r".numNewlines, 3)
    verifyEq("x\r\r".numNewlines, 2)
    verifyEq("\rx\r\rx\r\n".numNewlines, 4)
  }

//////////////////////////////////////////////////////////////////////////
// Conversions
//////////////////////////////////////////////////////////////////////////

  Void testConversion()
  {
    verifyEq("true".toBool, true)
    verifyEq("false".toBool, false)
    verifyEq("xxx".toBool(false), null)
    verifyErr(ParseErr#) { "blah".toBool }

    verifyEq("708".toInt, 708)
    verifyEq("ff".toInt(16), 0xff)
    verifyEq("xxx".toInt(10, false), null)
    verifyErr(ParseErr#) { "blah".toInt }

    verifyEq("760.5".toFloat(), 760.5f)
    verifyEq("xxx".toFloat(false), null)
    verifyErr(ParseErr#) { "blah".toFloat }

    verifyEq("8.00".toDecimal, 8.00d)
    verifyEq("5.x".toDecimal(false), null)
    verifyErr(ParseErr#) { "5.x".toDecimal }

    verifyEq("http://foo/".toUri, `http://foo/`)

    verifyEq("foo".toRegex, Regex.fromStr("foo"))
  }

//////////////////////////////////////////////////////////////////////////
// ToCode
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq("".toCode, "\"\"")
    verifyEq("".toCode('\''), "''")

    verifyEq("a".toCode, "\"a\"")
    verifyEq("a".toCode('`'), "`a`")
    verifyEq("a".toCode('!'), "!a!")

    verifyEq("\u0000 \u001F".toCode, Str<|"\u0000 \u001f"|>)

    verifyEq("(\n \r \f \t \\ \$ ` ' \" \u0278 \u7abc)".toCode, "\"(\\n \\r \\f \\t \\\\ \\\$ ` ' \\\" \u0278 \u7abc)\"")
    verifyEq("(\n \r \f \t \\ \$ ` ' \" \u0278 \u7abc)".toCode('\''), "'(\\n \\r \\f \\t \\\\ \\\$ ` \\' \" \u0278 \u7abc)'")
    verifyEq("(\n \r \f \t \\ \$ ` ' \" \u0278 \u7abc)".toCode('`'), "`(\\n \\r \\f \\t \\\\ \\\$ \\` ' \" \u0278 \u7abc)`")
    verifyEq("(\n \r \f \t \\ \$ ` ' \" \u0278 \u8abc)".toCode('`', true), "`(\\n \\r \\f \\t \\\\ \\\$ \\` ' \" \\u0278 \\u8abc)`")
  }

//////////////////////////////////////////////////////////////////////////
// Mult
//////////////////////////////////////////////////////////////////////////

  Void testMult()
  {
    verifySame("x" * -1, "")
    verifySame("x" * 0, "")
    verifySame("x" * 1, "x")
    verifyEq("x" * 2, "xx")
    verifyEq("x" * 3, "xxx")
    verifyEq("x" * 4, "xxxx")
    verifySame("<>" * 1, "<>")
    verifyEq("<>" * 2, "<><>")
    verifyEq("<>" * 3, "<><><>")
  }

//////////////////////////////////////////////////////////////////////////
// ToXml
//////////////////////////////////////////////////////////////////////////

  Void testToXml()
  {
    verifySame("".toXml, "")
    verifySame("x".toXml, "x")
    verifySame("!@^%()".toXml, "!@^%()")
    verifySame("x>".toXml, "x>")
    verifySame("x>\u01bc".toXml, "x>\u01bc")
    verifyEq(">".toXml, "&gt;")
    verifyEq("]>".toXml, "]&gt;")
    verifyEq("<>&\"'".toXml, "&lt;>&amp;&quot;&#39;")
    verifyEq("foo&".toXml, "foo&amp;")
    verifyEq("foo&bar".toXml, "foo&amp;bar")
    verifyEq("&bar".toXml, "&amp;bar")
  }

//////////////////////////////////////////////////////////////////////////
// ToBuf
//////////////////////////////////////////////////////////////////////////

  Void testToBuf()
  {
    verifyEq("abc\u0abc".toBuf.toHex,
      Buf().print("abc\u0abc").toHex)

    verifyEq("x\u0abc".toBuf(Charset.utf16BE).toHex,
      Buf { charset=Charset.utf16BE; write(0).write('x').write(0xa).write(0xbc) }.toHex)

    verifyEq("hi there".toBuf.readAllStr, "hi there")
  }

//////////////////////////////////////////////////////////////////////////
// In
//////////////////////////////////////////////////////////////////////////

  Void testIn()
  {
    verifyEq("hi test".in.readAllStr, "hi test")
    verifyEq("hi\ntest".in.readAllLines, ["hi", "test"])
  }


}