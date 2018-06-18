//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Jun 06  Brian Frank  Creation
//

**
** UriTest
**
class UriTest : Test
{
//////////////////////////////////////////////////////////////////////////
// Def Val
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifyEq(Uri.defVal, ``)
    verifyEq(Uri#.make, ``)
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    // equals
    verifyUriEq(Uri.fromStr("http://u@foo:88/a/b?q#f"), Uri.fromStr("http://u@foo:88/a/b?q#f"));
    verifyUriEq(`http://foo/`, Uri.fromStr("http://foo/"));
    verifyUriEq(`http://u@foo:88/a/b?q#f`, `http://u@foo:88/a/b?q#f`);
    verifySame(`http://u@foo:88/a/b?q#f`, `http://u@foo:88/a/b?q#f`);

    // case difference in each component
    verifyUriEq(`Http://u@foo:88/a/b?q#f`, `http://u@foo:88/a/b?q#f`);
    verifyNotEq(`http://u@foo:88/A/b?q#f`, `http://u@foo:88/a/b?q#f`);
    verifyNotEq(`http://u@foo:88/a/b?Q#f`, `http://u@foo:88/a/b?q#f`);
    verifyNotEq(`http://u@foo:88/a/b?q#F`, `http://u@foo:88/a/b?q#f`);
    verifyNotEq(`http://Foo/`, `http://foo/`);
  }

//////////////////////////////////////////////////////////////////////////
// Kitchen Sink
//////////////////////////////////////////////////////////////////////////

  Void testKitchenSink()
  {
    uri := `http://user@host:88/a/b/c.txt?a=b&c=d#frag`
    verifyEq(uri.scheme,   "http")
    verifyEq(uri.auth,     "user@host:88")
    verifyEq(uri.host,     "host")
    verifyEq(uri.port,     88)
    verifyEq(uri.userInfo, "user")
    verifyEq(uri.path,     ["a", "b", "c.txt"])
    verifyEq(uri.pathStr,  "/a/b/c.txt")
    verifyEq(uri.name,     "c.txt")
    verifyEq(uri.basename, "c")
    verifyEq(uri.ext,      "txt")
    verifyEq(uri.mimeType, MimeType.fromStr("text/plain; charset=utf-8"))
    verifyEq(uri.query,    ["a":"b", "c":"d"])
    verifyEq(uri.queryStr, "a=b&c=d")
    verifyEq(uri.frag,     "frag")
    verifyEq(uri.toStr,    "http://user@host:88/a/b/c.txt?a=b&c=d#frag")
    verifyEq(uri.toLocale, "http://user@host:88/a/b/c.txt?a=b&c=d#frag")
  }

//////////////////////////////////////////////////////////////////////////
// Encoding
//////////////////////////////////////////////////////////////////////////

