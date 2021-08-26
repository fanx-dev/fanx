//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Aug 08  Brian Frank  Creation
//

**
** NamingTest
**
class NamingTest : Test
{

//////////////////////////////////////////////////////////////////////////
// SchemeFind
//////////////////////////////////////////////////////////////////////////

  Void testSchemeFind()
  {
    verifyScheme(UriScheme.find("fan"),  "std::FanScheme", "fan")
    verifyScheme(UriScheme.find("file"), "std::FileScheme", "file")

    verifyEq(UriScheme.find("foobar", false), null)
    verifyErr(UnresolvedErr#) { UriScheme.find("foobar") }
    verifyErr(UnresolvedErr#) { UriScheme.find("foobar", true) }
  }

  Void verifyScheme(UriScheme x, Str qname, Str scheme)
  {
    verifyEq(x.typeof.qname, qname)
    verifyEq(x.toStr, qname)
    verifySame(UriScheme.find(scheme), x)

    UriScheme y := x.typeof.make
    verifySame(y.typeof, x.typeof)
  }

//////////////////////////////////////////////////////////////////////////
// file:
//////////////////////////////////////////////////////////////////////////

  Void testFile()
  {
    // verify file:
    uri := Env.cur.homeDir.normalize.uri
    verifyEq(uri.scheme, "file")
    File home := uri.get
    verifyEq(home.list.map |File f->Str| { f.name },
      Env.cur.homeDir.list.map |File f->Str| { f.name })

    // verify we can resolve without trailing slash
    uri = uri.toStr[0..-2].toUri
    verifyEq(uri.toStr.endsWith("/"), false)
    home = uri.get
    verifyEq(home.isDir, true)
    verifyEq(home.uri.isDir, true)
    verifyEq(home.uri.toStr.endsWith("/"), true)
    verifyEq(home.list.map |File f->Str| { f.name },
      Env.cur.homeDir.list.map |File f->Str| { f.name })
  }

//////////////////////////////////////////////////////////////////////////
// fan:pod
//////////////////////////////////////////////////////////////////////////

  Void testFanPod()
  {
    verifySame(`fan://sys`.get, Str#.pod)
    verifySame(`fan://testSys`.get, this.typeof.pod)
    verifySame(`fan://testSys/res/test.b`.get, this.typeof.pod.file(`/res/test.b`))

    verifySame(`fan://badFooBarPod`.get(null, false), null)
    verifyErr(UnresolvedErr#) { `fan://badFooBarPod`.get }
    verifyErr(UnresolvedErr#) { `fan://badFooBarPod`.get(null) }
    verifyErr(UnresolvedErr#) { `fan://badFooBarPod`.get(null, true) }
  }

}