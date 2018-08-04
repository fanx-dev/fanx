//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-01  chunquedong  Creation
//

using compiler

**
** GenericTypeTest
**
class GenericTypeTest : CompilerTest
{

  Void testDef()
  {
    compile("class Foo<T> { T? t }")

    t := pod.types.first
    verifyEq(t.isGeneric, true)
  }

  Void testRef()
  {
    compile("class Foo<T> { T? t }
             class Bar {
                Foo<Str>? foo
             }
             ")

    t := pod.types.first
    verifyEq(t.isGeneric, true)
  }
}