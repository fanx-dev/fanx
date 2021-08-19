//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Aug 06  Brian Frank  Creation
//

using compiler

**
** Abstract base with useful utilities common to compiler tests.
**
abstract class CompilerTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  Str podName()
  {
    curTestMethod.toStr.replace("::", "_").replace(".", "_") + "_" + podNameSuffix
  }

  Void compile(Str src, |CompilerInput in|? f := null)
  {
    input := CompilerInput.make
    input.podName     = podName
    input.summary     = "test"
    input.version     = Version.defVal
    input.log.level   = LogLevel.err
    input.isTest      = true
    input.isScript    = true
    input.output      = CompilerOutputMode.transientPod
    input.mode        = CompilerInputMode.str
    input.srcStr      = src
    input.srcStrLoc   = Loc.make("Script")
    input.depends = [Depend("sys 2"), Depend("std 1")]
    f?.call(input)

    compiler = Compiler.make(input)
    pod = compiler.compile.transientPod
    podNameSuffix++
  }

  Void verifyErrors(Str src, Obj[] errors, |CompilerInput in|? f := null)
  {
    if (dumpErrors) echo("=============verifyErrors")
    try
    {
      compile(src) { f?.call(it); it.log.level = LogLevel.silent }
    }
    catch (CompilerErr e)
    {
    }
    catch (Err e)
    {
      e.trace
      fail
    }
    doVerifyErrors(errors)
  }

  Void doVerifyErrors(Obj?[] errs, CompilerErr[] actual := compiler.errs)
  {
    c := compiler
    if (dumpErrors)
      echo(actual.join("\n") |CompilerErr e->Str| { return "${e.loc.toLocStr.justl(14)} $e.msg" })
    verifyEq("size=${actual.size}", "size=${errs.size / 3}")
    for (i := 0; i<errs.size/3; ++i)
    {
      emsg := errs[i*3+2]
      if (!actual[i].msg.startsWith(emsg)) {
        verifyEq(actual[i].msg, emsg)
      }
      verifyEq(actual[i].loc.line, errs[i*3+0])
      verifyEq(actual[i].loc.col,  errs[i*3+1])
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Compiler? compiler      // compile()
  Pod? pod                // compiled pod
  Int podNameSuffix := 0
  Bool dumpErrors := true
  Depend[]? depends

}