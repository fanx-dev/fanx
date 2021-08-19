//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 07  Brian Frank  Creation
//

**
** RegexTest
**
class RegexTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  Void testIdentity()
  {
    re := Regex.fromStr(";")
    verifyEq(re, Regex.fromStr(";"))
    verifyNotEq(re, ";")
    verifyEq(re.toStr, ";")
    verifyEq(re.hash, ";".hash)
    verifyType(re, Regex#)
    verifyEq(Regex.defVal.toStr, "")
  }

//////////////////////////////////////////////////////////////////////////
// Glob
//////////////////////////////////////////////////////////////////////////

  Void testGlob()
  {
    re := Regex.glob("foo*bar")
    verifyEq(re.toStr, "foo.*bar")
    verifyEq(re.matches("foobar"), true)
    verifyEq(re.matches("fooxbar"), true)
    verifyEq(re.matches("foo*._bar"), true)
    verifyEq(re.matches("fobar"), false)

    re = Regex.glob("a?b?c")
    verifyEq(re.toStr, "a.b.c")
    verifyEq(re.matches("a_b_c"), true)
    verifyEq(re.matches("abc"), false)

    re = Regex.glob("file*.txt")
    verifyEq(re.toStr, "file.*\\.txt")
    verifyEq(re.matches("file.txt"), true)
    verifyEq(re.matches("file22.txt"), true)
    verifyEq(re.matches("file-txt"), false)

    re = Regex.glob("+()")
    verifyEq(re.toStr, Str<|\+\(\)|>)
    verifyEq(re.matches("+()"), true)
  }

//////////////////////////////////////////////////////////////////////////
// Quote
//////////////////////////////////////////////////////////////////////////

  Void testQuote()
  {
    re := Regex.quote("foobar")
    verifyEq(re.toStr, "foobar")
    verifyEq(re.matches("foobar"), true)
    verifyEq(re.matches("barfoo"), false)

    re = Regex.quote("foo.*bar")
    verifyEq(re.toStr, "foo\\.\\*bar")
    verifyEq(re.matches("foobar"), false)
    verifyEq(re.matches("fooxbar"), false)
    verifyEq(re.matches("foo.*bar"), true)

    re = Regex.quote("+(.*)")
    verifyEq(re.toStr, Str<|\+\(\.\*\)|>)
    verifyEq(re.matches("+(.*)"), true)
  }

//////////////////////////////////////////////////////////////////////////
// Split
//////////////////////////////////////////////////////////////////////////

  Void testSplit()
  {
    // tests from javadoc
    s := "boo:and:foo"
    re := Regex.fromStr(":")
    verifyEq(re.split(s), ["boo", "and", "foo"])
    verifyEq(re.split(s, 0), ["boo", "and", "foo"])
    verifyEq(re.split(s, 1),  ["boo:and:foo"])
    verifyEq(re.split(s, 2),  ["boo", "and:foo"])
    verifyEq(re.split(s, 5),  ["boo", "and", "foo"])
    verifyEq(re.split(s, -2), ["boo", "and", "foo"])
    re = Regex.fromStr("o")
    verifyEq(re.split(s),       ["b", "", ":and:f",])
    verifyEq(re.split(s, 0),    ["b", "", ":and:f"])
    verifyEq(re.split(s, 5),    ["b", "", ":and:f", "", ""])
    verifyEq(re.split(s, -2),   ["b", "", ":and:f", "", ""])

    // spaces
    re = Regex<|\W+|>
    s = "This is a test."
    verifyEq(re.split(s), ["This", "is", "a", "test"])
    verifyEq(re.split(s, 3), ["This", "is", "a test."])
  }

//////////////////////////////////////////////////////////////////////////
// Matches
//////////////////////////////////////////////////////////////////////////

  Void testMatchesVsFind()
  {
    re := Regex.fromStr("^foo\$")
    verifyTrue(re.matcher("foo").matches)
    verifyTrue(re.matcher("foo").find)

    re = Regex.fromStr("foo")
    verifyTrue(re.matcher("foo").matches)
    verifyTrue(re.matcher("foo").find)

    re = Regex.fromStr("foo")
    verifyFalse(re.matcher("foo bar").matches)
    verifyTrue (re.matcher("foo bar").find)
  }

  ** Test basic usage which should also work in Javascript
  Void testFindGroups()
  {
    matcher := Regex.fromStr("(foo)-(bar)?").matcher("foo-bar wot foo-poo ever")

    verifyTrue(matcher.find)
    verifyEq  (matcher.groupCount, 2)
    verifyEq  (matcher.start, 0)
    verifyEq  (matcher.end, 7)
    verifyEq  (matcher.group(0), "foo-bar")
    verifyEq  (matcher.group(1), "foo")
    verifyEq  (matcher.group(2), "bar")

    verifyTrue(matcher.find)
    verifyEq  (matcher.groupCount, 2)
    verifyEq  (matcher.start, 12)
    verifyEq  (matcher.end, 16)
    verifyEq  (matcher.group(0), "foo-")
    verifyEq  (matcher.group(1), "foo")
    verifyEq  (matcher.group(2), null)

    verifyFalse(matcher.find)
  }

  Void testMatches()
  {
    re := Regex.fromStr("[a-z]+")
    verifyMatches(re, "", false)
    verifyMatches(re, "q", true)
    verifyMatches(re, "aqz", true)
    verifyMatches(re, "Aqz", false)
  }

  Void verifyMatches(Regex re, Str s, Bool expected)
  {
    verifyEq(re.matches(s), expected)

    m := re.matcher(s)
    verifyEq(m.matches, expected)
    if (expected)
    {
      verifyEq(m.group, s)
      verifyEq(m.start, 0)
      verifyEq(m.end,  s.size)
      verifyEq(m.groupCount, 0)

      verifyErr(IndexErr#) { m.group(1) }
      verifyErr(IndexErr#) { m.start(1) }
      verifyErr(IndexErr#) { m.end(1) }
    }
    else
    {
      verifyEq(m.groupCount, 0)
      verifyErr(Err#) { m.group }
      verifyErr(Err#) { m.start }
      verifyErr(Err#) { m.end }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Replacement
//////////////////////////////////////////////////////////////////////////

  Void testReplace()
  {
    verifyEq(Regex<|(\d+)|>.matcher("123 456 678").replaceFirst("foo"), "foo 456 678")
    verifyEq(Regex<|(\d+)|>.matcher("123 456 678").replaceAll("foo"), "foo foo foo")
  }

//////////////////////////////////////////////////////////////////////////
// Groups
//////////////////////////////////////////////////////////////////////////

  Void testGroups()
  {
    // single find
    m := Regex<|(a(b)c)d|>.matcher("abcd")
    verifyGroups(m, [ ["abcd", 0, 4], ["abc",  0, 3], ["b",    1, 2] ])
    verify(!m.find)

    // double find
    m = Regex<|(a(b)c)d|>.matcher("abcdabcd")
    verifyGroups(m, [ ["abcd", 0, 4], ["abc",  0, 3], ["b",    1, 2] ])
    verifyGroups(m, [ ["abcd", 4, 8], ["abc",  4, 7], ["b",    5, 6] ])
    verify(!m.find)

    // find null
    m = Regex <|foo|foo/(\d*)|>.matcher("foo/33")
    verifyGroups(m, [["foo", 0, 3], [null, -1, -1]])
  }

  Void verifyGroups(RegexMatcher m, Obj[][] expected)
  {
    verify(m.find)
    verifyEq(m.groupCount, expected.size-1)
    expected.each |Obj?[] x, Int i|
    {
      if (i == 0)
      {
        verifyEq(m.group, x[0])
        verifyEq(m.start, x[1])
        verifyEq(m.end,   x[2])
      }

      verifyEq(m.group(i), x[0])
      verifyEq(m.start(i), x[1])
      verifyEq(m.end(i),   x[2])
    }
  }
//////////////////////////////////////////////////////////////////////////
// Special characters, control chars
//////////////////////////////////////////////////////////////////////////

  Void testSpecialChars()
  {
    // build a str where the character index is the character value.
    str := (0..255).toList.map |Int ch->Str|{ch.toChar}.join

    // verify backslash escapes - tab, nl, etc.
    m := Regex<|[\t\n\r\f\a\e]|>.matcher(str)
    verifyMultipleMatches(m,
      [ ["\u0007", 7, 8], ["\u0009", 9,10], ["\u000a",10,11],
        ["\u000c",12,13], ["\u000d",13,14], ["\u001b",27,28] ])

    // hex space & tab; octal 'A' & 'B'; unicode 'a' & 'b'
    m = Regex<|[\x20\x09\0101\0102\u0061\u0062]|>.matcher(str)
    verifyMultipleMatches(m,
      [ ["\t",9,10], [" ",32,33],
        ["A",65,66], ["B",66,67],
        ["a",97,98], ["b",98,99] ])

    // ought to do the control characters: \cC, for ^C etc, but I don't
    // know the list of codes/values offhand

    // digit and nondigit
    m = Regex<|\d\D|>.matcher(str)
    verifyMultipleMatches(m, [ ["9:",'9','9'+2] ])

    // space and nonspace.  Space is: [\t\n\x0b\f\r ] == 0x09-0x0d + 0x20
    m = Regex<|(\s\s\s\s)?\s\S|>.matcher(str)
    verifyMultipleMatches(m,
      [ ["\u0009\u000a\u000b\u000c\u000d\u000e",9,15], ["\u0020\u0021",32,34] ])

    // word and nonword.  Word is: [a-zA-Z0-9_]
    m = Regex<|\w\W|>.matcher(str)
    verifyMultipleMatches(m,
      [ ["9:",57,59], ["Z[",90,92],
        ["_`",95,97], ["z{",122,124] ])

  }

//////////////////////////////////////////////////////////////////////////
// Character classes
//////////////////////////////////////////////////////////////////////////

  Void testClasses()
  {       //          1111111111222222222233333333334444
          //01234567890123456789012345678901234567890123
    qbf := "the Quick Brown fox jumped Over the Lazy dog"

    // union and range
    m := Regex<|[abc[A-Z]]|>.matcher(qbf)
    verifyMultipleMatches(m, [ ["Q",4,5], ["c",7,8], ["B",10,11], ["O",27,28], ["L",36,37], ["a",37,38] ])

    // negative class
    m = Regex<|[^a-z ]|>.matcher(qbf)
    verifyMultipleMatches(m, [ ["Q",4,5], ["B",10,11], ["O",27,28], ["L",36,37] ])

    // intersection
    m = Regex<|[a-z&&[fg]]|>.matcher(qbf)
    verifyMultipleMatches(m, [ ["f",16,17], ["g",43,44] ])

    // subtraction
    m = Regex<|[a-z&&[^c-x]]|>.matcher(qbf)
    verifyMultipleMatches(m, [ ["a",37,38], ["z",38,39], ["y",39,40] ])
  }

  // cycle the matcher and verify that it finds all (and only)
  // the expected matches.
  Void verifyMultipleMatches(RegexMatcher m, Obj[][] expected)
  {
    expected.each |Obj[] x|
    {
      verify(m.find)
      verifyEq(m.group, x[0])
      verifyEq(m.start, x[1])
      verifyEq(m.end,   x[2])
    }
    verify(!m.find)
  }

//////////////////////////////////////////////////////////////////////////
// Posix character classes
//////////////////////////////////////////////////////////////////////////

  Void testPosixClasses()
  {
    // \p{xxx} or \P{xxx}  where xxx is one of:
    // Lower Upper ASCII Alpha Digit Alnum
    // Punct Graph Print Blank Cntrl XDigit Space
    // \p means in the class, \P means not in the class
    // \p{Lower} A lower-case alphabetic character: [a-z]
    // \p{Upper} An upper-case alphabetic character:[A-Z]
    // \p{ASCII} All ASCII:[\x00-\x7F]
    // \p{Alpha} An alphabetic character:[\p{Lower}\p{Upper}]
    // \p{Digit} A decimal digit: [0-9]
    // \p{Alnum} An alphanumeric character:[\p{Alpha}\p{Digit}]
    // \p{Punct} Punctuation: One of !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
    // \p{Graph} A visible character: [\p{Alnum}\p{Punct}]
    // \p{Print} A printable character: [\p{Graph}\x20]
    // \p{Blank} A space or a tab: [ \t]
    // \p{Cntrl} A control character: [\x00-\x1F\x7F]
    // \p{XDigit} A hexadecimal digit: [0-9a-fA-F]
    // \p{Space} A whitespace character: [ \t\n\x0B\f\r]

    verifyMatches(Regex<|\p{Lower}|>, "a", true)
    verifyMatches(Regex<|\P{Lower}|>, "A", true)

    verifyMatches(Regex<|\p{Upper}|>, "A", true)
    verifyMatches(Regex<|\P{Upper}|>, "a", true)

    verifyMatches(Regex<|\p{ASCII}|>, "a", true)
    verifyMatches(Regex<|\P{ASCII}|>, "A", false)

    verifyMatches(Regex<|\p{Alpha}|>, "a", true)
    verifyMatches(Regex<|\P{Alpha}|>, "_", true)

    verifyMatches(Regex<|\p{Digit}|>, "1", true)
    verifyMatches(Regex<|\P{Digit}|>, "A", true)

    verifyMatches(Regex<|\p{Alnum}|>, "a", true)
    verifyMatches(Regex<|\P{Alnum}|>, "_", true)

    verifyMatches(Regex<|\p{Punct}|>, ":", true)
    verifyMatches(Regex<|\P{Punct}|>, "A", true)

    verifyMatches(Regex<|\p{Graph}|>, "a", true)
    verifyMatches(Regex<|\P{Graph}|>, "\t", true)

    verifyMatches(Regex<|\p{Print}|>, " ", true)
    verifyMatches(Regex<|\P{Print}|>, "\t", true)

    verifyMatches(Regex<|\p{Blank}|>, " ", true)
    verifyMatches(Regex<|\P{Blank}|>, "A", true)

    verifyMatches(Regex<|\p{Cntrl}|>, "\t", true)
    verifyMatches(Regex<|\P{Cntrl}|>, "A", true)

    verifyMatches(Regex<|\p{XDigit}|>, "a", true)
    verifyMatches(Regex<|\P{XDigit}|>, "g", true)

    verifyMatches(Regex<|\p{Space}|>, "\t", true)
    verifyMatches(Regex<|\P{Space}|>, "A", true)
  }

//////////////////////////////////////////////////////////////////////////
// java.lang.Character classes
//////////////////////////////////////////////////////////////////////////

  Void testJavaCharacterClasses()
  {
    // \p{xxx} or \P{xxx}  where xxx is one of:
    // \p{javaLowerCase} Equivalent to java.lang.Character.isLowerCase()
    // \p{javaUpperCase} Equivalent to java.lang.Character.isUpperCase()
    // \p{javaWhitespace} Equivalent to java.lang.Character.isWhitespace()
    // \p{javaMirrored} Equivalent to java.lang.Character.isMirrored()

    verifyMatches(Regex<|\p{javaLowerCase}|>, "a", true)
    verifyMatches(Regex<|\P{javaLowerCase}|>, "A", true)

    verifyMatches(Regex<|\p{javaUpperCase}|>, "A", true)
    verifyMatches(Regex<|\P{javaUpperCase}|>, "a", true)

    verifyMatches(Regex<|\p{javaWhitespace}|>, " ", true)
    verifyMatches(Regex<|\P{javaWhitespace}|>, "a", true)

    // not even sure what 'mirrored' means
    verifyMatches(Regex<|\p{javaMirrored}|>, "a", false)
    verifyMatches(Regex<|\P{javaMirrored}|>, "a", true)
  }

//////////////////////////////////////////////////////////////////////////
// Unicode blocks and categories
//////////////////////////////////////////////////////////////////////////

  Void testUnicodeBlocks()
  {
    // \p{xxx} or \P{xxx} where xxx is one of:
    // InGreek Lu Sc (L is letter, Lu is uppercase, S is Symbol, Sc is currency)
    // @see java.lang.Character.UnicodeBlock for supported blocks

    verifyMatches(Regex<|\p{L}|>, "a", true)
    verifyMatches(Regex<|\p{Lu}|>, "A", true)
    verifyMatches(Regex<|\p{S}|>, ":", false)
    verifyMatches(Regex<|\p{Sc}|>, "\$", true)
  }

//////////////////////////////////////////////////////////////////////////
// Boundary matchers - match to start or end of text / line
//////////////////////////////////////////////////////////////////////////

  Void testBoundaryMatchers()
  {
    // ^ $ \b \B \A \G \Z \z
    // ^ The beginning of a line
    // $ The end of a line
    // \b A word boundary
    // \B A non-word boundary
    // \A The beginning of the input
    // \G The end of the previous match
    // \Z The end of the input but for the final terminator, if any
    // \z The end of the input

    m := Regex<|^a.*d$|>.matcher("abcd")
    verifyGroups(m, [ ["abcd", 0, 4] ])
    verify(!m.find)

    m = Regex<|\b..\b|>.matcher("ab cd")
    verifyGroups(m, [ ["ab", 0, 2] ])
    verifyGroups(m, [ ["cd", 3, 5] ])
    verify(!m.find)

    m = Regex<|.\B.|>.matcher("ab:cd")
    verifyGroups(m, [ ["ab", 0, 2] ])
    verifyGroups(m, [ ["cd", 3, 5] ])
    verify(!m.find)

    // need \G test

    m = Regex<|\A.*\Z|>.matcher("abcd")
    verifyGroups(m, [ ["abcd", 0, 4] ])
    verify(!m.find)
  }

//////////////////////////////////////////////////////////////////////////
// Greedy
//////////////////////////////////////////////////////////////////////////

  Void testGreedyQuantifiers()
  {
    // X?       X, once or not at all
    // X*       X, zero or more times
    // X+       X, one or more times
    // X{n}     X, exactly n times
    // X{n,}    X, at least n times
    // X{n,m}   X, at least n but not more than m times

    m := Regex<|(a*)(a+)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaa", 0, 3], ["a", 3, 4] ])

    m = Regex<|(a*)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaaa", 0, 4], ["", 4, 4] ])

    m = Regex<|(a?)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["a", 0, 1], ["aaa", 1, 4] ])

    m = Regex<|(a+)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaaa", 0, 4], ["", 4, 4] ])

    m = Regex<|(a{2})(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aa", 0, 2], ["aa", 2, 4] ])

    m = Regex<|(a{2,})(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaaa", 0, 4], ["", 4, 4] ])

    m = Regex<|(a{2,3})(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaa", 0, 3], ["a", 3, 4] ])
  }

//////////////////////////////////////////////////////////////////////////
// Reluctant
//////////////////////////////////////////////////////////////////////////

  Void testReluctantQuantifiers()
  {
    // X??      X, once or not at all
    // X*?      X, zero or more times
    // X+?      X, one or more times
    // X{n}?    X, exactly n times
    // X{n,}?   X, at least n times
    // X{n,m}?  X, at least n but not more than m times

    m := Regex<|(a*?)(a+)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["", 0, 0], ["aaaa", 0, 4] ])

    m = Regex<|(a*?)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["", 0, 0], ["aaaa", 0, 4] ])

    m = Regex<|(a??)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["", 0, 0], ["aaaa", 0, 4] ])

    m = Regex<|(a+?)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["a", 0, 1], ["aaa", 1, 4] ])

    m = Regex<|(a{2}?)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aa", 0, 2], ["aa", 2, 4] ])

    m = Regex<|(a{2,}?)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aa", 0, 2], ["aa", 2, 4] ])

    m = Regex<|(a{2,3}?)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aa", 0, 2], ["aa", 2, 4] ])
  }

//////////////////////////////////////////////////////////////////////////
// Posessive
//////////////////////////////////////////////////////////////////////////

  Void testPosessiveQuantifiers()
  {
    // X?+      X, once or not at all
    // X*+      X, zero or more times
    // X++      X, one or more times
    // X{n}+    X, exactly n times
    // X{n,}+   X, at least n times
    // X{n,m}+  X, at least n but not more than m times

    m := Regex<|(a*+)a|>.matcher("aaaa")
    //verifyGroups(m, [ ["aaaa", 0, 4], ["aaaa", 0, 4] ], [null, -1, -1] ])
    verify(!m.find) // possessive group steals all the a's

    m = Regex<|(a*+)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaaa", 0, 4], ["", 4, 4] ])

    m = Regex<|(a?+)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["a", 0, 1], ["aaa", 1, 4] ])

    m = Regex<|(a++)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaaa", 0, 4], ["", 4, 4] ])

    m = Regex<|(a{2}+)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aa", 0, 2], ["aa", 2, 4] ])

    m = Regex<|(a{2,}+)a|>.matcher("aaaa")
    verify(!m.find)

    m = Regex<|(a{2,3}+)(a*)|>.matcher("aaaa")
    verifyGroups(m, [ ["aaaa", 0, 4], ["aaa", 0, 3], ["a", 3, 4] ])
  }

