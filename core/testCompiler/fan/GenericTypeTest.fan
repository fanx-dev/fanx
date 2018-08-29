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
    verifyEq(t.name, "Foo")
  }

  Void testRef()
  {
    compile("class Foo<T> { T? t }
             class Bar {
                Foo<Str>? foo
             }
             ")

    t := pod.types.first
    //verifyEq(t.isGeneric, true)
    verifyEq(t.name, "Foo")
  }

  Void testInherit() {
    compile(
    """
            class Super<K,V> {
              V? val
              K? key

              virtual V? getFoo(K k) {
                if (k == key) return val
                return null
              }

              virtual Void set(K k, V v) {
                val = v
                key = k
              }
            }

            class Sub<K,V> : Super<K, V> {
              override Void set(K k, V v) {
                super.set(k, v)
              }
            }

            class Main {
              Void main() {
                nlist := Sub<Str, Int>()
                nlist.set("1", 1)
                x := nlist.getFoo("1")
                echo(x)
                echo(x.isEven)
              }
            }
            """)
  }

  Void testBoxing() {
    compile(
    """class Bar<V> {
          const V a
          V b

          new make(V x) {
            a = x
            b = x
          }

          V get(V d) { d }
        }

        class Main {
          Void main() {

            bar := Bar<Int>(1)
            bar.b = 1
            Int x := bar.a
            Int y := bar.get(1)
            Int z := bar.b
            assert(x == y)
            assert(y == z)
          }
        }""")

    t := pod.types.find { it.name == "Main" }
    echo(t)
    assert(t is Type)
    t.make->main
  }

}