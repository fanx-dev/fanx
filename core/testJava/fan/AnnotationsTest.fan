//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Sep 10  Brian Frank  Creation
//

**
** AnnotationsTest
**
class AnnotationsTest : JavaTest
{

  Void test()
  {
    compile(
     Str<|using sys::Test
          using [java] java.lang
          using [java] java.lang.annotation
          using [java] fanx.interop
          using [java] fanx.test
          using [java] java.lang::Thread$State as ThreadState

          @TestAnnoA
          @TestAnnoB { value = "it;\nworks!" }
          @TestAnnoC
          {
            bool    = true
            i       = 123
            b       = -50
            s       = 1000
            l       = 456
            f       = 2f
            d       = -66f
            str1    = "foo;bar"
            enum1   = ElementType.PACKAGE
            enum2   = ThreadState.BLOCKED
            cls1    = Str#
            cls2    = Class#
            bools   = [true, false, true]
            bytes   = [2, 3]
            shorts  = [20, 30]
            ints    = [200, 300]
            longs   = [2000, 3000]
            floats  = [200f, 300f]
            doubles = [2000f, 3000f]
            strs    = ["foo", "bar"]
            enums   = [ElementType.FIELD, ElementType.METHOD]
            classes = [Thread#, Annotation#]
          }
          class Test
          {
            @TestAnnoA
            @TestAnnoB { value = "it;\nworks!" }
            Str? field

            @TestAnnoA
            @TestAnnoB { value = "it;\nworks!" }
            Void method() {}

            new make(Test t) { this.testRef = t }

            Void test()
            {
              testType
              testField
              testMethod
            }

            Void testType()
            {
              verifyEq(typeof.facets.size, 0)
              verifyErr(UnknownFacetErr#) { this.typeof.facet(TestAnnoA#) }
              verifyErr(UnknownFacetErr#) { this.typeof.facet(TestAnnoB#) }
              verifyErr(UnknownFacetErr#) { this.typeof.facet(TestAnnoC#) }

              cls := Interop.getClass(this)
              verifyEq(cls.getAnnotations.size, 3)

              verifyA(cls.getAnnotation(TestAnnoA#->toClass))
              verifyB(cls.getAnnotation(TestAnnoB#->toClass))
              verifyC(cls.getAnnotation(TestAnnoC#->toClass))
            }

            Void testField()
            {
              verifyEq(#field.facets.size, 0)
              verifyErr(UnknownFacetErr#) { #field.facet(TestAnnoA#) }
              verifyErr(UnknownFacetErr#) { #field.facet(TestAnnoB#) }

              jf := Interop.getClass(this).getField("field")
              verifyEq(jf.getAnnotations.size, 2)

              verifyA(jf.getAnnotation(TestAnnoA#->toClass))
              verifyB(jf.getAnnotation(TestAnnoB#->toClass))
            }

            Void testMethod()
            {
              verifyEq(#method.facets.size, 0)
              verifyErr(UnknownFacetErr#) { #method.facet(TestAnnoA#) }
              verifyErr(UnknownFacetErr#) { #method.facet(TestAnnoB#) }

              jm := Interop.getClass(this).getMethod("method", Class[,])
              verifyEq(jm.getAnnotations.size, 2)

              verifyA(jm.getAnnotation(TestAnnoA#->toClass))
              verifyB(jm.getAnnotation(TestAnnoB#->toClass))
            }

            Void verifyA(TestAnnoA java)
            {
              //echo("---> verifyA $fan  $java")
              verify(java is TestAnnoA)
            }

            Void verifyB(TestAnnoB java)
            {
              //echo("---> verifyB $fan  $java")
              verify(java is TestAnnoB)
              verifyEq(java.value, "it;\nworks!")
            }

            Void verifyC(TestAnnoC java)
            {
              //echo("---> verifyC $fan  $java")
              verify(java is TestAnnoC)
              verifyEq(java.bool, true)
              verifyEq(java.i,    123)
              verifyEq(java.b,    -50)
              verifyEq(java.s,    1000)
              verifyEq(java.l,    456)
              verifyEq(java.f,    2f)
              verifyEq(java.d,    -66f)
              verifyEq(java.str1,  "foo;bar")
              verifyEq(java.enum1, ElementType.PACKAGE)
              verifyEq(java.enum2, ThreadState.BLOCKED)
              verifyEq(java.cls1.getName, "java.lang.String")
              verifyEq(java.cls2.getName, "java.lang.Class")

              verifyEq(java.bools.size, 3)
              verifyEq(java.bools[0], true)
              verifyEq(java.bools[1], false)
              verifyEq(java.bools[2], true)

              verifyEq(java.bytes.size, 2)
              verifyEq(java.bytes[0], 2)
              verifyEq(java.bytes[1], 3)

              verifyEq(java.shorts.size, 2)
              verifyEq(java.shorts[0], 20)
              verifyEq(java.shorts[1], 30)

              verifyEq(java.ints.size, 2)
              verifyEq(java.ints[0], 200)
              verifyEq(java.ints[1], 300)

              verifyEq(java.longs.size, 2)
              verifyEq(java.longs[0], 2000)
              verifyEq(java.longs[1], 3000)

              verifyEq(java.floats.size, 2)
              verifyEq(java.floats[0], 200f)
              verifyEq(java.floats[1], 300f)

              verifyEq(java.doubles.size, 2)
              verifyEq(java.doubles[0], 2000f)
              verifyEq(java.doubles[1], 3000f)

              verifyEq(java.strs.size, 2)
              verifyEq(java.strs[0], "foo")
              verifyEq(java.strs[1], "bar")

              verifyEq(java.classes.size, 2)
              verifyEq(java.classes[0]->getName, "java.lang.Thread")
              verifyEq(java.classes[1]->getName, "java.lang.annotation.Annotation")

              verifyEq(java.enums.size, 2)
              verifyEq(java.enums[0], ElementType.FIELD)
              verifyEq(java.enums[1], ElementType.METHOD)
            }

            Void verifyEq(Obj? a, Obj? b) { testRef.verifyEq(a, b) }
            Void verifyErr(Type t, |Test| f) { testRef.verifyErr( t, f) }
            Void verify(Bool c) { testRef.verify(c) }
            Test? testRef
          }|>)

    obj := pod.types.first.make([this])
    obj->test
  }

}