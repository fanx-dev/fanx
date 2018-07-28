//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 May 08  Brian Frank  Creation
//

**
** MimeTypeTest
**
class MimeTypeTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  Void testIdentity()
  {
    verifyEq(MimeType("text/plain"), MimeType("text/plain"))
    verifyEq(MimeType("text/PLAIN"), MimeType("text/plain"))
    verifyEq(MimeType("TEXT/plain"), MimeType("text/plain"))
    verifyEq(MimeType("text/plain; a=b; C=d"), MimeType("text/plain;A = b;c = d;"))
    verifyNotEq(MimeType("text/html"), MimeType("text/plain"))
    verifyNotEq(MimeType("text/plain; charset=utf-8"), MimeType("text/plain; charset=us-ascii"))
    verifyNotEq(MimeType("x/y; a=b"), MimeType("x/y; a=B"))
  }

//////////////////////////////////////////////////////////////////////////
// Predefined
//////////////////////////////////////////////////////////////////////////

  Void testPredefined()
  {
    verifyPredefined("image", "gif")
    verifyPredefined("image", "png")
    verifyPredefined("image", "jpeg")
    verifyPredefined("text", "plain")
    verifyPredefined("text", "html")
    verifyPredefined("text", "xml")
    verifyPredefined("x-directory", "normal")

    verifyPredefinedText("text/plain; charset=utf-8")
    verifyPredefinedText("text/html; charset=utf-8")
    verifyPredefinedText("text/xml; charset=utf-8")
  }

  Void verifyPredefined(Str media, Str sub)
  {
    m := MimeType("$media/$sub")
    verifyEq(m.mediaType, media)
    verifyEq(m.subType, sub)
    verifyEq(m.toStr, "$media/$sub")
    verifyEq(m.params.isRO, true)
    verifyEq(m.params.size, 0)
    verifySame(m, MimeType(m.toStr))
  }

  Void verifyPredefinedText(Str mime)
  {
    m := MimeType(mime)
    verifyEq(m.mediaType, "text")
    verifyEq(m.params.isRO, true)
    verifyEq(m.toStr, mime)
    verifyEq(m.params["charset"], "utf-8")
    verifyEq(m.params["Charset"], "utf-8")
    verifyEq(m.params["CHARSET"], "utf-8")
    verifySame(m, MimeType(mime))
  }

