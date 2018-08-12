//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2018-08-12  Jed Young  Creation
//

class JsonTest : Test
{
  Void testParse() {
    str := Str<|{
                 "str"   : "abc",
                 "list"   : [ "x", "y" ],
                 "map"   : { "a" : 1, "b" : 2 },
                 "int"   : 1234,
                 "bool"  : true,
                 "float" : 2.4,
                 "encode" : "你好",
                  nonstandard : "std"
                 }|>
    val := JVal.readJson(str)

    res2 := val.xpath("map/a")
    verifyEq(res2.asInt, 1)

    res1 := val.xpath("list[1]")
    verifyEq(res1.asStr, "y")

    jstr := val.writeJson
    echo(jstr)
  }

}