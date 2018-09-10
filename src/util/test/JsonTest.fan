//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 08  Brian Frank  Creation
//

class JsonTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Basics
//////////////////////////////////////////////////////////////////////////

  Void testBasics()
  {
    // basic scalars
    verifyBasics("null", null)
    verifyBasics("true", true)
    verifyBasics("false", false)

    // numbers
    verifyBasics("5", 5)
    verifyBasics("-1234", -1234)
    verifyBasics("23.48", 23.48f)
    verifyBasics("2.309e23", 2.309e23f)
    verifyBasics("-5.8e-15", -5.8e-15f)

    // strings
    verifyBasics(Str<|""|>, "")
    verifyBasics(Str<|"x"|>, "x")
    verifyBasics(Str<|"ab"|>, "ab")
    verifyBasics(Str<|"hello world!"|>, "hello world!")
    verifyBasics(Str<|"\" \\ \/ \b \f \n \r \t"|>, "\" \\ / \b \f \n \r \t")
    verifyBasics(Str<|"\u00ab \u0ABC \uabcd"|>, "\u00ab \u0ABC \uabcd")

    // arrays
    verifyBasics("[]", Obj?[,])
    verifyBasics("[1]", Obj?[1])
    verifyBasics("[1,2.0]", Obj?[1,2f])
    verifyBasics("[1,2,3]", Obj?[1,2,3])
    verifyBasics("[3, 4.0, null, \"hi\"]", [3, 4.0f, null, "hi"])
    verifyBasics("[2,\n3]", Obj?[2, 3])
    verifyBasics("[2\n,3]", Obj?[2, 3])
    verifyBasics("[  2 \n , \n 3 ]", Obj?[2, 3])

    // objects
    verifyBasics(Str<|{}|>, Str:Obj?[:])
    verifyBasics(Str<|{"k":null}|>, Str:Obj?["k":null])
    verifyBasics(Str<|{"a":1, "b":2}|>, Str:Obj?["a":1, "b":2])
    verifyBasics(Str<|{"a":1, "b":2,}|>, Str:Obj?["a":1, "b":2])

    // errors
    verifyErr(ParseErr#) { JsonInStream("\"".in).readJson }
    verifyErr(ParseErr#) { JsonInStream("[".in).readJson }
    verifyErr(ParseErr#) { JsonInStream("[1".in).readJson }
    verifyErr(ParseErr#) { JsonInStream("[1,2".in).readJson }
    verifyErr(ParseErr#) { JsonInStream("{".in).readJson }
    verifyErr(ParseErr#) { JsonInStream("""{"x":""".in).readJson }
    verifyErr(ParseErr#) { JsonInStream("""{"x":4,""".in).readJson }
  }

  Void verifyBasics(Str s, Obj? expected)
  {
    // verify object stand alone
    verifyRoundtrip(expected)

    // wrap as [s]
    array := JsonInStream("[$s]".in).readJson as Obj?[]
    verifyIsType(array, Obj?[]#)
    verifyEq(array.size, 1)
    verifyEq(array[0], expected)
    verifyRoundtrip(array)

    // wrap as [s, s]
    array = JsonInStream("[$s,$s]".in).readJson as Obj?[]
    verifyIsType(array, Obj?[]#)
    verifyEq(array.size, 2)
    verifyEq(array[0], expected)
    verifyEq(array[1], expected)
    verifyRoundtrip(array)

    // wrap as {"key":s}
    map := JsonInStream("{\"key\":$s}".in).readJson as Str:Obj?
    verifyIsType(map, Str:Obj?#)
    verifyEq(map.size, 1)
    verifyEq(map["key"], expected)
    verifyRoundtrip(map)
  }

  Void verifyRoundtrip(Obj? obj)
  {
    str := JsonOutStream.writeJsonToStr(obj)
    roundtrip := JsonInStream(str.in).readJson
    verifyEq(obj, roundtrip)
  }

//////////////////////////////////////////////////////////////////////////
// Write
//////////////////////////////////////////////////////////////////////////

  Void testWrite()
  {
    // built-in scalars
    verifyWrite(null, Str<|null|>)
    verifyWrite(true, Str<|true|>)
    verifyWrite(false, Str<|false|>)
    verifyWrite("hi", Str<|"hi"|>)
    verifyWrite(-2.3e34f, Str<|-2.3E34|>)
    verifyWrite(34.12345d, Str<|34.12345|>)

    // list/map sanity checks
    verifyWrite([1, 2, 3], Str<|[1,2,3]|>)
    verifyWrite(["key":"val"], Str<|{"key":"val"}|>)
    verifyWrite(["key":"val\\\"ue"], Str<|{"key":"val\\\"ue"}|>)


    // simples
    verifyWrite(5min, Str<|"5min"|>)
    verifyWrite(`/some/uri/`, Str<|"/some/uri/"|>)
    verifyWrite(TimeOfDay("23:45:01"), Str<|"23:45:01"|>)
    verifyWrite(Date("2009-12-21"), Str<|"2009-12-21"|>)
    verifyWrite(Month.dec, Str<|"dec"|>)
    verifyWrite(Version("3.4"), Str<|"3.4"|>)

    // serializable
    verifyWrite(SerialA(),
      Str<|{"b":true,"i":7,"f":5.0,"s":"string\n","ints":[1,2,3]}|>)

    // errors
    verifyErr(IOErr#) { verifyWrite(Buf(), "") }
    verifyErr(IOErr#) { verifyWrite(Str#.pod, "") }
  }

  Void verifyWrite(Obj? obj, Str expected)
  {
    verifyEq(JsonOutStream.writeJsonToStr(obj), expected)
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  public Void testRaw()
  {
    // make raw json
    buf := StrBuf.make
    buf.add("\n{\n  \"type\"\n:\n\"Foobar\",\n \n\n\"age\"\n:\n34,    \n\n\n\n")
    buf.add("\t\"nested\"\t:  \n{\t \"ids\":[3.28, 3.14, 2.14],  \t\t\"dead\":false\n\n,")
    buf.add("\t\n \"friends\"\t:\n null\t  \n}\n\t\n}")
    str := buf.toStr

    // parse
    Str:Obj? map := JsonInStream(str.in).readJson

    // verify
    verifyEq(map["type"], "Foobar")
    verifyEq(map["age"], 34)
    inner := (Str:Obj?) map["nested"]
    verifyNotEq(inner, null)
    verifyEq(inner["dead"], false)
    verifyEq(inner["friends"], null)
    list := (List)inner["ids"]
    verifyNotEq(list, null)
    verifyEq(list.size, 3)
    verifyEq(map["friends"], null)
  }

  public Void testEscapes()
  {
    Str:Obj obj := JsonInStream(
      Str<|{
           "foo"   : "bar\nbaz",
           "bar"   : "_\r \t \u0abc \\ \/_",
           "baz"   : "\"hi\"",
           "num"   : 1234,
           "bool"  : true,
           "float" : 2.4,
           "dollar": "$100 \u00f7",
           "a\nb"  : "crazy key"
           }|>.in).readJson

    f := |->|
    {
      verifyEq(obj["foo"], "bar\nbaz")
      verifyEq(obj["bar"], "_\r \t \u0abc \\ /_")
      verifyEq(obj["baz"], Str<|"hi"|>)
      verifyEq(obj["num"], 1234)
      verifyEq(obj["bool"], true)
      verify(2.4f.approx(obj["float"]))
      verifyEq(obj["dollar"], "\$100 \u00f7")
      verifyEq(obj["a\nb"], "crazy key")
      verifyEq(obj.keys.join(","), "foo,bar,baz,num,bool,float,dollar,a\nb")
    }

    f()
    buf := Buf()
    JsonOutStream(buf.out).writeJson(obj)
    obj = JsonInStream(buf.flip.in).readJson
    f()
  }

}

**************************************************************************
** SerialA
**************************************************************************

@Serializable
internal class SerialA
{
  Bool b := true
  Int i := 7
  Float f := 5f
  Str s := "string\n"
  @Transient Int noGo := 99
  Int[] ints  := [1, 2, 3]
}