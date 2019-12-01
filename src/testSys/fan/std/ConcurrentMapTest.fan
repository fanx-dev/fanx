//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Feb 16  Brian Frank  Creation
//

**
** ConcurrentMapTest
**
class ConcurrentMapTest : Test
{
  Void test()
  {
    m := ConcurrentMap()
    verifyConcurrentMap(m, Str:Int[:])

    m["a"] = 10
    verifyConcurrentMap(m, Str:Int["a":10])

    m["b"] = 20
    verifyConcurrentMap(m, Str:Int["a":10, "b":20])

    m["b"] = 30
    verifyConcurrentMap(m, Str:Int["a":10, "b":30])

    m["c"] = 40
    verifyConcurrentMap(m, Str:Int["a":10, "b":30, "c":40])

    count := 0
    r := m.eachWhile |x| { count++; return count >= 2 ? "break" : null }
    verifyEq(r, "break")
    verifyEq(count, 2)

    verifyErr(Err#) { m.add("c", 50) }
    verifyConcurrentMap(m, Str:Int["a":10, "b":30, "c":40])

    verifyEq(m.remove("notThere"), null)
    verifyEq(m.remove("b"), 30)
    verifyConcurrentMap(m, Str:Int["a":10, "c":40])

    m.clear
    verifyEq(m.size, 0)
    verifyConcurrentMap(m, Str:Int[:])

    verifyEq(m.getOrAdd("a", 10), 10)
    verifyEq(m.getOrAdd("a", 20), 10)

    m.setAll(["a": 5, "b": 10, "c": 15])
    verifyConcurrentMap(m, Str:Int["a":5, "b":10, "c":15])
    m.setAll(["a": 5, "b": 10, "c": 15].toImmutable)
    verifyConcurrentMap(m, Str:Int["a":5, "b":10, "c":15])

    mut := ConcurrentMap()
    verifyErr(NotImmutableErr#) { mut["foo"] = this }
    verifyErr(NotImmutableErr#) { mut.add("foo", Buf()) }
    verifyErr(NotImmutableErr#) { mut.set("foo", Str[,]) }
    verifyErr(NotImmutableErr#) { mut.add("foo", Str[,]) }
  }

  Void verifyConcurrentMap(ConcurrentMap m, [Str:Obj] expected)
  {
    verifyEq(m.isEmpty, expected.isEmpty)
    verifyEq(m.size, expected.size)
    expected.each |v, k|
    {
      verifyEq(m[k], v)
      verify(m.containsKey(k))
    }
    verify(!m.containsKey("DNE"))

    x := Str:Int[:]
    m.each |v, k| { x[k] = v }
    verifyEq(x, expected)

    keys := m.keys
    //verifyEq(keys.typeof, Str[]#)
    verifyEq(keys.sort, expected.keys.sort)

    vals := m.vals
    //verifyEq(vals.typeof, Int[]#)
    verifyEq(vals.sort, expected.vals.sort)
  }
}