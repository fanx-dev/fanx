//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 06  Brian Frank  Creation
//

**
** PodTest
**
class PodTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  Void testIdentity()
  {
    pod := Pod.of(this)
    verifyEq(pod.name,  "testSys")
    verifyEq(pod.toStr, "testSys")
    verifyEq(pod.uri,   `fan://testSys`)
    //verifySame(pod.uri.get, pod)
    verifySame(pod, Type.of(this).pod)
  }

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testFind()
  {
    verifySame(Pod.find("sys"), Bool#.pod)
    verifySame(Pod.find("notHereFoo", false), null)
    verifyErr(UnknownPodErr#) { Pod.find("notHereFoo") }
  }

//////////////////////////////////////////////////////////////////////////
// List
//////////////////////////////////////////////////////////////////////////

  Void testList()
  {
    pods := Pod.list
    verify(pods.isRO)
    verifyIsType(pods, Pod[]#)
    verify(pods.contains(Pod.find("sys")))
    verify(pods.contains(Pod.find("testSys")))
  }

//////////////////////////////////////////////////////////////////////////
// Meta
//////////////////////////////////////////////////////////////////////////

  Void testMeta()
  {
    sys := Pod.find("sys")
    verifyEq(sys.name, "sys")
    verifyEq(sys.depends.size, 0)
    verifyEq(sys.meta["pod.docApi"], "true")
    //verifyEq(sys.meta["pod.docSrc"], "true")
    verifyMeta(sys)

    testSys := Pod.find("testSys")
    verifyEq(testSys.meta["testSys.foo"], "got it")
    verifyEq(testSys.meta["pod.docApi"], "false")
    verifyNotEq(testSys.meta["pod.docSrc"], "true")
    verifyEq(testSys.name, "testSys")
    //verifyEq(testSys.depends.size, 2)
    verifyEq(testSys.depends[0].name, "sys")
    //verifyEq(testSys.depends[1].name, "concurrent")
    verifyMeta(testSys)
  }

  Void verifyMeta(Pod pod)
  {
    verify(pod.version >= Version.fromStr("1.0.14"))
    verifyEq(pod.version.major, 2)
    //verifyEq(pod.version.minor, 0)

    verify(pod.depends.isImmutable)
    verifyIsType(pod.depends, Depend[]#)

    verify(pod.meta.isImmutable)
    verifyIsType(pod.meta, Str:Str#)

    verifyEq(pod.meta["pod.name"], pod.name)
    verifyEq(pod.meta["pod.version"], pod.version.toStr)
    verify(pod.meta.containsKey("pod.depends"))
    verify(pod.meta.containsKey("build.host"))
    verify(pod.meta.containsKey("build.user"))
    verify(pod.meta.containsKey("build.ts"))
  }

//////////////////////////////////////////////////////////////////////////
// Files
//////////////////////////////////////////////////////////////////////////

  Void testFiles()
  {
    pod := this.typeof.pod
    verifyEq(pod.files.isImmutable, true)
    verifySame(pod.files, pod.files)

    f := pod.file(`/locale/en.props`)
    verifyEq(f.uri, `fan://testSys/locale/en.props`)
    verifySame(f, pod.files.find {it.name=="en.props"})

    verifyTestFile(pod.file(`fan://testSys/res/test.b`))
    //TODO
    //verifyTestFile(`fan://testSys/res/test.b`.toFile)

    verifyErr(ArgErr#) { pod.file(`res/test.b`) }
    verifyErr(ArgErr#) { pod.file(`fan://foo/res/test.b`) }
    verifyErr(ArgErr#) { pod.file(`//testSys/res/test.b`) }

    //verifyNull(pod.file(`fan://testSys/bad/file`, false))
    //verifyErr(UnresolvedErr#) { pod.file(`fan://testSys/bad/file`) }
    //verifyErr(UnresolvedErr#) { pod.file(`fan://testSys/bad/file`, true) }
  }

  Void verifyTestFile(File f)
  {
    //verifyEq(f.uri, `fan://testSys/res/test.b`)
    verifyEq(f.name, "test.b")
    verifyEq(f.size, 19)
    verifyEq(f.readAllStr, "hello world\nline 2")
  }

//////////////////////////////////////////////////////////////////////////
// Log
//////////////////////////////////////////////////////////////////////////

  Void testLog()
  {
    verifyEq(Pod.of(this).log.name, "testSys")
  }

//////////////////////////////////////////////////////////////////////////
// Props
//////////////////////////////////////////////////////////////////////////
/*TODO
  Void testProps()
  {
    pod := this.typeof.pod
    verifyEq(pod.props(`res/podtest.props`, 1ms)["barney"], "stinson")
    verifyEq(pod.props(`res/podtest.props`, 1ms).isImmutable, true)

    verifyEq(pod.props(`not/found`, 1ms).size, 0)
    verifyEq(pod.props(`not/found`, 1ms).isImmutable, true)

    verifySame(pod.props(`res/podtest.props`, 1ms), pod.props(`res/podtest.props`, 1ms))
    verifySame(pod.props(`not/found`, 1ms), pod.props(`not/found`, 1ms))
  }
*/
//////////////////////////////////////////////////////////////////////////
// Reload
//////////////////////////////////////////////////////////////////////////
/*TODO
  Void testReload()
  {
    podName := "testSysPodReload"
    podFile := Env.cur.workDir + `lib/fan/${podName}.pod`
    try
    {
      // verify pod is not installed yet
      pods := Pod.list
      verifyEq(pods.find |p| { p.name == podName }, null)
      verifyEq(Pod.find(podName, false), null)
      verifyErr(UnknownPodErr#) { Pod.find(podName) }
      verifyEq(Env.cur.index("podReload"), Str[,])

      // create new pod
      writePod(podFile, podName, "1.0")

      // verify pod is now installed
      this.typeof.pod->reloadList
      pod := Pod.find(podName)
      verifyPod(pod, podName, "1.0")

      // now rewrite the pod
      writePod(podFile, podName, "1.1")

      // verify pod changes
      oldPod := pod
      pod->reload
      pod = Pod.find(podName)
      verifyNotSame(oldPod, pod)
      verifyPod(pod, podName, "1.1")

      // verify can't use old pod
      verifyErr(null) { oldPod.file(`/res/a.txt`).readAllStr }

      // verify can't reload pods with code
      verifyErr(Err#) { Pod.find("sys")->reload }
      verifyErr(Err#) { Pod.find("compiler")->reload }
      verifyErr(Err#) { Pod.find("testSys")->reload }

      // rewrite pod one more time
      writePod(podFile, podName, "1.2")
      pod->reload
      pod = Pod.find(podName)
      verifyPod(pod, podName, "1.2")
    }
    finally podFile.delete
  }

  private Void verifyPod(Pod pod, Str podName, Str ver)
  {
    verifyEq(Pod.list.find |p| { p.name == podName }, pod)
    verifyEq(Env.cur.index("podReload"), [ver])
    verifyEq(pod.props(`foo.props`, 1min)["foo"], "foo $ver")
    verifyEq(pod.name, podName)
    verifyEq(pod.version, Version(ver))
    verifyEq(pod.meta["pod.summary"], "$podName $ver")
    verifyEq(pod.file(`/res/a.txt`).readAllStr, "a $ver\n")
    verifyEq(pod.file(`/res/b.txt`).readAllStr, "b $ver\n")
  }

  private Void writePod(File podFile, Str podName, Str ver)
  {
    meta := [
      "pod.name":podName,
      "pod.version":ver,
      "pod.depends":"",
      "pod.summary":"$podName $ver",
      "fcode.version":"1.0.51"]    // TODO
    f := tempDir + `${podName}.pod`
    zip := Zip.write(f.out)
    zip.writeNext(`meta.props`).writeProps(meta).close
    zip.writeNext(`index.props`).writeProps(["podReload":ver]).close
    zip.writeNext(`foo.props`).writeProps(["foo":"foo $ver"]).close
    zip.writeNext(`res/a.txt`).printLine("a $ver").close
    zip.writeNext(`res/b.txt`).printLine("b $ver").close
    zip.close
    f.copyTo(podFile, ["overwrite":true])
  }
*/
}