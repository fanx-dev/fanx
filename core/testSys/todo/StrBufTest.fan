//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 May 06  Brian Frank  Creation
//

**
** StrBufTest
**
@Js
class StrBufTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Size
//////////////////////////////////////////////////////////////////////////

  Void testSize()
  {
    s := StrBuf.make
    verifyEq(s.size, 0)
    verifyEq(s.isEmpty, true)
    verifyEq(s.toStr, "")

    s.add("foo")
    verifyEq(s.size, 3)
    verifyEq(s.isEmpty, false)
    verifyEq(s.toStr, "foo")

    verify(s.capacity >= 3)
    s.capacity = 100
    verifyEq(s.capacity, 100)
  }

//////////////////////////////////////////////////////////////////////////
// Get/Set
//////////////////////////////////////////////////////////////////////////

  Void testGetSet()
  {
    s := StrBuf.make(8).add("abcd")
    verifyEq(s.size, 4)
    verifyEq(s[0], 'a')
    verifyEq(s[1], 'b')
    verifyEq(s[2], 'c')
    verifyEq(s[3], 'd')
    verifyEq(s[-1], 'd')
    verifyEq(s[-2], 'c')
    verifyEq(s[-3], 'b')
    verifyEq(s[-4], 'a')

    s[0]  = 'A'; verifyEq(s.toStr, "Abcd")
    s[-1] = 'D'; verifyEq(s.toStr, "AbcD")
    s[-3] = 'B'; verifyEq(s.toStr, "ABcD")
    s[2]  = 'C'; verifyEq(s.toStr, "ABCD")

    verifyErr(IndexErr#) { x := s[4] }
    verifyErr(IndexErr#) { x := s[-5] }
    verifyErr(IndexErr#) { s[4] = 'x' }
    verifyErr(IndexErr#) { s[-5] = 'x' }
    verifyEq(s.toStr, "ABCD")
  }

  Void testGetRange()
  {
    s := StrBuf.make(4).add("abcd")
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

    verifyErr(IndexErr#) { x:=s[0..4] }
    verifyErr(IndexErr#) { x:=s[1..4] }
    verifyErr(IndexErr#) { x:=s[3..1] }
    verifyErr(IndexErr#) { x:=s[3..<2] }
    verifyErr(IndexErr#) { x:=s[0..<5] }
  }

//////////////////////////////////////////////////////////////////////////
// Add
//////////////////////////////////////////////////////////////////////////

  Void testAdd()
  {
    s := StrBuf.make
    s.add("abc")
    s.addChar('d')
    s.add(null)
    s.addChar('\n')
    verifyEq(s.toStr, "abcdnull\n")
  }

//////////////////////////////////////////////////////////////////////////
// Join
//////////////////////////////////////////////////////////////////////////

  Void testJoin()
  {
    s := StrBuf()
    s.join(null);   verifyEq(s.toStr, "null")
    s.join(null);   verifyEq(s.toStr, "null null")
    s.join(3, ";"); verifyEq(s.toStr, "null null;3")
    s.clear
    s.join(3, "; "); verifyEq(s.toStr, "3")
    s.join(5, "; "); verifyEq(s.toStr, "3; 5")
  }

//////////////////////////////////////////////////////////////////////////
// Insert
//////////////////////////////////////////////////////////////////////////

  Void testInsert()
  {
    s := StrBuf.make
    s.insert(0, "xyz")
    verifyEq(s.toStr, "xyz")
    s.insert(0, 4)
    verifyEq(s.toStr, "4xyz")
    s.insert(1, null)
    verifyEq(s.toStr, "4nullxyz")
    s.insert(-1, "A")
    verifyEq(s.toStr, "4nullxyAz")
    s.insert(-2, true)
    verifyEq(s.toStr, "4nullxytrueAz")

    s.clear.add("abc")
    verifyErr(IndexErr#) { s.insert(4, "x") }
    verifyErr(IndexErr#) { s.insert(-4, "x") }
  }

//////////////////////////////////////////////////////////////////////////
// Remove
//////////////////////////////////////////////////////////////////////////

  Void testRemove()
  {
    s := StrBuf.make.add("abcdef")
    s.remove(0)
    verifyEq(s.toStr, "bcdef")
    s.remove(2)
    verifyEq(s.toStr, "bcef")
    s.remove(-1)
    verifyEq(s.toStr, "bce")
    s.remove(-2)
    verifyEq(s.toStr, "be")
    s.remove(1)
    verifyEq(s.toStr, "b")
    s.remove(0)
    verifyEq(s.toStr, "")

    s.add("abcdef")
    verifyErr(IndexErr#) { s.remove(-7) }
    verifyErr(IndexErr#) { s.remove(6) }
  }

//////////////////////////////////////////////////////////////////////////
// RemoveRange
//////////////////////////////////////////////////////////////////////////

  Void testRemoveRange()
  {
    s := StrBuf.make.add("abcdefghijklmnop")
    verifyEq(s.removeRange(0..<2).toStr,  "cdefghijklmnop")
    verifyEq(s.removeRange(1..3).toStr,   "cghijklmnop")
    verifyEq(s.removeRange(-3..-2).toStr, "cghijklmp")
    verifyEq(s.removeRange(-1..-1).toStr, "cghijklm")
    verifyEq(s.removeRange(4..<-2).toStr, "cghilm")
    verifyEq(s.removeRange(1..1).toStr,   "chilm")
    verifyEq(s.removeRange(-3..-1).toStr, "ch")
    verifyEq(s.removeRange(0..1).toStr,   "")

    verifyErr(IndexErr#) { StrBuf().add("").removeRange(0..1) }
    verifyErr(IndexErr#) { StrBuf().add("abc").removeRange(0..3) }
    verifyErr(IndexErr#) { StrBuf().add("abc").removeRange(0..<4) }
    verifyErr(IndexErr#) { StrBuf().add("abc").removeRange(-4..-1) }
  }

//////////////////////////////////////////////////////////////////////////
// Replace
//////////////////////////////////////////////////////////////////////////

  Void testReplace()
  {
    verifyEq(StrBuf().replaceRange(0..<0, "").toStr, "")
    verifyEq(StrBuf().replaceRange(0..<0, "abc").toStr, "abc")

    s := StrBuf.make.add("abcdefghijklmnop")
    verifyEq(s.replaceRange(0..<2, "").toStr,   "cdefghijklmnop")
    verifyEq(s.replaceRange(1..3, "ab").toStr,  "cabghijklmnop")
    verifyEq(s.replaceRange(-3..-2, "").toStr,  "cabghijklmp")
    verifyEq(s.replaceRange(-1..-1, "").toStr,  "cabghijklm")
    verifyEq(s.replaceRange(4..<-2, "").toStr,  "cabglm")
    verifyEq(s.replaceRange(1..1, "h").toStr,   "chbglm")
    verifyEq(s.replaceRange(-3..-1, "").toStr,  "chb")
    verifyEq(s.replaceRange(0..1, "xyz").toStr, "xyzb")
    verifyEq(s.replaceRange(0..3, "").toStr,    "")

    verifyErr(IndexErr#) { StrBuf().add("").replaceRange(0..1, "") }
    verifyErr(IndexErr#) { StrBuf().add("abc").replaceRange(0..3, "") }
    verifyErr(IndexErr#) { StrBuf().add("abc").replaceRange(0..<4, "") }
    verifyErr(IndexErr#) { StrBuf().add("abc").replaceRange(-4..-1, "abc") }
  }

//////////////////////////////////////////////////////////////////////////
// Clear
//////////////////////////////////////////////////////////////////////////

  Void testClear()
  {
    s := StrBuf.make
    s.add("foo")
    verifyEq(s.size, 3)
    verifyEq(s.isEmpty, false)
    verifyEq(s.toStr, "foo")
    s.clear()
    verifyEq(s.size, 0)
    verifyEq(s.isEmpty, true)
    verifyEq(s.toStr, "")
  }

//////////////////////////////////////////////////////////////////////////
// OutputStream
//////////////////////////////////////////////////////////////////////////

  Void testOut()
  {
    verifyOut("x\u0abc\n") |out| { out.print("x\u0abc\n") }
    verifyOut("x\u0abc\n") |out| { out.printLine("x\u0abc") }
    verifyOut("x\u0abc\n") |out| { out.writeChar('x').writeChar('\u0abc').writeChar('\n') }
    verifyOut("x\u0abc\n") |out| { out.writeChars("x\u0abc\n") }
    verifyOut("&lt;foo>") |out| { out.writeXml("<foo>") }
    verifyOut("&lt;&amp;\"'") |out| { out.writeXml("<&\"'") }
    verifyOut("&lt;&amp;&quot;&#39;") |out| { out.writeXml("<&\"'", OutStream.xmlEscQuotes) }

    verifyErr(UnsupportedErr#) { StrBuf().out.write(3) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeBuf(Buf()) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeI2(99) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeI4(99) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeI8(99) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeF4(99f) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeF8(99f) }
    verifyErr(UnsupportedErr#) { StrBuf().out.writeUtf("foo") }
  }

  Void verifyOut(Str expected, |OutStream out| f)
  {
    s := StrBuf()
    f(s.out)
    verifyEq(s.toStr, expected)
  }

//////////////////////////////////////////////////////////////////////////
// Wrapped OutputStream
//////////////////////////////////////////////////////////////////////////

  Void testOutWrap()
  {
    buf := StrBuf()
    out := StrBufWrapOutStream(buf.out)

    // writeChar, writeChars, print, printLine
    out.writeChar('a');           verifyEq(buf.toStr, "a")
    out.writeChars("bc");         verifyEq(buf.toStr, "abc")
    out.writeChars("xde", 1);     verifyEq(buf.toStr, "abcde")
    out.writeChars("xfgx", 1, 2); verifyEq(buf.toStr, "abcdefg")
    out.print("hi");              verifyEq(buf.toStr, "abcdefghi")
    out.printLine("j");           verifyEq(buf.toStr, "abcdefghij\n")

    // writeProps
    buf.clear
    out.writeProps(["k":"x\ty"]);  verifyEq(buf.toStr, "k=x\\ty\n")

    // writeXml
    buf.clear
    out.writeXml("<foo>");  verifyEq(buf.toStr, "&lt;foo>")
  }

//////////////////////////////////////////////////////////////////////////
// Charset
//////////////////////////////////////////////////////////////////////////

  Void testDefaultCharset()
  {
    s := StrBuf.make
    verify(s.out.charset.name == "UTF-8")
  }
}

@Js
internal class StrBufWrapOutStream : OutStream
{
  new make(OutStream out) : super(out) {}
}
