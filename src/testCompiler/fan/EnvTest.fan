//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Jul 09  Brian Frank  Creation
//
/*
using compiler

**
** EnvTest is used to define a new working dir which is used to
** compile new pods and then execute them in another process.
**
class EnvTest : Test
{

  File workHome := tempDir + `testenv/`
  File outFile  := tempDir + `test-output.txt`
  Str podA := "testAx" + Int.random(0..0xffff).toHex.upper
  Str podB := "testBx" + Int.random(0..0xffff).toHex.upper

//////////////////////////////////////////////////////////////////////////
// Test
//////////////////////////////////////////////////////////////////////////

  Void test()
  {
    genPodA
    genPodB
    run("$podB::TheTest")
    verifyOutFile
  }

//////////////////////////////////////////////////////////////////////////
// PodA
//////////////////////////////////////////////////////////////////////////

  Void genPodA()
  {
    dir := workHome + `$podA/`

    // build.fan
    buildFile := dir+`build.fan`
    buildFile.out.print(
    """class Build : build::BuildPod
       {
         new make()
         {
           podName = "$podA"
           summary = "test pod A"
           depends = ["sys 2.0"]
           srcDirs = [`fan/`]
           index   = ["testCompiler.envTest":"a"]
         }
       }""").close

    // src.fan
    srcFile := dir+`fan/src.fan`
    srcFile.out.print(
    """@Foo { val="alpha" }
       class A
       {
         static Str a() { return "a" }
       }

       facet class Foo { const Str val := "" }

       """).close

    compile(podA, buildFile)
  }

//////////////////////////////////////////////////////////////////////////
// PodB
//////////////////////////////////////////////////////////////////////////

  Void genPodB()
  {
    dir := workHome + `$podB/`

    // build.fan
    buildFile := dir+`build.fan`
    buildFile.out.print(
    """class Build : build::BuildPod
       {
         new make()
         {
           podName = "$podB"
           summary = "test pod B"
           depends = ["sys 2.0", "std 1.0", "util 1.0", "$podA 1.0"]
           srcDirs = [`fan/`]
           index   = ["testCompiler.envTest":"b"]
         }
       }""").close

    // src.fan
    srcFile := dir+`fan/src.fan`
    srcFile.out.print(
    """using util
       using $podA
       class TheTest : Test
       {
         // test env
         Void testEnv()
         {
           //verifyEq(Env.cur.typeof, PathEnv#)
           //env := (PathEnv)Env.cur
           //verifyEq(env.path.size, 2)
           //verifyEq(env.path[0].uri, `$workHome`)
           //verifyEq(env.path[1].uri, `$Env.cur.homeDir`)
         }

         // test pods
         Void testPods()
         {
           pods := Pod.list
           verify(pods.contains(Pod.find("$podA")))
           verify(pods.contains(Pod.find("$podB")))
           verify(pods.contains(Pod.find("sys")))
         }

         // test facets
         Void testFacets()
         {
           verifyEq(A#.facet(Foo#)->val, "alpha")
           verifyEq(B#.facet(Foo#)->val, "beta")
         }

         // test indexed props
         Void testIndexedProps()
         {
           verifyEq(Env.cur.index("testCompiler.envTest").dup.sort, ["a", "b"])
         }

         static Void main()
         {
           out := File($outFile.uri.toCode).out
           t := TheTest()
           TheTest#.methods.each |m|
           {
             if (m.isStatic || m.isCtor || m.parent != TheTest#) return
             echo("-- EnvTest: \${m.name}...")
             try
             {
               m.callOn(t, [,])
               out.printLine("\$m.name pass")
             }
             catch (Err e)
             {
               e.trace
               out.printLine("\$m.name fail \$e")
             }
           }
           out.close
         }
       }

       @Foo { val = "beta" }
       class B {}
       """).close

    compile(podB, buildFile)
  }

//////////////////////////////////////////////////////////////////////////
// Verify Out File
//////////////////////////////////////////////////////////////////////////

  Void verifyOutFile()
  {
    lines := outFile.readAllLines
    verify(lines.size > 0)
    lines.each |line| { verify(line.endsWith("pass"), line) }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void compile(Str podName, File buildFile)
  {
    run(buildFile.osPath)
    file := workHome + `lib/fan/${podName}.pod`
    //echo(file)
    verify(file.exists)
  }

  Void run(Str target)
  {
    isWindows := Env.cur.os == "win32"
    Str[]? cmds
    if (isWindows)
    {
      cmd := "cmd.exe"
      fan := (Env.cur.homeDir + `bin/fan`).osPath
      cmds = [cmd, "/C", fan, target]
    }
    else {
      cmd := "sh"
      fan := (Env.cur.homeDir + `bin/fan`).osPath
      cmds = [cmd, fan, target]
    }
    p := Process(cmds)
    //p.env["FAN_ENV"]      = "util::PathEnv"
    p.env["FAN_ENV_PATH"] = workHome.uri.relToAuth.toStr
    echo("$p.command === $p.env")
    status := p.run.join
    verifyEq(status, 0)
  }

}
*/