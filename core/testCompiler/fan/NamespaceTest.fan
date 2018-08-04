//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Sep 06  Brian Frank  Creation
//

using compiler

**
** NamespaceTest
**
class NamespaceTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// Sys
//////////////////////////////////////////////////////////////////////////

  Void testReflect()
  {
    ns := ReflectNamespace()
    verifySys(ns)
  }

  Void testFPod()
  {
    ns := FPodNamespace(Env.cur.homeDir + `lib/fan/`)
    verifySys(ns)
  }

  Void verifySys(CNamespace ns)
  {
    // sys pod
    pod := ns.resolvePod("sys", null)
    verifyEq(pod.name, "sys")
    verify(pod.version > Version.fromStr("1.0.7"))
    types := pod.types

    // get some useful types
    int     := types.find |CType t->Bool| { return t.name == "Int" }
    obj     := pod.resolveType("Obj",     true)
    v       := pod.resolveType("Void",    true)
    num     := pod.resolveType("Num",     true)
    str     := pod.resolveType("Str",     true)
    buf     := pod.resolveType("Buf",     true)
    list    := pod.resolveType("List",    true)
    map     := pod.resolveType("Map",     true)
    method  := pod.resolveType("Method",  true)
    func    := pod.resolveType("Func",    true)
    in      := pod.resolveType("InStream",true)
    depend  := pod.resolveType("Depend",  true)
    service := pod.resolveType("Service", true)

    // sys::Int
    verifySame(int.pod, pod)
    verifyEq(int.name,  "Int")
    verifyEq(int.qname, "sys::Int")
    verifyEq(int.signature, "sys::Int")
    verifyEq(int.isVal, true)
    verifyEq(int.isGeneric, false)
    verifyEq(int.isParameterized, false)
    verifyEq(int.isGenericParameter, false)
    verifyEq(int.base, num)
    verifyEq(int.mixins.size, 0)
    verifyEq(int.isMixin, false)
    verifyEq(int.isAbstract, false)

    // sys::Service
    verifySame(service.pod, pod)
    verifyEq(service.name,  "Service")
    verifyEq(service.qname, "sys::Service")
    verifyEq(service.signature, "sys::Service")
    verifyEq(service.base, obj)
    verifyEq(service.mixins.size, 0)
    verifyEq(service.isMixin, true)
    verifyEq(service.isAbstract, true)

    // sys::Buf.charset
    cs := (CField)buf.slots["charset"]
    verifyEq(cs.qname, "sys::Buf.charset")
    verifyEq(cs.getter.qname, "sys::Buf.charset")
    verifyEq(cs.setter.qname, "sys::Buf.charset")
    verifyEq(cs.getter.returnType.qname, "sys::Charset")
    verifyEq(cs.getter.params.size, 0)
    verifyEq(cs.setter.returnType.isVoid, true)
    verifyEq(cs.setter.params.size, 1)
    verifyEq(cs.setter.params[0].paramType.qname, "sys::Charset")

    // slots -> Int.echo
    slots := int.slots
    echo := slots["echo"] as CMethod
    verifySame(echo.parent, obj)
    verifyEq(echo.name, "echo")
    verifyEq(echo.qname, "sys::Obj.echo")
    verifyEq(echo.signature, "sys::Void echo(sys::Obj? x)")
    verifySame(echo.returnType, v)
    verifyEq(echo.params[0].name, "x")
    verifyEq(echo.params[0].paramType, obj.toNullable)
    verifyEq(echo.params[0].hasDefault, true)

    // slots -> Int.hash
    hash := slots["hash"] as CMethod
    verifySame(hash.parent, int)
    verifySame(hash.returnType, int)
    verify(hash.params.isEmpty)
    verifyEq(hash.isGeneric, false)

    // fits
    verifyEq(obj.fits(obj), true)
    verifyEq(int.fits(num), true)
    verifyEq(int.fits(int), true)
    verifyEq(int.fits(buf), false)
    verifyEq(service.fits(obj), true)
    verifyEq(service.fits(service), true)
    verifyEq(service.fits(buf), false)

    // generic
    verifySame(list.pod, pod)
    verifyEq(list.name,  "List")
    verifyEq(list.qname, "sys::List")
    verifyEq(list.signature, "sys::List")
    verifyEq(list.base, obj)
    verifyEq(list.isGeneric, true)
    verifyEq(list.isParameterized, false)
    verifyEq(list.isGenericParameter, false)
    verifyEq(map.isGeneric, true)
    verifyEq(func.isGeneric, true)
    verifyEq(method.isGeneric, false)

    // generic parameters
    get := (CMethod)list.slot("get")
    verifyEq(get.isGeneric, true)
    verifyEq(get.isParameterized, false)
    verify(get.returnType.pod == pod)
    verifyEq(get.returnType.name, "V")
    verifyEq(get.returnType.qname, "sys::V")
    verifyEq(get.returnType.isGeneric, false)
    verifyEq(get.returnType.isParameterized, false)
    verifyEq(get.returnType.isGenericParameter, true)
    set := (CMethod)list.slot("set")
    verifyEq(set.returnType.qname, "sys::L")
    verifyEq(set.returnType.isGenericParameter, true)
    verifyEq(set.params[1].paramType.qname, "sys::V")
    verifyEq(set.params[1].paramType.isGenericParameter, true)

    // parameterized: Int[]
    ints := ListType.make(int)
    verify(ints.pod == pod)
    verifyEq(ints.name, "List")
    verifyEq(ints.qname, "sys::List")
    verifyEq(ints.signature, "sys::Int[]")
    verifyEq(ints.isGeneric, false)
    verifyEq(ints.isParameterized,     true)
    verifyEq(ints.isGenericParameter,  false)
    verifyEq(ints.fits(int.toListOf),  true)
    verifyEq(ints.fits(num.toListOf),  true)
    verifyEq(ints.fits(obj.toListOf),  true)
    verifyEq(ints.fits(list),          true)
    verifyEq(ints.fits(obj.toListOf),  true)
    verifyEq(ints.fits(str.toListOf),  false)
    verifyEq(obj.toListOf.fits(ints),  false)
    verifyEq(num.toListOf.fits(ints),  false)
    verifyEq(str.toListOf.fits(ints),  false)

    // parameterized method: List.get
    pget := (CMethod)ints.slot("get")
    verifyEq(pget.isGeneric, false)
    verifyEq(pget.isParameterized, true)
    verifySame(pget.generic, get)
    verifyEq(pget.returnType, int)
    verifyEq(pget.params.size, 1)
    verifyEq(pget.params[0].name, "index")
    verifyEq(pget.params[0].paramType, int)

    // parameterized method: List.set
    pset := (CMethod)ints.slot("set")
    verifyEq(pset.isGeneric, false)
    verifyEq(pset.isParameterized, true)
    verifySame(pset.generic, set)
    verifySame(pset.returnType, ints)
    verifyEq(pset.params.size, 2)
    verifyEq(pset.params[0].name, "index")
    verifyEq(pset.params[0].paramType, int)
    verifyEq(pset.params[1].name, "item")
    verifyEq(pset.params[1].paramType, int)

    // parameterized method: List.set
    peach := (CMethod)ints.slot("each")
    verifyEq(peach.isGeneric, false)
    verifyEq(peach.isParameterized, true)
    verifyEq(pset.params.size, 2)
    verifyEq(pset.params[0].paramType, int)
    verifyEq(pset.params[1].paramType, int)

    // parameterized type: Int:Str
    pmap := MapType.make(int, str)
    verifyEq(pmap.name, "Map")
    verifyEq(pmap.qname, "sys::Map")
    verifyEq(pmap.signature, "[sys::Int:sys::Str]")
    verifyEq(pmap.isGeneric, false)
    verifyEq(pmap.isParameterized, true)
    verifyEq(pmap.isGenericParameter, false)
    verifyEq(pmap.slot("toStr")->isGeneric, false)
    verifyEq(pmap.fits(ns.resolveType("[sys::Int:sys::Str]")), true)
    verifyEq(pmap.fits(ns.resolveType("[sys::Num:sys::Str]")), true)
    verifyEq(pmap.fits(ns.resolveType("[sys::Num:sys::Obj]")), true)
    verifyEq(pmap.fits(ns.resolveType("sys::Map")),     true)
    verifyEq(pmap.fits(ns.resolveType("sys::Obj")),     true)
    verifyEq(pmap.fits(ns.resolveType("[sys::Str:sys::Str]")), false)
    verifyEq(pmap.fits(ns.resolveType("[sys::Int:sys::Int]")), false)
    verifyEq(ns.resolveType("[sys::Num:sys::Str]").fits(pmap), false)
    verifyEq(ns.resolveType("[sys::Int:sys::Obj]").fits(pmap), false)

    // parameterized method: Map.set
    set  = (CMethod)map.slot("set")
    pset = (CMethod)pmap.slot("set")
    verifyEq(set.isGeneric, true)
    verifyEq(set.isParameterized, false)
    verifyEq(set.returnType.qname, "sys::M")
    verifyEq(set.params[0].paramType.qname, "sys::K")
    verifyEq(set.params[1].paramType.qname, "sys::V")
    verifyEq(pset.isGeneric, false)
    verifyEq(pset.isParameterized, true)
    verifyEq(pset.returnType, pmap)
    verifyEq(pset.params[0].paramType, int)
    verifyEq(pset.params[1].paramType, str)

    // parameterized type: |Str s->Int|
    pfunc := FuncType.make([str], ["s"], int)
    verifyEq(pfunc.qname, "sys::Func")
    verifyEq(pfunc.signature, "|sys::Str->sys::Int|")
    verifyEq(pfunc.isGeneric, false)
    verifyEq(pfunc.isParameterized, true)
    verifyEq(pfunc.isGenericParameter, false)
    verifyEq(pfunc.slot("toStr")->isGeneric, false)
    verifyEq(pfunc.fits(ns.resolveType(|Str s->Int|#.signature)), true)
    verifyEq(pfunc.fits(ns.resolveType(|Str s->Num|#.signature)), true)
    verifyEq(pfunc.fits(ns.resolveType(|Obj s->Num|#.signature)), false)
    verifyEq(pfunc.fits(ns.resolveType(|Obj s|#.signature)), false)
    verifyEq(pfunc.fits(ns.resolveType(|Obj s, Obj x|#.signature)), false)
    verifyEq(pfunc.fits(ns.resolveType(|Obj s, Obj x, Obj y->Obj|#.signature)), false)
    verifyEq(pfunc.fits(ns.resolveType(Func#.signature)), true)
    verifyEq(pfunc.fits(ns.resolveType(Obj#.signature)), true)
    verifyEq(pfunc.fits(ns.resolveType(|Slot s->Int|#.signature)), false)
    verifyEq(pfunc.fits(ns.resolveType(|Str s->Str|#.signature)), false)
    verifyEq(ns.resolveType(|Str a, Str b->Int|#.signature).fits(pfunc), false)

    // parameterized method: Map.set
    call  := (CMethod)func.slot("call")
    pcall := (CMethod)pfunc.slot("call")
    verifyEq(call.isGeneric, true)
    verifyEq(call.isParameterized, false)
    verifyEq(call.returnType.qname, "sys::R")
    verifyEq(call.params[0].paramType.qname, "sys::A")
    verifyEq(call.params[1].paramType.qname, "sys::B")
    verifyEq(pcall.isGeneric, false)
    verifyEq(pcall.isParameterized, true)
    verifyEq(pcall.returnType, int)
    verifyEq(pcall.params[0].paramType, str)
    verifyEq(pcall.params[1].paramType, obj)

    // parameterized parsing: Str[]
    strs := ns.resolveType(Str[]#.signature)
    verifyEq(strs.qname, "sys::List")
    verifyEq(strs.signature, "sys::Str[]")
    verifyEq(strs.isParameterized, true)
    verifyEq(strs.slot("get")->returnType, str)

    // parameterized parsing: Str[][]
    strs2 := ns.resolveType(Str[][]#.signature)
    verifyEq(strs2.qname, "sys::List")
    verifyEq(strs2.signature, "sys::Str[][]")
    verifyEq(strs2.isParameterized, true)
    verifyEq(strs2.slot("get")->returnType, strs)

    // parameterized parsing: Str[][]
    intBuf := ns.resolveType(Int:Buf#.signature)
    verifyEq(intBuf.qname, "sys::Map")
    verifyEq(intBuf.signature, "[sys::Int:sys::Buf]")
    verifyEq(intBuf.isParameterized, true)
    verifyEq(intBuf.slot("set")->params->get(0)->paramType, int)
    verifyEq(intBuf.slot("set")->params->get(1)->paramType, buf)

    // parameterized parsing: |Int, Num->Str|
    m := ns.resolveType(|Int x, Num y->Str|#.signature)
    verifyEq(m.qname, "sys::Func")
    verifyEq(m.signature, "|sys::Int,sys::Num->sys::Str|")
    verifyEq(m.isParameterized, true)
    verifyEq(m.slot("call")->returnType, str)
    verifyEq(m.slot("call")->params->get(0)->paramType, int)
    verifyEq(m.slot("call")->params->get(1)->paramType, num)

    // facets
    f := depend.facet("sys::Serializable")
    verifyNotNull(f)
    verifyEq(f.get("simple"), true)
    verifyEq(f.get("bad"), null)
  }

//////////////////////////////////////////////////////////////////////////
// Raw Generics
//////////////////////////////////////////////////////////////////////////

  Void testRawGenerics()
  {
    compile(
     "class Foo
      {
        static Int doX(Int a) { return a }
        static Obj x() { return Foo#.method(\"doX\").call(4) }

        static Obj doY(List list) { return list[0] }
        static Obj y() { return doY([5, 6]) }
      }")
     t := pod.types.first
     verifyEq(t.method("x").call, 4)
     verifyEq(t.method("y").call, 5)
  }

//////////////////////////////////////////////////////////////////////////
// Dependency Checking
//////////////////////////////////////////////////////////////////////////

  Void testInvalidDepends()
  {
    try
    {
      compile("class Foo {}")
      {
        it.isScript = false
        it.depends = [Depend("sys 0+"), Depend("jarJarBinks 1.0"), Depend("testCompiler 99.0")]
      }
    }
    catch (CompilerErr e)
    {
    }

    myVer := Pod.of(this).version
    doVerifyErrors(
      [null, null, "Cannot resolve depend: pod 'jarJarBinks' not found",
       null, null, "Cannot resolve depend: 'testCompiler $myVer' != 'testCompiler 99.0'"])
  }

  Void testNoSysDepend()
  {
    try
    {
      compile("class Foo {}")
      {
        it.isScript = false
        it.depends  = [Depend("compiler 0+")]
      }
    }
    catch (CompilerErr e)
    {
    }

    myVer := Pod.of(this).version
    doVerifyErrors(
      [null, null, "All pods must have a dependency on 'sys'"])
  }

  Void testInvalidUsing()
  {
    // check errors stage
    verifyErrors(
     "using compiler
      using $podName

      class Foo {}
      ",
       [
         1,  1, "Using 'compiler' which is not a declared dependency for '$podName'",
         2,  1, "Using '$podName' is on pod being compiled",
       ]) { it.log.level = LogLevel.silent; it.isScript = false }
  }

  Void testInvalidQname()
  {
    // check errors stage
    verifyErrors(
     "class Foo
      {
        Void x(sys::Str a, compiler::Loc loc) {}
      }
      ",
       [
         3, 22, "Using 'compiler' which is not a declared dependency for '$podName'",
       ]) { it.log.level = LogLevel.silent; it.isScript = false }
  }

//////////////////////////////////////////////////////////////////////////
// FFI Checking
//////////////////////////////////////////////////////////////////////////

  Void testFFI()
  {
    verifyErrors(
     "using [barxyzfoo] a.b.c
      using [testCompiler] d.e.f
      class Foo {}
      ",
       [
         1, 1, "No FFI bridge available for 'barxyzfoo'",
         2, 1, "No FFI bridge available for 'testCompiler'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Bug 545 Test
//////////////////////////////////////////////////////////////////////////

  Int bug545 := 545
  Void testBug545()
  {
    compile(
     "using testCompiler
      using testCompiler::NamespaceTest as NsTest
      class Foo
      {
        Int x() { return NsTest().bug545 }
        Int y() { return testCompiler::NamespaceTest().bug545 }
      }")
     obj := pod.types.first.make
     verifyEq(obj->x, 545)
     verifyEq(obj->y, 545)

    verifyErrors(
     "using testCompiler
      using testCompiler::NamespaceTest as NsTest
      class Foo
      {
        Int x() { return NamespaceTest().bug545 }
      }",
       [
         5, 20, "Unknown method '$podName::Foo.NamespaceTest'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Ambiguous
//////////////////////////////////////////////////////////////////////////

  Void testAmbiguous()
  {
    x := podName
    compile("class Foo {}\nclass Bar {}")
    xp := pod

    y := podName
    compile("class Foo {}\nclass Bar {}\nclass Baz {}")
    yp := pod

    verifyErrors(
    "using $x
     using $y
     class Test
     {
       Obj? m05() { return Foo# }
       Obj? m06() { return Bar#.bar }
       Obj? m07() { return (Baz)m06 }
     }
     class Foo {}
     class Baz {}",
     [
       5, 23, "Ambiguous type: $podName::Foo, $x::Foo, $y::Foo",
       6, 23, "Ambiguous type: $x::Bar, $y::Bar",
       7, 24, "Ambiguous type: $podName::Baz, $y::Baz",
     ])
  }

//////////////////////////////////////////////////////////////////////////
// Res Conflicts
//////////////////////////////////////////////////////////////////////////

  Void testResConflicts()
  {
    verifyErrors(
     "class Foo {}",
       [
         1, 1, "Resource `Foo/` conflicts with type name 'Foo'",
       ]) { resFiles = [`Foo/`] }
  }

}