//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jul 06 - Fireworks!  Brian Frank  Creation
//


**
** FacetsTests
**
class FacetsTest : Test
{
  Str? aField
  Void aMethod() {}

//////////////////////////////////////////////////////////////////////////
// Attributes
//////////////////////////////////////////////////////////////////////////
/*
  Void testAttributes()
  {
    if (!isJs)
    {
      verifyEq(this->typeof->lineNumber, 13)
      verifyEq(this->typeof->sourceFile, "FacetsTest.fan")

      Field field := #aField
      verifyEq(field->lineNumber, 15)

      Method method := #aMethod
      verifyEq(method->lineNumber, 16)
    }
  }
*/
//////////////////////////////////////////////////////////////////////////
// Empty Facets
//////////////////////////////////////////////////////////////////////////

  Void testEmpty()
  {
    /*
    if (!isJs)
    {
      verifyEq(Type.find("testSys::ZipTest").facets, Facet[,])
      verifyEq(Type.find("testSys::ZipTest").facets.isImmutable, true)
      verifyEq(Type.find("testSys::ZipTest").facet(NoDoc#, false), null)
    }
    */

    verifyEq(FacetsTest#testEmpty.facets, Facet[,])
    verifyEq(FacetsTest#testEmpty.facets.isImmutable, true)
    verifyEq(FacetsTest#testEmpty.facet(NoDoc#, false), null)
  }

//////////////////////////////////////////////////////////////////////////
// Type Facets
//////////////////////////////////////////////////////////////////////////

  Void testTypeFacets()
  {
    t := FacetsA#
    verifyFacets(t, t.facets)
  }

  Void testSlotFacets()
  {
    s := FacetsA#i
    verifyFacets(s, s.facets)
  }

  Void verifyFacets(Obj t, Facet[] facets)
  {
    verifyEq(facets.isImmutable, true)
    verifyIsType(facets, Facet[]#)
    verifyEq(facets.size, 3)

    verifyEq(t->facet(Transient#, false), null)
    verifyErr(UnknownFacetErr#) { t->facet(Transient#) }
    verifyErr(UnknownFacetErr#) { t->facet(Transient#, true) }

    m1 := (FacetM1)t->facet(FacetM1#)
    s1 := (FacetS1)t->facet(FacetS1#)
    s2 := (FacetS2)t->facet(FacetS2#)

    verifySame(m1, FacetM1.defVal)
    verifyEq(s1.val, "foo")
    verifyEq(s2.b, false)
    verifyEq(s2.i, 77)
    verifyEq(s2.s, null)
    verifyEq(s2.v, Version("9.0"))
    verifyEq(s2.l, [1, 2, 3])
    verifySame(s2.type, Str#)
    verifySame(s2.slot, Float#nan)
    verify(facets.contains(m1))
    verify(facets.contains(s1))
    verify(facets.contains(s2))
    verifySame(facets, t->facets)
  }

//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////

  Void testInheritance()
  {
    /*
    echo("M2: " + FacetsM2#.facets)
    echo("C1: " + FacetsC1#.facets)
    echo("C2: " + FacetsC2#.facets)
    */

    // M2: from M1 not F1, yes F3; self F2
    verifyEq(FacetsM2#.facets.size, 2)

    verifyNotNull(FacetsM2#.facets.find { it.typeof == FacetsF2# })
    verifyNotNull(FacetsM2#.facets.find { it.typeof == FacetsF3# })
    verifyEq(FacetsM2#.facet(FacetsF1#, false), null)
    verifyEq(FacetsM2#.facet(FacetsF3#)->n, "FacetsM1")
    verifyEq(FacetsM2#.facet(FacetsF2#)->n, "FacetsM2")

    // C1: from M3 yes F4, from self F3
    verifyEq(FacetsC1#.facets.size, 2)
    verifyNotNull(FacetsC1#.facets.find { it.typeof == FacetsF3# })
    verifyNotNull(FacetsC1#.facets.find { it.typeof == FacetsF4# })
    verifyEq(FacetsC1#.facet(FacetsF1#, false), null)
    verifyEq(FacetsC1#.facet(FacetsF2#, false), null)
    verifyEq(FacetsC1#.facet(FacetsF3#)->n, "FacetsC1")
    verifyEq(FacetsC1#.facet(FacetsF4#)->n, "FacetsM3")

    // C1: from C2 F4, F4; self: F1
    verifyEq(FacetsC2#.facets.size, 3)
    verifyNotNull(FacetsC2#.facets.find { it.typeof == FacetsF3# })
    verifyNotNull(FacetsC2#.facets.find { it.typeof == FacetsF4# })
    verifyNotNull(FacetsC2#.facets.find { it.typeof == FacetsF1# })
    verifyEq(FacetsC2#.facet(FacetsF2#, false), null)
    verifyEq(FacetsC2#.facet(FacetsF1#)->n,  "FacetsC2")
    verifyEq(FacetsC2#.facet(FacetsF3#)->n, "FacetsC1")
    verifyEq(FacetsC2#.facet(FacetsF4#)->n, "FacetsM3")

    // Null FacetsF1
    verifyEq(FacetsNull#.facet(FacetsF1#)->n, null)

    // sanity
    verifyEq(FacetsC2#.facets.isImmutable, true)
    verifySame(FacetsC2#.facets, FacetsC2#.facets)
  }

}

**************************************************************************
** FacetsA
**************************************************************************

@FacetM1
@FacetS1 { val = "foo" }
@FacetS2 { i = 77; v = Version("9.0"); l = [1, 2, 3]; type = Str#; slot = Float#nan }
class FacetsA
{
  @FacetM1
  @FacetS1 { val = "foo" }
  @FacetS2 { i = 77; v = Version("9.0"); l = [1, 2, 3]; type = Str#; slot = Float#nan }
  Int i
}

**************************************************************************
** FacetsInherit
**************************************************************************

facet class FacetsF1 { const Str? n }
facet class FacetsF2 { const Str? n }
@FacetMeta { inherited = true } facet class FacetsF3 { const Str? n }
@FacetMeta { inherited = true } facet class FacetsF4 { const Str? n }
@FacetMeta { inherited = true } facet class FacetsF5 { const Str? n }

@FacetsF1 { n = "FacetsM1" }
@FacetsF3 { n = "FacetsM1" }
mixin FacetsM1 {}

@FacetsF2 { n = "FacetsM2" }
mixin FacetsM2 : FacetsM1 {}

@FacetsF4 { n = "FacetsM3" }
mixin FacetsM3 {}

@FacetsF3 { n = "FacetsC1" }
class FacetsC1 : FacetsM2, FacetsM3 {}

@FacetsF1 { n = "FacetsC2" }
class  FacetsC2 : FacetsC1 {}

@FacetsF1 { n = null }
class  FacetsNull {}