//////////////////////////////////////////////////////////////////////////
// Logical operators
//////////////////////////////////////////////////////////////////////////

  Void testLogicalOperators()
  {
    // XY X followed by Y
    // X|Y Either X or Y
    // (X) X, as a capturing group

    verifyMatches(Regex.fromStr("XY"), "XY", true)
    verifyMatches(Regex.fromStr("X|Y"), "X", true)
    verifyMatches(Regex.fromStr("X|Y"), "Y", true)
    m := Regex<|(X)|>.matcher("X")
    verifyGroups(m, [ ["X", 0, 1], ["X", 0, 1] ])
  }

//////////////////////////////////////////////////////////////////////////
// Back references
//////////////////////////////////////////////////////////////////////////

  Void testBackReferences()
  {
    // \n Whatever the nth capturing group matched
    m := Regex<|(a(b)c)d\2\1|>.matcher("abcdbabc")
    verifyGroups(m, [ ["abcdbabc", 0, 8], ["abc",  0, 3], ["b",    1, 2] ])
    verify(!m.find)
  }

//////////////////////////////////////////////////////////////////////////
// Quotation
//////////////////////////////////////////////////////////////////////////

  Void testQuotation()
  {
    // \ Nothing, but quotes the following character
    // \Q Nothing, but quotes all characters until \E
    // \E Nothing, but ends quoting started by \Q

    // assume normal backslash quote is tested elsewhere;
    // verify we understand \Q..\E
    // NOTE: this does regex-quoting, quotes characters so they don't
    // have special meaning to Regex.  Doesn't do string quoting, so
    // \Qt\E doesn't make a tab.
    m := Regex<|\Q[.]trn\E|>.matcher("[.]trn")
    verifyGroups(m, [ ["[.]trn", 0, 6] ])
    verify(!m.find)

  }

//////////////////////////////////////////////////////////////////////////
// Special constructs
//////////////////////////////////////////////////////////////////////////

  Void testSpecialConstructs()
  {
    // (?:X) X, as a non-capturing group
    // (?idmsux-idmsux)  Nothing, but turns match flags i d m s u x on - off
    // (?idmsux-idmsux:X)   X, as a non-capturing group with the given flags i d m s u x on - off
    // (?=X) X, via zero-width positive lookahead
    // (?!X) X, via zero-width negative lookahead
    // (?<=X) X, via zero-width positive lookbehind
    // (?<!X) X, via zero-width negative lookbehind
    // (?>X) X, as an independent, non-capturing group

  }

}