  Void testEncoding()
  {
    s  := "a+b://c + \u30A2@d + \u00c0/a:b;/%\u009a%?a=b+ \u00ff#f[?g"
    u1 := `a+b://c + \u30A2@d + \u00c0/a:b;/%\u009a%?a=b+ \u00ff#f[?g`
    u2 := Uri.fromStr(s)
    verifyUriEq(u1, u2);
    [u1, u2].each |Uri u|
    {
      verifyEq(s.toStr, s)
      //verifyEq(s.toLocale, s)
      verifyEq(u.scheme, "a+b")
      verifyEq(u.userInfo, "c + \u30A2")
      verifyEq(u.host, "d + \u00c0")
      verifyEq(u.host, "d + \u00c0")
      verifyEq(u.pathStr, "/a:b;/%\u009a%")
      verifyEq(u.path[0], "a:b;")
      verifyEq(u.path[1], "%\u009a%")
      verifyEq(u.queryStr, "a=b+ \u00ff")
      verifyEq(u.query["a"], "b+ \u00ff")
      verifyEq(u.frag, "f[?g")
      verifyEq(u.encode, "a+b://c%20+%20%E3%82%A2@d%20+%20%C3%80/a:b;/%25%C2%9A%25?a=b%2B+%C3%BF#f%5B?g")
      verifyEq(Uri.decode(u.encode), u)
      verifyEq(Uri.decode(u.encode.lower), u)
      verifyEq(Uri.decode(u.encode).toStr, s)
    }

    x := Uri.decode("/foo.png?q_w#f-g~h")
    verifyEq(x.path[0], "foo.png")
    verifyEq(x.basename, "foo")
    verifyEq(x.ext, "png")
    verifyEq(x.mimeType, MimeType("image/png"))
    verifyEq(x.queryStr, "q_w")
    verifyEq(x.frag, "f-g~h")

    verifyEq(Uri.decode(s, false), null)
    verifyErr(ParseErr#) { Uri.decode(s) }
    verifyErr(ParseErr#) { Uri.decode(s, true) }
    verifyErr(ParseErr#) { Uri.decode("/a%") }
    verifyErr(ParseErr#) { Uri.decode("/a%C") }
    verifyErr(ParseErr#) { Uri.decode("http://user^host/") }
    verifyErr(ParseErr#) { Uri.decode("http://foo:aa/") }
    verifyErr(ParseErr#) { Uri.decode("http://foo/a?h g") }
    verifyErr(ParseErr#) { Uri.decode("a b") }
    verifyErr(ParseErr#) { Uri.decode("a#g#h") }
  }

//////////////////////////////////////////////////////////////////////////
// Query Encoding
//////////////////////////////////////////////////////////////////////////

  Void testQueryEncoding()
  {
    verifyQueryEncoding(
      "x=h2%0D%0A%3D%3D",
      ["x":"h2\r\n=="])

    verifyQueryEncoding(
      "xyz=a%7E%21%40%23%24%25%5C%5E%26*%28+%29%3F%3B%3D%7C&flag",
      ["xyz":Str<|a~!@#$%\^&*( )?;=||>, "flag":"true"], false)

    verifyQueryEncoding(
      "a%3D%3B%26=foo_%5E%25%24%5Cdog",
      ["a=;&":"foo_^%\$\\dog"], false)

    verifyQueryEncoding(
      "a%3D%3B%26=foo_%5E%25%24%5C%0D%0Adog",
      ["a=;&":"foo_^%\$\\\r\ndog"], false)

    verifyQueryEncoding(
      "u+c=%D0%99",
      ["u c":"\u0419"])

    verifyQueryEncoding(
      "u+c=%5C%E8%91%89%26+%3D%E5%8F%B6",
      ["u c":"\\\u8449& =\u53F6"])

    verifyQueryEncoding(
      "a%3D%3B%26=foo_%5E%25%24%5C%0D%0Adog&b%3D%3B%26=%CE%94%EB%A7%90",
      ["a=;&":"foo_^%\$\\\r\ndog",
      "b=;&":"\u0394\uB9D0"], false)

    verifyQueryEncoding(
      "d=egg&coo&a=b",
      ["d":"egg", "coo":"true", "a":"b"])

    verifyQueryEncoding(
      "a=boo+hoo&%E3%82%A2=%c3%a9!",
      ["a":"boo hoo", "\u30A2":"\u00e9!"])

    // Safari tests which encode unnamed form elements as ""

    verifyQueryEncoding(
      "=x",
      ["":"x"])

    verifyQueryEncoding(
      "a=b;=x",
      ["a":"b", "":"x"])

    verifyQueryEncoding(
      "=x;alpha=beta;q=z;foo=bar",
      ["alpha":"beta", "":"x", "q":"z", "foo":"bar"])

    verifyEq(Uri.encodeQuery(["key":"a b c"]), "key=a+b+c")
    verifyEq(Uri.decodeQuery("key=a+b+c"), ["key":"a b c"])
    verifyEq(`foo?key=a b c`.encode, "foo?key=a+b+c")
    verifyEq(Uri.decode("foo?key=a+b+c"), `foo?key=a b c`)
  }

  Void verifyQueryEncoding(Str encoded, Str:Str q, Bool exact := true)
  {
    a := Uri.decodeQuery(encoded)
    verifyEq(a, q)
    roundtrip := Uri.decodeQuery(Uri.encodeQuery(q))
    verifyEq(roundtrip, q)

    qci := CIMap<Str,Str>()
    q.each |v, k| { qci[k] = v }
    verifyEq(Uri.encodeQuery(qci), Uri.encodeQuery(q))

    uri := Uri.decode("?$encoded")
    if (exact) verify(uri.encode[1..-1].equalsIgnoreCase(encoded))
    verifyUriEq(uri, Uri.fromStr(uri.toStr))
    verifyUriEq(uri, Uri.decode(uri.encode))
    verifyEq(uri.query, q)
  }

//////////////////////////////////////////////////////////////////////////
// Abs Defaults
//////////////////////////////////////////////////////////////////////////

  Void testAbsDefaults()
  {
    uri := `http://host/a/b/c`
    verifyEq(uri.scheme,   "http")
    verifyEq(uri.auth,     "host")
    verifyEq(uri.host,     "host")
    verifyEq(uri.port,     null)
    verifyEq(uri.userInfo, null)
    verifyEq(uri.path,     ["a", "b", "c"])
    verifyEq(uri.pathStr,  "/a/b/c")
    verifyEq(uri.name,     "c")
    verifyEq(uri.basename, "c")
    verifyEq(uri.ext,      null)
    verifyEq(uri.mimeType, null)
    verifyEq(uri.query,    Str:Str[:])
    verifyEq(uri.queryStr, null)
    verifyEq(uri.frag,     null)
  }

//////////////////////////////////////////////////////////////////////////
// Scheme
//////////////////////////////////////////////////////////////////////////

  Void testScheme()
  {
    verifyScheme(`http://foo/`, "http");
    verifyScheme(`HTTP://foo/`, "http");
    verifyScheme(`mailto:who@there.com`, "mailto");
    verifyScheme(`MailTo:who@there.com`, "mailto");
    verifyScheme(`/a/b/c`, null);
    verifyScheme(`../a/b/c`, null);
    verifyScheme(`#frag`, null);
  }

  Void verifyScheme(Uri uri, Str? scheme)
  {
    verifyEq(uri.scheme, scheme)
    verifyEq(uri.isAbs, scheme != null)
    verifyEq(uri.isRel, scheme == null)
  }

//////////////////////////////////////////////////////////////////////////
// Auth (UserInfo, Host, Port)
//////////////////////////////////////////////////////////////////////////

  Void testAuth()
  {
    // combinations
    verifyAuth(`http://brian:pass@host:88/`, "brian:pass@host:88", "brian:pass", "host", 88)
    verifyAuth(`http://brian:pass@host/`, "brian:pass@host", "brian:pass", "host", null)
    verifyAuth(`http://host:88/`, "host:88", null, "host", 88)
    verifyAuth(`http://host/`, "host", null, "host", null)

    // host names
    verifyAuth(`http://HOST/#frag`, "HOST", null, "HOST", null)
    verifyAuth(`foo://www.foo.com:8080/a?q`, "www.foo.com:8080", null, "www.foo.com", 8080)
    verifyAuth(`http://www.foo-bar.com/index`, "www.foo-bar.com", null, "www.foo-bar.com", null)

    // IPv4 addresses
    verifyAuth(`http://10.89.255.0/#frag`, "10.89.255.0", null, "10.89.255.0", null)
    verifyAuth(`http://user@129.5.255.90:90/a/b`, "user@129.5.255.90:90", "user", "129.5.255.90", 90)
    // TODO - Java silently ignores invalid IP addresses like 256.256.256.256
    // verifyAuth(`http://256.256.256.256/`, "256.256.256.256", null, "256.256.256.256", null)

    // IPv6 addresses
    verifyAuth(`http://u@[2001:0db8:0000:0000:0000:0000:1428:57ab]:81/`, "u@[2001:0db8:0000:0000:0000:0000:1428:57ab]:81", "u", "[2001:0db8:0000:0000:0000:0000:1428:57ab]", 81)
    verifyAuth(`ftp://[2001:0db8:0000:0000:0000:0000:1428:57ab]/`, "[2001:0db8:0000:0000:0000:0000:1428:57ab]", null, "[2001:0db8:0000:0000:0000:0000:1428:57ab]", null)
    verifyAuth(`http://[::192.9.5.5]/`, "[::192.9.5.5]", null, "[::192.9.5.5]", null)

    // relative
    verifyAuth(`//u@foo:0/a/b/c`, "u@foo:0", "u", "foo", 0);
    verifyAuth(`//foo/a/b/c`, "foo", null, "foo", null);
    verifyAuth(`/a/b/c`, null, null, null, null);
    verifyAuth(`../a/b/c`, null, null, null, null);
    verifyAuth(`#frag`, null, null, null, null);
  }

  Void verifyAuth(Uri uri, Str? auth, Str? userInfo, Str? host, Int? port)
  {
    verifyEq(uri.auth, auth)
    verifyEq(uri.userInfo, userInfo)
    verifyEq(uri.host, host)
    verifyEq(uri.port, port)
  }

//////////////////////////////////////////////////////////////////////////
// Path
//////////////////////////////////////////////////////////////////////////

  Void testPath()
  {
    // none
    verifyPath(`mailto:me@there.com`, "me@there.com", ["me@there.com"])

    // absolute
    verifyPath(`http://host`, "/", Str[,])  // normalized
    verifyPath(`http://host/`, "/", Str[,])
    verifyPath(`http://host/a`, "/a", ["a"])
    verifyPath(`http://host/a/b`, "/a/b", ["a", "b"])
    verifyPath(`http://host/a/b/`, "/a/b/", ["a", "b"])
    verifyPath(`http://host/_a/_b`, "/_a/_b", ["_a", "_b"])

    // auth absolute
    verifyPath(`/`, "/", Str[,])
    verifyPath(`//host/`, "/", Str[,])
    verifyPath(`//host/a`, "/a", ["a"])
    verifyPath(`//host/a/`, "/a/", ["a"])
    verifyPath(`//host/a/b`, "/a/b", ["a", "b"])
    verifyPath(`//host/_a/_b`, "/_a/_b", ["_a", "_b"])

    // path absolute
    verifyPath(`/`, "/", Str[,])
    verifyPath(`/a`, "/a", ["a"])
    verifyPath(`/a/b`, "/a/b", ["a", "b"])

    // path relative
    verifyPath(``, "", Str[,])
    verifyPath(`a`, "a", ["a"])
    verifyPath(`a/b`, "a/b", ["a", "b"])

    // path dot
    verifyPath(`.`, ".", ["."])
    verifyPath(`./a`, "a", ["a"])
    verifyPath(`./a/b`, "a/b", ["a", "b"])

    // path backup
    verifyPath(`..`, "..", [".."])
    verifyPath(`../a`, "../a", ["..", "a"])
    verifyPath(`../a/b`, "../a/b", ["..", "a", "b"])

    // path backup
    verifyPath(`../..`, "../..", ["..", ".."])
    verifyPath(`../../a`, "../../a", ["..", "..", "a"])
    verifyPath(`../../a/b`, "../../a/b", ["..", "..", "a", "b"])
  }

  Void verifyPath(Uri uri, Str pathStr, Str[]? path)
  {
    verifyEq(uri.pathStr, pathStr)
    verifyEq(uri.path, path)
    if (path == null)
    {
      verifyEq(uri.isPathAbs, false)
      verifyEq(uri.isPathRel, true)
    }
    else
    {
      verifyEq(uri.isPathAbs, pathStr.startsWith("/"))
      verifyEq(uri.isPathRel, !pathStr.startsWith("/"))
      verifyEq(uri.path.isRO, true)
      verifyEq(uri.isDir, pathStr.size > 0 && pathStr[-1] == '/')
      if (uri.isDir) verifyEq(uri.mimeType.toStr, "x-directory/normal")
      if (path.size > 0) verifyEq(uri.name, path[-1])
    }

    verifyUriEq(Uri.fromStr(pathStr), uri.pathOnly)
    verifyUriEq(Uri.decode(uri.encode), uri)
  }

//////////////////////////////////////////////////////////////////////////
// PathOnly
//////////////////////////////////////////////////////////////////////////

  Void testIsPathOnly()
  {
    verifyEq(`http://foo:80@user/foo?q#frag`.isPathOnly, false)
    verifyEq(`http:foo`.isPathOnly, false)
    verifyEq(`//foo:80@user/foo`.isPathOnly, false)
    verifyEq(`//foo/foo`.isPathOnly, false)
    verifyEq(`//foo@user/foo`.isPathOnly, false)
    verifyEq(`/foo?q`.isPathOnly, false)
    verifyEq(`/foo#frag`.isPathOnly, false)

    verifyEq(`/`.isPathOnly, true)
    verifyEq(`/foo`.isPathOnly, true)
    verifyEq(`foo`.isPathOnly, true)
    verifyEq(`../foo`.isPathOnly, true)
  }

//////////////////////////////////////////////////////////////////////////
// Name
//////////////////////////////////////////////////////////////////////////

  Void testName()
  {
    // none
    verifyName(`mailto:me@there.com`, "me@there.com", "me@there", "com")

    // absolute roots
    verifyName(`http://host`, "", "", null)
    verifyName(`http://host/`, "", "", null)
    verifyName(`/`, "", "", null)

    // absolute names
    verifyName(`http://host/a`, "a", "a", null)
    verifyName(`http://host/a/`, "a", "a", null)
    verifyName(`http://host/a.`, "a.", "a", "")
    verifyName(`http://host/a.t`, "a.t", "a", "t")

    // relative paths
    verifyName(`alpha`, "alpha", "alpha", null)
    verifyName(`alpha.`, "alpha.", "alpha", "")
    verifyName(`alpha.txt`, "alpha.txt", "alpha", "txt")
    verifyName(`alpha.txt/`, "alpha.txt", "alpha", "txt")

    // dot
    verifyName(`.`, ".", ".", null)
    verifyName(`..`, "..", "..", null)
    verifyName(`../..`, "..", "..", null)
  }

  Void verifyName(Uri uri, Str name, Str basename, Str? ext)
  {
    verifyEq(uri.name, name)
    verifyEq(uri.basename, basename)
    verifyEq(uri.ext, ext)
  }

//////////////////////////////////////////////////////////////////////////
// Query
//////////////////////////////////////////////////////////////////////////

  Void testQuery()
  {
    // none
    none := Str:Str[:]
    verifyQuery(`mailto:brian@there.com`, null, none)
    verifyQuery(`mailto:brian?there?com`, "there?com", Str:Str["there?com":"true"])
    verifyQuery(`http://foo/index`, null, none)
    verifyQuery(`http://foo/index#frag`, null, none)
    verifyQuery(`/index`, null, none)

    // various prefixes
    verifyQuery(`http://foo/index?a=b&c=d#frag`, "a=b&c=d", ["a":"b", "c":"d"])
    verifyQuery(`http://foo/index?a=b&c=d`, "a=b&c=d", ["a":"b", "c":"d"])
    verifyQuery(`/index?a=b;c=d`, "a=b;c=d", ["a":"b", "c":"d"])
    verifyQuery(`file.txt?a=b;c=d`, "a=b;c=d", ["a":"b", "c":"d"])
    verifyQuery(`?a=b&c=d`, "a=b&c=d", ["a":"b", "c":"d"])

    // various combinations
    verifyQuery(`?a`, "a", Str:Str["a":"true"])
    verifyQuery(`?a_b!`, "a_b!", Str:Str["a_b!":"true"])
    verifyQuery(`?a=b`, "a=b", ["a":"b"])
    verifyQuery(`?a=beta`, "a=beta", ["a":"beta"])
    verifyQuery(`?alpha=b`, "alpha=b", ["alpha":"b"])
    verifyQuery(`?alpha=b;`, "alpha=b;", ["alpha":"b"])
    verifyQuery(`?alpha=b&`, "alpha=b&", ["alpha":"b"])
    verifyQuery(`?alpha=b;;&;&`, "alpha=b;;&;&", ["alpha":"b"])
    verifyQuery(`?alpha=b&c`, "alpha=b&c", Str:Str["alpha":"b", "c":"true"])
    verifyQuery(`?a=b&;&charlie;`, "a=b&;&charlie;", Str:Str["a":"b", "charlie":"true"])
    verifyQuery(`?x=1&x=2&y=9&x=3`, "x=1&x=2&y=9&x=3", Str:Str["x":"1,2,3", "y":"9"])
  }

  Void verifyQuery(Uri uri, Str? queryStr, Str:Str query)
  {
    verifyEq(uri.queryStr, queryStr)
    verifyEq(uri.query, query)
    verify(uri.query.isRO())
    verifyUriEq(Uri.decode(uri.encode), uri)
    verifyEq(Uri.decodeQuery(Uri.encodeQuery(query)), query)
  }

//////////////////////////////////////////////////////////////////////////
// Frag
//////////////////////////////////////////////////////////////////////////

  Void testFrag()
  {
    // none
    verifyFrag(`mailto:brian@there.com`, null)
    verifyFrag(`mailto:brian?there#com`, "com")
    verifyFrag(`http://foo/index`,  null)

    // combos
    verifyFrag(`http://foo/index?a=b&c=d#frag`, "frag")
    verifyFrag(`http://foo/index#frag`, "frag")
    verifyFrag(`//foo/index#f`, "f")
    verifyFrag(`file.txt#f_g`, "f_g")
    verifyFrag(`#h1`, "h1")
  }

  Void verifyFrag(Uri uri, Str? frag)
  {
    verifyEq(uri.frag, frag)
  }

//////////////////////////////////////////////////////////////////////////
// Parent
//////////////////////////////////////////////////////////////////////////

  Void testParent()
  {
    verifyParent(`http://foo:81/a/b/c/?query#frag`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c?query#frag`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c/?query`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c?query`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c/#frag`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c#frag`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c/`, `http://foo:81/a/b/`)
    verifyParent(`http://foo:81/a/b/c`, `http://foo:81/a/b/`)

    verifyParent(`http://foo/a/b/c/`, `http://foo/a/b/`)
    verifyParent(`http://foo/a/b/c`, `http://foo/a/b/`)

    verifyParent(`/a/b/c/`, `/a/b/`)
    verifyParent(`/a/b/c`, `/a/b/`)

    verifyParent(`a/b/c/`, `a/b/`)
    verifyParent(`a/b/c`, `a/b/`)

    verifyParent(`../a/b/c/`, `../a/b/`)
    verifyParent(`../a/b/c#frag`, `../a/b/`)

    verifyParent(`/a/`, `/`)
    verifyParent(`/a`,  `/`)

    verifyParent(`/`, null)
    verifyParent(`a.txt`, null)
    verifyParent(`a`, null)
    verifyParent(``, null)
  }

  Void verifyParent(Uri uri, Uri? parent)
  {
    verifyUriEq(uri.parent, parent)
  }

//////////////////////////////////////////////////////////////////////////
// Path Only
//////////////////////////////////////////////////////////////////////////

  Void testPathOnly()
  {
    verifyPathOnly(`http://host:90/a/b/c?query#frag`, `/a/b/c`)
    verifyPathOnly(`http://user@host/a/b/?queryfrag`, `/a/b/`)
    verifyPathOnly(`//foo/rock`, `/rock`)
    verifyPathOnly(`//foo:8/`, `/`)
    verifyPathOnly(`/alpha/`, `/alpha/`)
    verifyPathOnly(`../foo`, `../foo`)
    verifyPathOnly(`../foo#index`, `../foo`)
  }

  Void verifyPathOnly(Uri u, Uri expected)
  {
    r := u.pathOnly
    if (u == expected)
      verifySame(u, r)
    else
      verifyUriEq(expected, r)

    verifyEq(r.auth, null)
    verifyEq(r.scheme, null)
    verifyEq(r.userInfo, null)
    verifyEq(r.host, null)
    verifyEq(r.port, null)
    verifyEq(r.query.isEmpty, true)
    verifyEq(r.queryStr, null)
    verifyEq(r.frag, null)
  }

//////////////////////////////////////////////////////////////////////////
// Slice
//////////////////////////////////////////////////////////////////////////
/*
  Void testSlice()
  {
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..-1, `http://h:9/a/b/c?query#frag`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..-2, `http://h:9/a/b/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..-3, `http://h:9/a/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..-4, `http://h:9/`)
    verifyErr(IndexErr#) { x := `http://h:9/a/b/c?query#frag`[0..-5] }

    verifySlice(`http://h:9/a/b/c?query#frag`, 0..<-1, `http://h:9/a/b/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..<-2, `http://h:9/a/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..<-3, `http://h:9/`)
    verifyErr(IndexErr#) { x := `http://h:9/a/b/c?query#frag`[0..<-4] }

    verifySlice(`http://h:9/a/b/c?query#frag`, 0..2, `http://h:9/a/b/c?query#frag`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..1, `http://h:9/a/b/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..0, `http://h:9/a/`)

    verifySlice(`http://h:9/a/b/c?query#frag`, 0..<2, `http://h:9/a/b/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..<1, `http://h:9/a/`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 0..<0, `http://h:9/`)

    verifySlice(`http://h:9/a/b/c?query#frag`, 1..-1, `b/c?query#frag`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 2..-1, `c?query#frag`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 3..-1, `?query#frag`)

    verifySlice(`http://h:9/a/b/c?query#frag`, 1..2, `b/c?query#frag`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 2..<3, `c?query#frag`)
    verifySlice(`http://h:9/a/b/c?query#frag`, 3..<3, `?query#frag`)

    verifySlice(`aaa/bbb/ccc/`, 0..2, `aaa/bbb/ccc/`)
    verifySlice(`aaa/bbb/ccc/`, 0..1, `aaa/bbb/`)
    verifySlice(`aaa/bbb/ccc/`, 1..2, `bbb/ccc/`)
    verifySlice(`aaa/bbb/ccc/`, 0..0, `aaa/`)
    verifySlice(`aaa/bbb/ccc/`, 1..1, `bbb/`)
    verifySlice(`/a/b/c/d/e/`,  0..-1, `/a/b/c/d/e/`)
    verifySlice(`/a/b/c/d/e/`,  0..-3, `/a/b/c/`)
    verifySlice(`/a/b/c/d/e/`,  2..-1, `c/d/e/`)
    verifySlice(`/a/b/c/d/e/`,  2..-2, `c/d/`)
    verifySlice(`/a/b/c/d/e/`,  2..2, `c/`)

    verifySlice(`//host/x`,   0..-1, `//host/x`)
    verifySlice(`//host/x/`,  0..-1, `//host/x/`)
    verifySlice(`../x?query`, 0..-1, `../x?query`)
    verifySlice(`../x?query`, 0..-2, `../`)
    verifySlice(`../x?q=z`, 1..-1, `x?q=z`)
  }

  Void verifySlice(Uri uri, Range r, Uri expected)
  {
    slice := uri[r]
    if (uri == expected)
      verifySame(slice, uri)
    verifyUriEq(slice, expected)

    pa := uri.getRangeToPathAbs(r)
    if (expected.isPathAbs)
      verifyEq(pa, expected)
    else
      verifyEq(pa, "/$expected".toUri)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Norm
//////////////////////////////////////////////////////////////////////////

  Void testNorm()
  {
    // abs
    verifyNorm("http://foo:81/path?q#f", `http://foo:81/path?q#f`)
    verifyNorm("http://foo", `http://foo/`)
    verifyNorm("http://foo:80/x", `http://foo/x`)
    verifyNorm("HTTP://foo:80", `http://foo/`)
    verifyNorm("http://foo/.", `http://foo/`)
    verifyNorm("http://foo/..", `http://foo/..`)
    verifyNorm("http://foo/a/..", `http://foo/`)
    verifyNorm("Http://foo:80/a/../..", `http://foo/..`)
    verifyNorm("HTTP://foo/a/b/c/../..", `http://foo/a/`)
    verifyNorm("https://foo:443", `https://foo/`)
    verifyNorm("HTTPS://foo:443/x", `https://foo/x`)
    verifyNorm("FTP://foo:21", `ftp://foo/`)
    verifyNorm("ftp://foo:21/x", `ftp://foo/x`)

    // relative
    verifyNorm("", ``)
    verifyNorm(".", `.`)
    verifyNorm("..", `..`)
    verifyNorm("a/..", ``)
    verifyNorm("a/../..", `..`)
    verifyNorm("a/b/c/../..", `a/`)
    verifyNorm("a/./b/c/../d..", `a/b/d..`)
    verifyNorm("/a/./b/../../d..", `/d..`)
    verifyNorm("a/./b/../c/d../", `a/c/d../`)

    // escapes
    verifyNorm(Str<|x\yz|>, `xyz`)
    verifyNorm(Str<|x\/z|>, `x\/z`)
    verifyNorm(Str<|\.|>, `.`)
    verifyNorm(Str<|.\.|>, `..`)
    verifyNorm(Str<|foo/bar/..|>, `foo/`)
    verifyNorm(Str<|foo/bar/baz/..|>, `foo/bar/`)
    verifyNorm(Str<|foo/bar/baz/\../..|>, `foo/`)
    verifyNorm(Str<|foo/bar/baz/../.\./..|>, ``)
    verifyNorm(Str<|foo/bar/baz/../\../\../..|>, `..`)
    verifyNorm(Str<|foo/bar/baz/\../\../\../\../roo|>, `../roo`)
    verifyNorm(Str<|foo/bar/baz/\../../roo|>, `foo/roo`)
    verifyEq(Uri.decode(Str<|%2e%2e/foo|>), `../foo`)
    verifyEq(Uri.decode(Str<|oo/bar/baz/%2e%2e/%2e%2e/%2e%2e/%2e%2e/roo|>), `../roo`)
    verifyEq(Uri.decode(Str<|%5c|>), Uri.fromStr(Str<|\\|>))
    verifyEq(Uri.decode(Str<|%5c%5c|>), Uri.fromStr(Str<|\\\\|>))
    verifyEq(Uri.decode(Str<|%5c..|>), Uri.fromStr(Str<|\\..|>))
    verifyEq(Uri.decode(Str<|%5c%5c..|>), Uri.fromStr(Str<|\\\\..|>))

    verifyEq(`.`.path, ["."])
    verifyEq(`.`.pathStr, ".")
    verifyEq(`..`.path, [".."])
    verifyEq(`..`.pathStr, "..")
    verifyEq(`../..`.path, ["..", ".."])
    verifyEq(`../..`.pathStr, "../..")
    verifyEq(`x/.`.path, ["x"])
    verifyEq(`x/.`.pathStr, "x/")
  }

  Void verifyNorm(Str unnorm, Uri norm)
  {
    uri := Uri.fromStr(unnorm)
    verifyUriEq(uri, norm)
  }

//////////////////////////////////////////////////////////////////////////
// Plus
//////////////////////////////////////////////////////////////////////////

  Void testPlus()
  {
    // abs + abs
    verifyPlus(`http://foo:81/path?q#f`, `http://bar:82/p?q2#f2`, `http://bar:82/p?q2#f2`)
    verifyPlus(`http://foo:81/path?q#f`, `mailto:joe@there.com`, `mailto:joe@there.com`)
    verifyPlus(`http://foo/path`, `http://bar/`, `http://bar/`)

    // rel + abs
    verifyPlus(`/a/b/c`, `http://bar:82/p?q2#f2`, `http://bar:82/p?q2#f2`)
    verifyPlus(`/path?q#f`, `mailto:joe@there.com`, `mailto:joe@there.com`)

    // abs + rel /path
    verifyPlus(`http://foo:81/path?q#f`, `/newpath`, `http://foo:81/newpath`)
    verifyPlus(`http://foo:81/path`, `/a/b/c`, `http://foo:81/a/b/c`)
    verifyPlus(`http://foo/`, `/a?query`, `http://foo/a?query`)

    // abs + rel path
    verifyPlus(`http://foo/path?q#f`, `newpath`, `http://foo/newpath`)
    verifyPlus(`http://foo/path/?q#f`, `newpath`, `http://foo/path/newpath`)
    verifyPlus(`http://foo/`, `a/b/c`, `http://foo/a/b/c`)
    verifyPlus(`http://foo/root`, `a/b/c`, `http://foo/a/b/c`)
    verifyPlus(`http://foo/root/`, `a/b/c`, `http://foo/root/a/b/c`)
    verifyPlus(`http://foo/root/`, `../a`, `http://foo/a`)

    // abs + query
    verifyPlus(`http://foo/path?q#f`, `?newquery`, `http://foo/path?newquery`)
    verifyPlus(`http://foo/path/?q#f`, `?newquery`, `http://foo/path/?newquery`)
    verifyPlus(`http://foo/path/`, `?newquery`, `http://foo/path/?newquery`)

    // abs + frag
    verifyPlus(`http://foo/path?q#f`, `#newfrag`, `http://foo/path?q#newfrag`)
    verifyPlus(`http://foo/`, `#newfrag`, `http://foo/#newfrag`)

    // rel + rel
    verifyPlus(`a/b/c`, `d`, `a/b/d`)
    verifyPlus(`a/b/c/`, `d`, `a/b/c/d`)
    verifyPlus(`a/b/c`, `./d`, `a/b/d`)
    verifyPlus(`a/b/c/`, `./d`, `a/b/c/d`)
    verifyPlus(`a/b/c`, `../d`, `a/d`)
    verifyPlus(`a/b/c/`, `../d`, `a/b/d`)
    verifyPlus(`a/b/c`, `../../d`, `d`)
    verifyPlus(`a/b/c/`, `../../d`, `a/d`)
    verifyPlus(`a/b/c`, `../../../d`, `../d`)
    verifyPlus(`a/b/c/`, `../../../d`, `d`)

    // misc
    verifyPlus(`/c:/dev/fan/`, `tmp/test/`, `/c:/dev/fan/tmp/test/`)
    verifyPlus(`https://example.org/`, `/.`, `https://example.org/`)
  }

  Void testPlusRfc3986()
  {
    // test cases as defined by RFC 3986
    a := `http://a/b/c/d;p?q`

    // 5.4.1. Normal Examples
    verifyPlus(a, `g:h`     , `g:h`)
    verifyPlus(a, `g`       , `http://a/b/c/g`)
    verifyPlus(a, `./g`     , `http://a/b/c/g`)
    verifyPlus(a, `g/`      , `http://a/b/c/g/`)
    verifyPlus(a, `/g`      , `http://a/g`)
    verifyPlus(a, `//g`     , `http://g/`) // derivation b/c normalization
    verifyPlus(a, `?y`      , `http://a/b/c/d;p?y`)
    verifyPlus(a, `g?y`     , `http://a/b/c/g?y`)
    verifyPlus(a, `#s`      , `http://a/b/c/d;p?q#s`)
    verifyPlus(a, `g#s`     , `http://a/b/c/g#s`)
    verifyPlus(a, `g?y#s`   , `http://a/b/c/g?y#s`)
    verifyPlus(a, `;x`      , `http://a/b/c/;x`)
    verifyPlus(a, `g;x`     , `http://a/b/c/g;x`)
    verifyPlus(a, `g;x?y#s` , `http://a/b/c/g;x?y#s`)
    verifyPlus(a, ``        , `http://a/b/c/d;p?q`)
    verifyPlus(a, `.`       , `http://a/b/c/`)
    verifyPlus(a, `./`      , `http://a/b/c/`)
    verifyPlus(a, `..`      , `http://a/b/`)
    verifyPlus(a, `../`     , `http://a/b/`)
    verifyPlus(a, `../g`    , `http://a/b/g`)
    verifyPlus(a, `../..`   , `http://a/`)
    verifyPlus(a, `../../`  , `http://a/`)
    verifyPlus(a, `../../g` , `http://a/g`)

    // 5.4.1. Abnormal Examples
    verifyPlus(a, `../../../g`    , `http://a/g`)
    verifyPlus(a, `../../../../g` , `http://a/g`)
    // we're not going to support this weird case
    // verifyPlus(a, `/./g`          , `http://a/g`)
    // verifyPlus(a, `/../g`         , `http://a/g`)
    verifyPlus(a, `g.`            , `http://a/b/c/g.`)
    verifyPlus(a, `.g`            , `http://a/b/c/.g`)
    verifyPlus(a, `g..`           , `http://a/b/c/g..`)
    verifyPlus(a, `..g`           , `http://a/b/c/..g`)
    verifyPlus(a, `./../g`        , `http://a/b/g`)
    verifyPlus(a, `./g/.`         , `http://a/b/c/g/`)
    verifyPlus(a, `g/./h`         , `http://a/b/c/g/h`)
    verifyPlus(a, `g/../h`        , `http://a/b/c/h`)
    verifyPlus(a, `g;x=1/./y`     , `http://a/b/c/g;x=1/y`)
    verifyPlus(a, `g;x=1/../y`    , `http://a/b/c/y`)
    verifyPlus(a, `g?y/./x`       , `http://a/b/c/g?y/./x`)
    verifyPlus(a, `g?y/../x`      , `http://a/b/c/g?y/../x`)
    verifyPlus(a, `g#s/./x`       , `http://a/b/c/g#s/./x`)
    verifyPlus(a, `g#s/../x`      , `http://a/b/c/g#s/../x`)
  }

  Void verifyPlus(Uri a, Uri b, Uri r)
  {
    x := a + b
    verifyUriEq(x, r)
    verify(x.path.isRO)
    verify(x.query.isRO)
  }

//////////////////////////////////////////////////////////////////////////
// Plus Name
//////////////////////////////////////////////////////////////////////////

  Void testPlusName()
  {
    verifyPlusName(`http://u/`,          "foo",  `http://u/foo`)
    verifyPlusName(`http://u`,           "foo",  `http://u/foo`)
    verifyPlusName(`fan://icons/`,       "foo",  `fan://icons/foo`)
    verifyPlusName(`fan://icons`,        "foo",  `fan://icons/foo`)
    verifyPlusName(`http://u@h:9/x`,     "foo",  `http://u@h:9/foo`)
    verifyPlusName(`http://u@h:9/x/`,    "foo",  `http://u@h:9/x/foo`)
    verifyPlusName(`http://u@h:9/x?y=z`, "foo",  `http://u@h:9/foo`)
    verifyPlusName(`http://u@h:9/x/#f`,  "foo",  `http://u@h:9/x/foo`)
    verifyPlusName(`//wow/a/b/c`,        "d",    `//wow/a/b/d`)
    verifyPlusName(`../dir/`,            "goo/", `../dir/goo/`)
    verifyPlusName(`/`,                  "goo/", `/goo/`)
    verifyPlusName(`file`,               "x",    `x`)
    verifyPlusName(`dir/`,               "x y",  `dir/x y`)
  }

  Void verifyPlusName(Uri a, Str n, Uri r)
  {
    asDir := false
    if (n[-1] == '/') { asDir = true; n = n[0..-2] }
    x := a.plusName(n, asDir)
    if (!asDir) verifyEq(x, a.plusName(n))
    verifyUriEq(x, r)
  }

//////////////////////////////////////////////////////////////////////////
// Plus Slash
//////////////////////////////////////////////////////////////////////////

  Void testPlusSlash()
  {
    verifyPlusSlash(`http://u@h:9/`, `http://u@h:9/`)
    verifyPlusSlash(`http://u@h:9/?q`, `http://u@h:9/?q`)
    verifyPlusSlash(`http://u@h:9/#f`, `http://u@h:9/#f`)

    verifyPlusSlash(`http://u@h:9/x`, `http://u@h:9/x/`)
    verifyPlusSlash(`http://u@h:9/x?q`, `http://u@h:9/x/?q`)
    verifyPlusSlash(`http://u@h:9/x#f`, `http://u@h:9/x/#f`)

    verifyPlusSlash(``, `/`)
    verifyPlusSlash(`/`, `/`)
    verifyPlusSlash(`a`, `a/`)
    verifyPlusSlash(`a/`, `a/`)
    verifyPlusSlash(`a/b`, `a/b/`)
    verifyPlusSlash(`a/b/`, `a/b/`)
    verifyPlusSlash(`/x`, `/x/`)
    verifyPlusSlash(`/x/y`, `/x/y/`)

    verifyPlusSlash(`..`, `../`)
    verifyPlusSlash(`..?q`, `../?q`)
    verifyPlusSlash(`../foo?q`, `../foo/?q`)
  }

  Void verifyPlusSlash(Uri a, Uri r)
  {
    if (a == r)
      verifySame(a.plusSlash, r)
    else
      verifyUriEq(a.plusSlash, r)
  }

//////////////////////////////////////////////////////////////////////////
// Plus Query
//////////////////////////////////////////////////////////////////////////

  Void testPlusQuery()
  {
    // NOTE: since these tests are dependent on map ordering,
    // we code the test cases to deal with various orders

    verifyPlusQuery(`http://u@h:9/`, ["a":"b"], "http://u@h:9/?")

    verifyPlusQuery(`http://u@h:9/?a=z`, ["a":"b"], "http://u@h:9/?")

    verifyPlusQuery(`http://u@h:9/?x=y`, ["a":"b"], "http://u@h:9/?")

    verifyPlusQuery(`/foo?x=y`, ["a":"b","c":"d"], "/foo?")

    verifyPlusQuery(`/foo.txt?x=y`, ["a":"b","c":"d"], "/foo.txt?")

    verifyPlusQuery(`/foo.txt?d=z&x=y`, ["a":"b","c":"d"], "/foo.txt?")

    verifyPlusQuery(`?`, ["x":"q::n"], "?")

    verifyPlusQuery(`?`, ["x":"=& ;#"], "?")

    verifyPlusQuery(`?`, ["a=b":"\u0345"], "?")

    verifyPlusQuery(`?a=x \&\\`, ["b":"#"], "?")
  }

  Void verifyPlusQuery(Uri u, Str:Str q, Str expectedBase)
  {
    a := u.plusQuery(q)

    // we can't rely on hash order across VMs
    queryStr := StrBuf.make
    qAll := u.query.dup.setAll(q)
    qAll.keys.each |Str k|
    {
      v := qAll[k]
      if (!queryStr.isEmpty) queryStr.addChar('&')
      queryStr.add(escQuery(k)).addChar('=').add(escQuery(v))
    }
    r := (expectedBase + queryStr).toUri

    verify(a.query.isRO)
    if (q.isEmpty)
    {
      verifySame(a, r)
    }
    else
    {
      verifyUriEq(a, r)
    }

    verifyEq(a.query, qAll)
    verifyQuery(a, r.queryStr, r.query)
  }

  Str escQuery(Str x)
  {
    return x.replace("\\", "\\\\")
            .replace("=", "\\=").replace(";", "\\;")
            .replace("&", "\\&").replace("#", "\\#")

  }

//////////////////////////////////////////////////////////////////////////
// Relativize
//////////////////////////////////////////////////////////////////////////

  Void testRelTo()
  {
    verifyRelTo(`http://foo/path?q#f`, `http://bar/`, `http://foo/path?q#f`)
    verifyRelTo(`http://foo/path`, `http://foo:88/`, `http://foo/path`)
    verifyRelTo(`http://foo/path`, `http://user@foo/`, `http://foo/path`)
    verifyRelTo(`http://foo/path?q#f`, `/bar`, `http://foo/path?q#f`)
    verifyRelTo(`http://foo/path?q#f`, `bar`,  `http://foo/path?q#f`)

    verifyRelTo(`http://bar/`, `http://foo/path?q#f`,  `http://bar/`)
    verifyRelTo(`/bar`, `http://foo/path?q#f`, `/bar`)
    verifyRelTo(`bar`, `http://foo/path?q#f`, `bar`)

    verifyRelTo(`http://foo/a/b/c`,  `http://foo/a/b/c`,  ``)
    verifyRelTo(`http://foo/a/b/c`,  `http://foo/a/b`,    `c`)
    verifyRelTo(`http://foo/a/b/c`,  `http://foo/a/b/`,   `c`)
    verifyRelTo(`http://foo/a/b/c`,  `http://foo/a`,      `b/c`)
    verifyRelTo(`http://foo/a/b/c`,  `http://foo/`,       `a/b/c`)
    verifyRelTo(`http://foo/a/b/c`,  `http://foo/ax`,     `/a/b/c`)

    verifyRelTo(`/a/b/`,  `/x/b/c`,  `/a/b/`)
    verifyRelTo(`/a/b/`,  `/a/x/c`,  `../b/`)
    verifyRelTo(`/a/b/`,  `/a/x/c/`, `../../b/`)
    verifyRelTo(`/a/b/x`, `/a/x/c/`, `../../b/x`)

    verifyRelTo(`/a/b/c`, `/a/b/c`, ``)
    verifyRelTo(`/a/b/c`, `/a/b`,   `c`)
    verifyRelTo(`/a/b/c`, `/a`,     `b/c`)
    verifyRelTo(`/a/b/c`, `/`,      `a/b/c`)
    verifyRelTo(`/a/b/c`, `/ax`,    `/a/b/c`)
    verifyRelTo(`/foo/`,  `/foo/`,  ``)
    verifyRelTo(`/foo/`,  `/foo/bar/`, `../`)
    verifyRelTo(`/`, `/`,  ``)
    verifyRelTo(`/foo?q`, `/`,  `foo?q`)
    verifyRelTo(`foo?q`, `/`,  `foo?q`)
    verifyRelTo(`foo/bar#f`, `/`,  `foo/bar#f`)
  }

  Void verifyRelTo(Uri a, Uri b, Uri r)
  {
    verifyEq(a.relTo(b), r)
  }

  Void testRelToAuth()
  {
    verifyRelToAuth(`http://u@foo:99/path?q#f`, `/path?q#f`)
    verifyRelToAuth(`http://foo/path?q#f`, `/path?q#f`)
    verifyRelToAuth(`http:a/b?foo=bar`, `a/b?foo=bar`)
    verifyRelToAuth(`/dir/f.txt#frag`, `/dir/f.txt#frag`)
    verifyRelToAuth(`logo.png`, `logo.png`)
  }

  Void verifyRelToAuth(Uri a, Uri r)
  {
    if (a == r)
      verifySame(a.relToAuth, a)
    verifyUriEq(a.relToAuth, r)
  }

//////////////////////////////////////////////////////////////////////////
// NameCheck (isName, checkName)
//////////////////////////////////////////////////////////////////////////
/*
  Void testNameCheck()
  {
    verifyNameCheck("", false)
    verifyNameCheck(".", false)
    verifyNameCheck("..", false)
    verifyNameCheck("a b", false)
    verifyNameCheck("\u00ff", false)
    verifyNameCheck("a:b", false)
    verifyNameCheck("x", true)
    verifyNameCheck("7", true)
    verifyNameCheck("-._~", true)
    verifyNameCheck("Hello_77", true)
  }

  Void verifyNameCheck(Str n, Bool ok)
  {
    verifyEq(Uri.isName(n), ok)
    if (ok) Uri.checkName(n)
    else verifyErr(NameErr#) { Uri.checkName(n) }
  }
*/
//////////////////////////////////////////////////////////////////////////
// Escapes
//////////////////////////////////////////////////////////////////////////

  Void testEsc()
  {
    // file path
    verifyPath(`a\#1/b`, Str<|a\#1/b|>, [Str<|a\#1|>, "b"])

    verifyEq(`filex \#2`.frag, null)

    verifyPath(`filex \\#2`,  Str<|filex \\|>, [Str<|filex \\|>])
    verifyEq(`filex \\#2`.frag, "2")

    verifyPath(`/x\/y/a\:b/what\?/`, "/x\\/y/a\\:b/what\\?/", ["x\\/y", "a\\:b", "what\\?"])
    verifyEq(`/x\/y/a\:b/what.\?/`.ext, "\\?")

    verifyPath(`why\/b`, Str<|why\/b|>, [Str<|why\/b|>])

    verifyPath(`a\\/b`, Str<|a\\/b|>, [Str<|a\\|>, "b"])

    verifyEq(`num\[2\] \@ foo`.name, "num[2] @ foo")
    verifyEq(Uri.fromStr(Str<|num\[2\] \@ foo|>).name, "num[2] @ foo")

    // query
    verifyEq(`foo?num=#3`.toStr,    "foo?num=#3")
    verifyEq(`foo?num=#3`.queryStr, "num=")
    verifyEq(`foo?num=#3`.frag,     "3")

    verifyEq(`foo?num=\#3`.toStr,    "foo?num=\\#3")
    verifyEq(`foo?num=\#3`.queryStr, "num=\\#3")
    verifyEq(`foo?num=\#3`.query["num"], "#3")
    verifyEq(`foo?num=\#3`.frag,     null)

    verifyEq(`foo?num=\\#3`.toStr,    "foo?num=\\\\#3")
    verifyEq(`foo?num=\\#3`.queryStr, "num=\\\\")
    verifyEq(`foo?num=\\#3`.query["num"], "\\")
    verifyEq(`foo?num=\\#3`.frag,     "3")

    verifyQuery(`?a=b\&c\=d`, "a=b\\&c\\=d", ["a":"b&c=d"])

    verifyEq(`/foo?a=h2\=\=;b\\b=c&d\;e`.path, ["foo"])
    verifyQuery(`/foo?a=h2\=\=;b\\b=c&d\;e`, Str<|a=h2\=\=;b\\b=c&d\;e|>, ["a":"h2==", "b\\b":"c", "d;e":"true"])

    verifyQuery(`?\\\;\&\#=\#\&\=\;\\#frag`, Str<|\\\;\&\#=\#\&\=\;\\|>, ["\\;&#":"#&=;\\"])
    verifyEq(`?\\\;\&\#=\#\&\=\;\\#frag`.frag,  "frag")

    // frag can contain anything
    verifyEq(`foo#a?b#:`.queryStr,  null)
    verifyEq(`foo#a?b#:`.frag, "a?b#:")

    // ok to use colon after first /
    verifyEq(`/c:/dir/`.scheme, null)
    verifyEq(`/c:/dir/`.pathStr, "/c:/dir/")
  }

  Void testEscMore()
  {
    nq := Str:Str[:]
    np := Str[,]

    verifyEsc(`/a b`, "/a%20b",  "/a b", ["a b"], null, nq, null)

    verifyEsc(`a/b#c`, "a/b#c", "a/b", ["a", "b"], null, nq, "c")
    verifyEsc(`a/b\#c`, "a/b%23c", "a/b\\#c", ["a", "b\\#c"], null, nq, null)

    verifyEsc(`b?c`, "b?c", "b", ["b"], "c", ["c":"true"], null)
    verifyEsc(`b\?c`, "b%3Fc", "b\\?c", ["b\\?c"], null, nq, null)

    verifyEsc(`&x y/z`, "&x%20y/z", "&x y/z", ["&x y", "z"], null, nq, null)
    verifyEsc(`&x y\/z`, "&x%20y%2Fz", "&x y\\/z", ["&x y\\/z"], null, nq, null)
    verifyEsc(`x\/`, "x%2F", "x\\/", ["x\\/"], null, nq, null)

    verifyEsc(`?\\=4`, "?%5C=4", "", np, "\\\\=4", ["\\":"4"], null)
    verifyEsc(`?\\=\\`, "?%5C=%5C", "", np, "\\\\=\\\\", ["\\":"\\"], null)

    verifyEsc(`?x=y`, "?x=y", "", np, "x=y", ["x":"y"], null)
    verifyEsc(`?x=y z`, "?x=y+z", "", np, "x=y z", ["x":"y z"], null)
    verifyEsc(`?x=y&z`, "?x=y&z", "", np, "x=y&z", ["x":"y", "z":"true"], null)
    verifyEsc(`?x=y\&z`, "?x=y%26z", "", np, "x=y\\&z", ["x":"y&z"], null)
    verifyEsc(`?x=y;z`, "?x=y;z", "", np, "x=y;z", ["x":"y", "z":"true"], null)
    verifyEsc(`?x=y\;z`, "?x=y%3Bz", "", np, "x=y\\;z", ["x":"y;z"], null)
    verifyEsc(`?x\=y`, "?x%3Dy", "", np, "x\\=y", ["x=y":"true"], null)
    verifyEsc(`?a=b&x\=y`, "?a=b&x%3Dy", "", np, "a=b&x\\=y", ["a":"b", "x=y":"true"], null)

    verifyEsc(`#\\`, "#%5C", "", np, null, nq, "\\\\")

    verifyEsc(`\\_.txt\\?x=\\`, "%5C_.txt%5C?x=%5C", Str<|\\_.txt\\|>, [Str<|\\_.txt\\|>], "x=\\\\", ["x":"\\"], null)
    verifyEsc(`\\_.txt\\?x=\\#f`, "%5C_.txt%5C?x=%5C#f", Str<|\\_.txt\\|>, [Str<|\\_.txt\\|>], "x=\\\\", ["x":"\\"], "f")

    verifyEsc(`\\?\\=\\#\\`, "%5C?%5C=%5C#%5C", "\\\\", ["\\\\"], "\\\\=\\\\", ["\\":"\\"], "\\\\")

    verifyEsc(`\u0114`, "%C4%94", "\u0114", ["\u0114"], null, nq, null)
    verifyEsc(`\u0645`, "%D9%85", "\u0645", ["\u0645"], null, nq, null)
    verifyEsc(`\u0114?\u0645`, "%C4%94?%D9%85", "\u0114", ["\u0114"], "\u0645", ["\u0645":"true"], null)
    verifyEsc(`\u0114?\u0645=\u1234`, "%C4%94?%D9%85=%E1%88%B4", "\u0114", ["\u0114"], "\u0645=\u1234", ["\u0645":"\u1234"], null)
  }

  Void verifyEsc(Uri uri, Str encoded, Str pathStr, Str[] path,
                 Str? queryStr, Str:Str query, Str? frag)
  {
    verifyEq(uri.encode, encoded)
    verifyUriEq(Uri.decode(uri.encode), uri)
    verifyPath(uri, pathStr, path)
    verifyQuery(uri, queryStr, query)
    verifyEq(uri.frag, frag)
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq(`/foo/bar baz?p=q`.toCode, "`/foo/bar baz?p=q`")
    verifyEq(`foo\#2#frag`.toCode, Str<|`foo\#2#frag`|>)
    verifyEq(`foo \$ bar \\ baz \` qoo`.toCode, Str<|`foo \$ bar \\ baz \` qoo`|>)
  }

//////////////////////////////////////////////////////////////////////////
// Interpolation
//////////////////////////////////////////////////////////////////////////

  Void testInterpolation()
  {
    x := "file.txt"
    verifyUriEq(`$x`, `file.txt`)
    verifyUriEq(`$x.upper`, `FILE.TXT`)
    verifyUriEq(`dir/$x`, `dir/file.txt`)
    verifyUriEq(`$x#frag`, `file.txt#frag`)
    verifyUriEq(`/dir/$x#frag`, `/dir/file.txt#frag`)
    verifyUriEq(`/dir/$x#$x.upper`, `/dir/file.txt#FILE.TXT`)

    y := `foo/bar/`
    z := "foo/bar/"
    verifyUriEq(`http://base/$y`, `http://base/foo/bar/`)
    verifyUriEq(`http://base/$z`, `http://base/foo/bar/`)
    verifyUriEq(`http://base/$z$x`, `http://base/foo/bar/file.txt`)
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  Void testMisc()
  {
    verifyEq(`foo:bar::Baz`.scheme,  "foo")
    verifyEq(`foo:bar::Baz`.pathStr, "bar::Baz")
  }

//////////////////////////////////////////////////////////////////////////
// Tokens
//////////////////////////////////////////////////////////////////////////
/*
  Void testTokens()
  {
    verifyToken("", Uri.sectionPath, "", "")
    verifyToken("x", Uri.sectionPath, "x", "x")
    verifyToken("Foo", Uri.sectionPath, "Foo", "Foo")
    verifyToken("foo bar", Uri.sectionPath, "foo bar", "foo%20bar")
    verifyToken("foo #1", Uri.sectionPath, "foo \\#1", "foo%20%231")
    verifyToken("Δ°F", Uri.sectionPath, "Δ°F", "%CE%94%C2%B0F")
    verifyToken("a/b?c", Uri.sectionPath, "a\\/b\\?c", "a%2Fb%3Fc")

    verifyToken("foo=bar&baz", Uri.sectionQuery, "foo\\=bar\\&baz", "foo%3Dbar%26baz")
    verifyToken("Δ # x", Uri.sectionQuery, "Δ \\# x", "%CE%94%20%23%20x")
    verifyToken("a/b", Uri.sectionQuery, "a/b", "a/b")
  }

  Void verifyToken(Str s, Int section, Str escaped, Str encoded)
  {
    /*
    echo
    echo("--- str $s")
    echo("    escape " + Uri.escapeToken(s, section))
    echo("    encode " + Uri.encodeToken(s, section))
    echo("  unescape " + Uri.unescapeToken(escaped))
    echo("    decode " + Uri.decodeToken(encoded, section))
    */

    verifyEq(Uri.escapeToken(s, section), escaped)
    verifyEq(Uri.encodeToken(s, section), encoded)
    verifyEq(Uri.unescapeToken(escaped), s)
    verifyEq(Uri.decodeToken(encoded, section), escaped)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

  Void verifyUriEq(Uri? a, Uri? b, Bool roundtrip := true)
  {
    verifyEq(a, b)
    if (a == null && b == null) return
    verifyEq(a.scheme,    b.scheme)
    verifyEq(a.userInfo,  b.userInfo)
    verifyEq(a.host,      b.host)
    verifyEq(a.port,      b.port)
    verifyEq(a.path,      b.path)
    verifyEq(a.pathStr,   b.pathStr)
    verifyEq(a.query,     b.query)
    verifyEq(a.queryStr,  b.queryStr)
    verifyEq(a.frag,      b.frag)
    verifyEq(a.isPathAbs, b.isPathAbs)
    verifyEq(a.toStr,     b.toStr)
    verify(a.path.isRO);   verify(b.path.isRO)
    verify(a.query.isRO)
    verify(b.query.isRO)

    if (roundtrip)
    {
      verifyUriEq(Uri.decode(a.encode), b, false)
      verifyUriEq(Uri.decode(b.encode), a, false)
      verifyUriEq(Uri.fromStr(a.toStr), b, false)
      verifyUriEq(Uri.fromStr(b.toStr), a, false)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Dump
//////////////////////////////////////////////////////////////////////////

  Void dump(Uri uri)
  {
    echo("uri:        $uri")
    echo("  scheme:   $uri.scheme")
    echo("  auth:     $uri.auth")
    echo("  host:     $uri.host")
    echo("  port:     $uri.port")
    echo("  userInfo: $uri.userInfo")
    echo("  path:     $uri.path")
    echo("  pathStr:  $uri.pathStr")
    echo("  name:     $uri.name")
    echo("  basename: $uri.basename")
    echo("  ext:      $uri.ext")
    echo("  query:    $uri.query")
    echo("  queryStr: $uri.queryStr")
    echo("  frag:     $uri.frag")
  }

}