//////////////////////////////////////////////////////////////////////////
// FromStr
//////////////////////////////////////////////////////////////////////////

  Void testFromStr()
  {
    verifyFromStr("text/plain", "text", "plain", null)
    verifyFromStr("Text/PLAIN", "text", "plain", null)
    verifyFromStr("Text/Plain; charset=utf-8", "text", "plain", ["charset":"utf-8"])
    verifyFromStr("Text/Plain ; charset=utf-8", "text", "plain", ["charset":"utf-8"])
    verifyFromStr("Text/Plain; charset=utf-8;", "text", "plain", ["charset":"utf-8"])
    verifyFromStr("Text/Plain;charset=utf-8 ;", "text", "plain", ["charset":"utf-8"])
    verifyFromStr("Text/Plain; a=b; c=d", "text", "plain", ["a":"b", "c":"d"])
    verifyFromStr("Text/Plain; a=b ; c = d;", "text", "plain", ["a":"b", "c":"d"])
    verifyFromStr("Text/Plain; a=\"q\"", "text", "plain", ["a":"q"])
    verifyFromStr("Text/Plain; a=\"q;x\"", "text", "plain", ["a":"q;x"])
    verifyFromStr("a/b; foo=\"bar==baz;\"", "a", "b", ["foo":"bar==baz;"])
    verifyFromStr("a/b; foo = \"bar==baz;\"; x=z", "a", "b", ["foo":"bar==baz;", "x":"z"])
    verifyFromStr("a/b; Foo=\"Bar==Baz;\"; x = Z ; y=\"=;\" ;", "a", "b", ["foo":"Bar==Baz;", "x":"Z", "y":"=;"])
    verifyFromStr("a/b; charset=foo (comment)", "a", "b", ["charset":"foo (comment)"])

    verifyFromStrBad("foo")
    verifyFromStrBad("a/b; x=")
  }

  Void verifyFromStr(Str s, Str media, Str sub, [Str:Str]? params)
  {
    if (params == null) params = Str:Str[:]
    t := MimeType.fromStr(s)
    //verifyEq(t.toStr, s)
    verifyEq(t.mediaType, media)
    verifyEq(t.subType, sub)
    verifyEq(t.params, params)
    //verifyEq(t.params.caseInsensitive, true)
    verifyEq(t.params.isRO, true)
  }

  Void verifyFromStrBad(Str s)
  {
    //verifyEq(MimeType.fromStr(s, false), null)
    verifyErr(ParseErr#) { x := MimeType.fromStr(s) }
    //verifyErr(ParseErr#) { x := MimeType.fromStr(s, true) }
  }

//////////////////////////////////////////////////////////////////////////
// ParseParams
//////////////////////////////////////////////////////////////////////////

  Void testParseParams()
  {
    verifyParseParams("", Str:Str[:])
    verifyParseParams("n=v", ["n":"v"])
    verifyParseParams("a= b; c = d;", ["a":"b", "c":"d"])
    verifyParseParams("aaa = \"bbb\"; ccc=\"ddd\"", ["aaa":"bbb", "ccc":"ddd"])
    verifyParseParams("aaa = \"bbb\"; ccc=\"ddd\"", ["aaa":"bbb", "ccc":"ddd"])
    verifyParseParams("name=\"a=b;c=d\"", ["name":"a=b;c=d"])
    //verifyParseParams("name=\"_\\\"quoted\\\"_\"", ["name":"_\"quoted\"_"])
    //verifyParseParams("a=\"quot=\\\"\"; b=c; d=\"bs=\\\\\"; e=\"_\\\\\\\"_\"", ["a":"quot=\"", "b":"c", "d":"bs=\\", "e":"_\\\"_"])
    verifyParseParams("a=\"\"; b=\"\"; c=\"foo\"", ["a":"", "b":"", "c":"foo"])
    verifyParseParams("a=\"\"; b=\"foo\"; c=\"\"", ["a":"", "b":"foo", "c":""])
    verifyParseParams("x=f (comment)", ["x":"f (comment)"])

    verifyParseParams("a", ["a":""])
    verifyParseParams("ax", ["ax":""])
    verifyParseParams("axy", ["axy":""])
    verifyParseParams("a; b", ["a":"", "b":""])
    verifyParseParams("ax; by", ["ax":"", "by":""])
    verifyParseParams("ax ;  by ", ["ax":"", "by":""])
    verifyParseParams("a=b; c", ["a":"b", "c":""])
    verifyParseParams("a=b; cx", ["a":"b", "cx":""])

    // not sure this is actually correctly formatted to have equals
    // in unquoted values, but have seen Chrome send cookies like this
    verifyParseParams("""a=sdecbc682; tz=America/New_York; b="05df13cc-9ef1"; c=MDI1MzE=; d=ABC=""",
      ["a": "sdecbc682",
       "tz": "America/New_York",
       "b":  "05df13cc-9ef1",
       "c":  "MDI1MzE=",
       "d":  "ABC="])

    verifyEq(MimeType.parseParams("n=", false), null)
    verifyErr(ParseErr#) { MimeType.parseParams("x=f;y=") }
  }

  Void verifyParseParams(Str s, Str:Str params)
  {
    p := MimeType.parseParams(s)
    verifyEq(p, params)
    //verifyEq(p.caseInsensitive, true)
  }

//////////////////////////////////////////////////////////////////////////
// ForExt
//////////////////////////////////////////////////////////////////////////

  Void testForExt()
  {
    verifyEq(MimeType.forExt("txt"), MimeType("text/plain; charset=utf-8"))
    verifyEq(MimeType.forExt("xml"), MimeType("text/xml; charset=utf-8"))
    verifyEq(MimeType.forExt("XML"), MimeType("text/xml; charset=utf-8"))
    verifyEq(MimeType.forExt("gif"), MimeType("image/gif"))
    verifyEq(MimeType.forExt("foobar"), null)
    //verifyEq(MimeType.forExt(null), null)
  }

//////////////////////////////////////////////////////////////////////////
// Charset
//////////////////////////////////////////////////////////////////////////

  Void testCharset()
  {
    verifyEq(MimeType("text/plain; charset=UTF-16BE").charset, Charset.utf16BE)
    verifyEq(MimeType("text/html").charset, Charset.utf8)
  }

//////////////////////////////////////////////////////////////////////////
// No Params
//////////////////////////////////////////////////////////////////////////

  Void testNoParams()
  {
    x := MimeType("text/plain")
    verifySame(x.noParams, x)
    x = MimeType("text/something")
    verifySame(x.noParams, x)
    verifyEq(MimeType("text/plain; charset=UTF-16BE").noParams, MimeType("text/plain"))
    verifyEq(MimeType("image/gif; foo=bar; baz=roo").noParams, MimeType("image/gif"))
  }

}