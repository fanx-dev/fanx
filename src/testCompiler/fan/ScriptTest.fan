//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Mar 08  Brian Frank  Creation
//

using compiler

**
** ScriptTest
**
class ScriptTest : CompilerTest
{

  Void testCompile()
  {
    f := tempDir + `test.fan`
    f.out.print("class Foo { Int x() { return 2008 } }").close

    t1 := Env.cur.compileScript(f)
    verifyEq(t1.make->x, 2008)

    t2 := Env.cur.compileScript(f)
    verifySame(t1, t2)
    verifyEq(t2.make->x, 2008)

    f.out.print("class Foo { Str x() { return \"2009\" } }").close
    t3 := Env.cur.compileScript(f)
    verifyNotSame(t1, t3)
    verifyEq(t3.make->x, "2009")

    t4 := Env.cur.compileScript(f, ["force":false])
    verifySame(t3, t4)
    t5 := Env.cur.compileScript(f, ["force":true])
    verifyNotSame(t3, t5)
  }

  Void testCompileType()
  {
    f := tempDir + `test.fan`
    f.out.print(
     "class C { }
      class A { }
      class B { }"
    ).close

    t := Env.cur.compileScript(f)
    verifyEq(t.name, "C")

    f.out.print(
     "internal class C { }
      class A { }
      class B { }"
    ).close

    t = Env.cur.compileScript(f)
    verifyEq(t.name, "A")
  }

  Void testCompileOptions()
  {
    f := tempDir + `test.fan`
    f.out.print("class Foo {}").close

    log := CompilerLog.make

    Env.cur.compileScript(f, ["log":log, "logLevel":LogLevel.silent])
    verifyEq(log.level, LogLevel.silent)

    Env.cur.compileScript(f, ["log":log, "logLevel":LogLevel.err, "force":true])
    verifyEq(log.level, LogLevel.err)
  }

  Void testCompileError()
  {
    f := tempDir + `test.fan`
    f.out.print("class Foo { Void x(Intx p) {} }").close

    try
    {
      Env.cur.compileScript(f, ["logLevel":LogLevel.silent])
      fail
    }
    catch (CompilerErr e)
    {
      verifyEq(e.msg, "Unknown type 'Intx'")
      verifyEq(e.col, 20)
    }
  }
}