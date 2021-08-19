//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Mar 10  Brian Frank  Creation
//

**
** CsvTest
**
@Js
class CsvTest : Test
{

  Void test()
  {
    // simple with auto-trim
    verifyCsv(
      Str<|one, two , three|>,
      [["one", "two", "three"]])
      {}

    // simple with no-trim
    verifyCsv(
      Str<|one, two , three|>,
      [["one", " two ", " three"]])
      { it.trim = false}

    // empty fields with auto-trim
    verifyCsv(
      Str<|1 , 2 , 3
           5 ,   , |>,
      [["1", "2", "3"],
       ["5", "", ""]])
      {}

    // simple multi-line
    verifyCsv(
      Str<|1|2|3
           4|5|6|>,
      [["1", "2", "3"],
       ["4", "5", "6"]])
      { it.delimiter = '|' }

    // quoted fields
    verifyCsv(
      Str<|foo,"bar"
           "baz",roo
           "abc","x"
           "a" ,"b"|>,
      [["foo", "bar"],
       ["baz", "roo"],
       ["abc", "x"],
       ["a",   "b"]])
      {}

    // quoted fields with embedded delimiters and quotes
    verifyCsv(
      Str<|" one,two ","_""hello""_ "
           """x"""," ,y,"|>,
      [[" one,two ", """_"hello"_ """],
       [Str<|"x"|>, " ,y,"]])
      {}

    // trim with quotes and trailing whitespace won't work,
    // but allow leading whitespace before the quote
    verifyCsv(
      Str<|foo, "bar"
           "baz", roo
           "abc", "x"|>,
      [["foo", "bar"],
       ["baz", "roo"],
       ["abc", "x"]])
      {}

    // embedded newlines
    verifyCsv(
      Str<|long,"line1
           line2"|>,
      [["long", "line1\nline2"]])
      {}

    // embedded newlines
    verifyCsv(
      Str<|long with empty lines,"line1

           line2"|>,
      [["long with empty lines", "line1\n\nline2"]])
      {}

    // multiple embedded newlines
    verifyCsv(
      Str<|first;"a
           b ""quote""
           c;
           d"
           second;"""
           line2
           line3
           "|>,
      [["first", "a\nb \"quote\"\nc;\nd"],
       ["second", "\"\nline2\nline3\n"]])
      { it.delimiter = ';' }

    // unicode
    verifyCsv(
      "\u0420\u0443\u0441\u0441\u043a\u043e\u0435,\u0441\u043b\u043e\u0432\u043e",
      [["\u0420\u0443\u0441\u0441\u043a\u043e\u0435", "\u0441\u043b\u043e\u0432\u043e"]])
      {}

    // leading/trailing commas
    verifyCsv(
      Str<|a,b,c,d
           a,b,c,
           a,b,,
           a,,,
           ,,,
           ,b,c,d|>,
      [["a", "b", "c", "d"],
       ["a", "b", "c", ""],
       ["a", "b", "", ""],
       ["a", "", "", ""],
       ["", "", "", ""],
       ["", "b", "c", "d"]])
      {}
  }

  Void verifyCsv(Str src, Str[][] expected, |CsvInStream| f)
  {
    // readAllRows
    in := CsvInStream(src.in); f(in)
    x := in.readAllRows
    verifyEq(x, expected)

    // readRow
    i := 0
    in = CsvInStream(src.in); f(in)
    while (true)
    {
      row := in.readRow
      if (row == null) break
      verifyEq(row, expected[i++])
    }
    verifyEq(i, expected.size)

    // eachRow
    i = 0
    in = CsvInStream(src.in); f(in)
    in.eachRow |row| { verifyEq(row, expected[i++]) }
    verifyEq(i, expected.size)

    // CsvOutStream via Buf
    buf := Buf()
    out := CsvOutStream(buf.out)
    out.delimiter = in.delimiter
    expected.each |row| { out.writeRow(row) }
    str := buf.flip.readAllStr
    in = CsvInStream(str.in); f(in)
    verifyEq(in.readAllRows, expected)

    // CsvOutStream via StrBuf
    sb := StrBuf()
    out = CsvOutStream(sb.out)
    out.delimiter = in.delimiter
    expected.each |row| { out.writeRow(row) }
    str = sb.toStr
    in = CsvInStream(str.in); f(in)
    verifyEq(in.readAllRows, expected)
  }

}
