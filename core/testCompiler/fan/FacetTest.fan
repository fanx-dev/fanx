//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   03 Feb 10  Brian Frank  Creation
//

**
** FacetTest
**
class FacetTest : CompilerTest
{

/////////////////////////////////////////////////////////////////////////
// Singleton
//////////////////////////////////////////////////////////////////////////

  Void testSingleton()
  {
    compile("facet class Foo {}")

    t := pod.types.first
    verifyEq(t.name,   "Foo")
    verifyEq(t.isFacet, true)
    verifyEq(t.isClass, true)
    verifyEq(t.isMixin, false)
    verifyEq(t.isConst, true)
    verifyEq(t.isFinal, true)
    verifyEq(t.isAbstract, false)
    verifyEq(t.base, Obj#)
    verifyEq(t.mixins, [Facet#])

    ctor := t.method("make")
    verifyEq(ctor.isPrivate, true)

    defVal := t.field("defVal")
    verifyEq(defVal.isPublic, true)
    verifyEq(defVal.isConst, true)
    verifyEq(defVal.isStatic, true)
    verifyEq(defVal.get.typeof.name, "Foo")
  }

/////////////////////////////////////////////////////////////////////////
// Struct
//////////////////////////////////////////////////////////////////////////

  Void testStruct()
  {
    compile(
      """facet class Foo
         {
           const Int i
           const Str s := "foo"
           const Duration d := 5min
         }
         class Test
         {
           Foo t1() { Foo() }
           Foo t2() { Foo {} }
           Foo t3() { Foo { i = 4 } }
           Foo t4() { Foo { s = "bar" } }
           Foo t5() { Foo { s = "baz"; d = 1day } }
         }
         """)

    t := pod.types.first
    verifyEq(t.name,   "Foo")
    verifyEq(t.isFacet, true)
    verifyEq(t.isConst, true)
    verifyEq(t.base, Obj#)
    verifyEq(t.mixins, [Facet#])
    verifyEq(t.hasFacet(Serializable#), true)

    ctor := t.method("make")
    verifyEq(ctor.isPublic, true)

    test := pod.types[1].make
    verifyStruct(test->t1, 0, "foo", 5min)
    verifyStruct(test->t2, 0, "foo", 5min)
    verifyStruct(test->t3, 4, "foo", 5min)
    verifyStruct(test->t4, 0, "bar", 5min)
    verifyStruct(test->t5, 0, "baz", 1day)
  }

  Void verifyStruct(Obj foo, Int i, Str s, Duration d)
  {
    verifyEq(foo->i, i)
    verifyEq(foo->s, s)
    verifyEq(foo->d, d)
  }

/////////////////////////////////////////////////////////////////////////
// Usage
//////////////////////////////////////////////////////////////////////////

  Void testUsage()
  {
    compile(
      """@A
         @$podName::B { x = 77 }
         class Foo
         {
           @sys::Transient @C { y = "foo"; z = [1, 2, 3] }
           Int f
         }

         facet class A {}
         facet class B { const Int x; const Int y }
         facet class C { const Str x := "x"; const Str y := "y"; const Int[]? z }
         """)

    t := pod.type("Foo")
    tf := t.field("f")

    a := pod.type("A")
    av := t.facet(a)
    aDefVal := a.field("defVal").get
    verifySame(av, aDefVal)
    verifySame(av, t.facet(a))
    verify(t.hasFacet(a))

    b := pod.type("B")
    bv := t.facet(b)
    verifyEq(bv->x, 77)
    verifyEq(bv->y, 0)
    verifySame(bv, t.facet(b))
    verify(t.hasFacet(b))

    c := pod.type("C")
    cv := tf.facet(c)
    verifyEq(cv->x, "x")
    verifyEq(cv->y, "foo")
    verifyEq(cv->z, [1, 2, 3])
    verifySame(cv, tf.facet(c))

    verify(t.facets.isImmutable)
    verify(t.facets.contains(av))
    verify(t.facets.contains(bv))
    verifySame(t.facets, t.facets)

    verify(tf.facets.contains(cv))
    verifySame(tf.facets, tf.facets)
    verify(tf.hasFacet(Transient#))
    verifySame(tf.facet(Transient#), Transient.defVal)
  }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  Void testErrors()
  {
    // Parse
    verifyErrors(
     """const class X : Facet {}
        """,
       [
         1, 17, "Cannot inherit 'Facet' explicitly",
       ])

    // InitFacet
    verifyErrors(
     """facet class A { new make() {} }
        """,
       [
         1, 17, "Facet cannot declare constructors",
       ])

    // CheckErrors
    verifyErrors(
     """@sys::Js @Js @NoDoc @NoDoc class Bar {}
        class Foo
        {
          @Transient @sys::Transient Int a
          @Str[] Int b
          @Foo Int c
          @A { a = 4; xyz = 5 } Int d
          @A { b = null } Int e
         }

        facet class A
        {
          const Str a := ""
          const Obj b := ""
        }
        """,
     [
       1,  1, "Duplicate facet 'sys::Js'",
       1, 14, "Duplicate facet 'sys::NoDoc'",
       4,  3, "Duplicate facet 'sys::Transient'",
       5,  3, "Not a facet type 'sys::Str[]'",
       6,  3, "Not a facet type '$podName::Foo'",
       7, 12, "Invalid type for facet field 'a': expected 'sys::Str' not 'sys::Int'",
       7, 21, "Unknown facet field '$podName::A.xyz'",
       8, 12, "Cannot assign null to non-nullable facet field 'b': 'sys::Obj'",
     ])

    // Assemble
    verifyErrors(
      "@X { val = Env.cur.homeDir }
       class Foo {}
       facet class X { const Obj? val }
       ",
       [
         1, 1, "Facet value is not serializable: '$podName::X' ('call' not serializable)",
       ])
  }


}