//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Mar 06  Brian Frank  Creation
//

**
** MapTest
**
class MapTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Make
//////////////////////////////////////////////////////////////////////////
/*
  Void testMake()
  {
    verifyEq(Map.make(Str:File#).typeof.signature, "[sys::Str:sys::File]")
    verifyEq(Map.make(Map#.parameterize(["K":Int#, "V":Obj?#])).typeof.signature, "[sys::Int:sys::Obj?]")
    verifyErr(ArgErr#) { x := Map.make(Map#.parameterize(["K":Int?#, "V":Obj?#])) }
  }
*/
//////////////////////////////////////////////////////////////////////////
// Equal
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    verifyEq([:], [:])
    verifyEq([0:null], [0:null])
    verifyEq([0:"a"], [0:"a"])

    verifyEq([:].hash, [:].hash)
    verifyEq([0:null].hash, [0:null].hash)
    verifyEq([0:"a"].hash, [0:"a"].hash)

    verifyNotEq([:], [0:"a"])
    verifyNotEq([0:"a"], [:])
    verifyNotEq([0:"a"], [0:null])
    verifyNotEq([0:"a"], ["f":"a"])
    verifyNotEq([0:"a"], [0:3])
    //verifyNotEq([:], Str:Str[:])
    verifyNotEq([:], null)
    verifyNotEq([0:"0"], [0:"x"])
    verifyNotEq([0:"0"], [0:"x"])
    verifyNotEq([0:"0"], "hello")
  }

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  Void testType()
  {
    verifyEq(Int:Str#, Int:Str#)
    //verifyNotEq(Int:Str#, Int:Obj#)
    //verifyNotEq(Int:Str#, Obj:Str#)
    //verifyNotEq(Int:Str#, Type.of([:]))
  }

//////////////////////////////////////////////////////////////////////////
// Is Operator
//////////////////////////////////////////////////////////////////////////

  Void testIsExplicit()
  {
    // Obj:Obj
    Obj a := Obj:Obj[:]
    verify(a is Obj)
    verify(a is Map)
    verify(a is Obj:Obj)
    verify(a is Obj:Obj)
    verifyFalse(a is Str)
    //verifyFalse(a is Str:Obj)
    //verifyFalse(a is Obj:Str)

    // Int:Str - empty
    Obj b := Str:Int[:]
    verify(b is Obj)
    verify(b is Map)
    verify(b is Obj:Obj)
    verify(b is Obj:Int)
    verify(b is Str:Obj)
    verify(b is Str:Int)
    verifyFalse(b is Str)
    verifyFalse(b is Str[])
    //verifyFalse(b is Str:Str)

    // Int:Str - with values
    Obj c := Int:Str[2:"b"]
    //verifyFalse(c is Str:Str)

    // Str:Field
    Obj d := Str:Field[:]
    verify(d is Obj)
    verify(d is Str:Obj)
    verify(d is Str:Slot)
    verify(d is Str:Field)
  }

  Void testIsInfered()
  {
    // empty Obj[Obj]
    Obj a := [:]
    verify(a is Obj:Obj)
    verifyIsType(a, Obj:Obj?#)

    // inferred Obj:Obj
    Obj b := [2:"two", "three":3]
    verify(b is Obj:Obj)
    verifyIsType(b, Obj:Obj#)

    // inferred Int:Str
    Obj c := [3:"c"]
    verify(c is Obj)
    verify(c is Int:Str)
    verify(c is Num:Str)
    verify(c is Num:Obj)
    verify(c is Obj:Obj)
    verifyIsType(c, Int:Str#)
    verifyIsType([3 : null , 4 : "d"], Int:Str?#)   // null

    Obj d := [3:"c"]
    verifyNotEq(Type.of(d), Obj:Str#)
    verifyNotEq(Type.of(d), Int:Obj#)
    verifyNotEq(Type.of(d), Charset:Bool#)

    // nullable
    Obj e := [2:"two", "three":null, "four":4]
    verifyIsType(e, Obj:Obj?#)
  }

//////////////////////////////////////////////////////////////////////////
// As Operator
//////////////////////////////////////////////////////////////////////////

  Void testAsExplicit()
  {
    Obj x := [:]

    o  := x as Obj;       verifySame(o , x)
    b  := x as Bool;      verifySame(b , null)
    s  := x as Str;       verifySame(s , null)
    m  := x as Map;       verifySame(m , x)
    ol := x as Obj:Obj;   verifySame(ol , x)
    il := x as Int:Int;   verifySame(il , x) // no runtime check
    sl := x as Int:Str;   verifySame(sl , x) // no runtime check
    s2 := x as Int:Str?;  verifySame(s2 , x) // no runtime check

    x  = [0:"a", 1:"b"]
    o  = x as Obj;       verifySame(o , x)
    b  = x as Bool;      verifySame(b , null)
    s  = x as Str;       verifySame(s , null)
    m  = x as Map;       verifySame(m , x)
    ol = x as Obj:Obj;   verifySame(ol , x)
    il = x as Int:Int;   verifySame(il , x) // no runtime check
    sl = x as Int:Str;   verifySame(sl , x) // no runtime check
    s2 = x as Int:Str?;  verifySame(s2 , x) // no runtime check

    x  = 4f
    o  = x as Obj;       verifySame(o , x)
    n := x as Num;       verifySame(o , n)
    f := x as Float;     verifySame(o , f)
    m  = x as Map;       verifySame(m , null)
    ol = x as Obj:Obj;   verifySame(ol, null)
    il = x as Int:Int;   verifySame(il, null)
  }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////
/*
  Void testReflect()
  {
    a := [:]
    t := Type.of(a)
    verifyEq(t.base,      Map#)
    verifyEq(t.base.base, Obj#)
    //verifyEq(t.pod.name,  "std")
    //verifyEq(t.name,      "Map")
    //verifyEq(t.qname,     "sys::Map")
    //verifyEq(t.signature, "[sys::Obj:sys::Obj?]")
    //verifyEq(t.toStr,     "[sys::Obj:sys::Obj?]")
    verifyEq(t.method("isEmpty").returns,  Bool#)
    verifyEq(t.method("get").returns,      Obj?#)
    verifyEq(t.method("get").params[0].type, Obj#)
    verifyEq(t.method("get").params[1].type, Obj?#)
    //verifyEq(t.method("set").returns,      Obj:Obj?#)
    verifyEq(t.method("set").params[0].type, Obj#)
    verifyEq(t.method("set").params[1].type, Obj?#)
    verifyEq(t.method("each").params[0].type, |Obj? v, Obj k->Void|#)
    verifyNotEq(t.method("each").params[0].type, |Str v, Obj k->Void|#)

    b := [0:"zero"]
    t = Type.of(b)
    verifyEq(t.base,      Map#)
    verifyEq(t.base.base, Obj#)
    //verifyEq(t.pod.name,  "std")
    //verifyEq(t.name,      "Map")
    //verifyEq(t.qname,     "sys::Map")
    //verifyEq(t.signature, "[sys::Int:sys::Str]")
    //verifyEq(t.toStr,     "[sys::Int:sys::Str]")
    verifyEq(t.method("isEmpty").returns,  Bool#)
    verifyEq(t.method("get").returns,      Str?#)
    verifyEq(t.method("get").params[0].type, Int#)
    verifyEq(t.method("get").params[1].type, Str?#)
    //verifyEq(t.method("set").returns,      Int:Str#)
    verifyEq(t.method("set").params[0].type, Int#)
    verifyEq(t.method("set").params[1].type, Str#)
    //verifyEq(t.field("def").type, Str?#)
    verifyEq(t.method("keys").returns,     Int[]#)
    verifyEq(t.method("vals").returns,     Str[]#)
    verifyEq(t.method("each").params[0].type, |Str v, Int k->Void|#)
    verifyNotEq(t.method("each").params[0].type, |Obj v, Int i->Void|#)

    c := [ArgErr.make:[0,1,2]]
    t = Type.of(c)
    verifyEq(t.base,      Map#)
    verifyEq(t.base.base, Obj#)
    //verifyEq(t.pod.name,  "std")
    //verifyEq(t.name,      "Map")
    //verifyEq(t.qname,     "sys::Map")
    //verifyEq(t.signature, "[sys::ArgErr:sys::Int[]]")
    //verifyEq(t.toStr,     "[sys::ArgErr:sys::Int[]]")
    verifyEq(t.method("isEmpty").returns,   Bool#)
    verifyEq(t.method("get").returns,       Int[]?#)
    verifyEq(t.method("get").params[0].type,  ArgErr#)
    //verifyEq(t.method("set").returns,       ArgErr:Int[]#)
    //verifyEq(t.method("set").returns,       [ArgErr:Int[]]#)
    verifyEq(t.method("set").params[0].type,  ArgErr#)
    verifyEq(t.method("set").params[1].type,  Int[]#)
    verifyEq(t.method("keys").returns,      ArgErr[]#)
    verifyEq(t.method("vals").returns,      Int[][]#)
    verifyEq(t.method("each").params[0].type, |Int[] v, ArgErr k->Void|#)
  }
  */
//////////////////////////////////////////////////////////////////////////
// Add/Remove
//////////////////////////////////////////////////////////////////////////

  Void testItems()
  {
    m := Int:Str?[:]
    verifyEq(m, Int:Str?[:])
    verifyEq(m[0], null)
    verify(m.isEmpty)
    //verify(m.get(null) == null)
    //verifyFalse(m.containsKey(null))

    m[5] = "five"
    verifyEq(m, Int:Str?[5:"five"])
    verifyEq(m[0], null)
    verifyEq(m[5], "five")
    verifyEq(m.get(5), "five")
    verifyEq(m.get(3), null)
    verifyEq(m.get(3, "?"), "?")
    verifyFalse(m.isEmpty)

    m[9] = "nine"
    verifyEq(m, Int:Str?[5:"five", 9:"nine"])
    verifyEq(m[0], null)
    verifyEq(m[5], "five")
    verifyEq(m[9], "nine")
    verifyFalse(m.isEmpty)

    m.add(2, "two")
    verifyEq(m, Int:Str?[2:"two", 5:"five", 9:"nine"])
    verifyEq(m[0], null)
    verifyEq(m[2], "two")
    verifyEq(m[5], "five")
    verifyEq(m[9], "nine")
    verifyErr(ArgErr#) { m.add(2, "err") }
    verifyEq(m[2], "two")

    m[9] = null
    verifyEq(m, Int:Str?[2:"two", 5:"five", 9:null])
    verifyEq(m[0], null)
    verifyEq(m[2], "two")
    verifyEq(m[5], "five")
    verifyEq(m[9], null)
    verifyEq(m.get(0, "?"), "?")
    verifyEq(m.get(2, "?"), "two")
    verifyEq(m.get(9, "?"), null)
    verifyErr(ArgErr#) { m.add(5, "err") }
    verifyErr(ArgErr#) { m.add(9, "err") }

    m.set(9, "nine")
    t := Int:Str?[2:"two", 5:"five", 9:"nine"]
    verifyEq(m.size, t.size)
    verifyEq(m, Int:Str?[2:"two", 5:"five", 9:"nine"])
    verifyEq(m[0], null)
    verifyEq(m[2], "two")
    verifyEq(m[5], "five")
    verifyEq(m[9], "nine")
    verifyErr(ArgErr#) { m.add(9, "err") }
    verifyEq(m[9], "nine")
    m[9] = null

    m.remove(9)
    verifyEq(m, Int:Str?[2:"two", 5:"five"])
    //verifyEq(m[null], null)
    verifyEq(m[0], null)
    verifyEq(m[2], "two")
    verifyEq(m[5], "five")
    verifyEq(m[9], null)
    //verify(!m.containsKey(null))

    m.remove(5)
    verifyEq(m, Int:Str?[2:"two"])
    //verifyEq(m[null], null)
    verifyEq(m[0], null)
    verifyEq(m[2], "two")
    verifyEq(m[5], null)
    verifyEq(m[9], null)

    m.remove(2)
    verifyEq(m, Int:Str?[:])
    //verifyEq(m[null], null)
    verifyEq(m[0], null)
    verifyEq(m[2], null)
    verifyEq(m[5], null)
    verifyEq(m[9], null)
    verify(m.isEmpty)

    for (Int i :=0;   i<10000; ++i) m[i] = i.toStr
    for (Int i :=0;   i<10000; ++i) verifyEq(m[i], i.toStr)
    for (Int i :=500; i<10000; ++i) m.remove(i)
    for (Int i :=0;   i<500;   ++i) verifyEq(m[i], i.toStr)
    for (Int i :=500; i<1000;  ++i) verifyEq(m[i], null)

    //verifyErr(NullErr#) { m.set(null, "foo") }
    //verifyErr(NullErr#) { m.add(null, "foo") }

    em := [:]
    verifyErr(NotImmutableErr#) { em.add(this, "foo") }
    verifyErr(NotImmutableErr#) { em.set(this, "foo") }
    verifyErr(NotImmutableErr#) { em[this] = "foo" }
    verify(em.isEmpty)
  }

//////////////////////////////////////////////////////////////////////////
// getOrThrow
//////////////////////////////////////////////////////////////////////////

  Void testGetOrThrow()
  {
    m := ["a": "A", "b": null]
    verifyEq(m.getOrThrow("a"), "A")
    verifyEq(m.getOrThrow("b"), null)
    verifyErr(UnknownKeyErr#) { x := m.getOrThrow("c") }

    verifyEq(m.getChecked("a"), "A")
    verifyEq(m.getChecked("b"), null)
    verifyEq(m.getChecked("c", false), null)
    verifyErr(UnknownKeyErr#) { x := m.getChecked("c") }
    verifyErr(UnknownKeyErr#) { x := m.getChecked("c", true) }
  }

//////////////////////////////////////////////////////////////////////////
// Null Vals
//////////////////////////////////////////////////////////////////////////

  Void testNullVals()
  {
    m := ["a": "A", "b": null]
    //m.def = "def field"

    verifyEq(m.size, 2)

    verify(m.containsKey("a"))
    verify(m.containsKey("b"))

    verifyEq(m["a"], "A")
    verifyEq(m["b"], null)
    verifyEq(m.get("c", "def field"), "def field")
    verifyEq(m.get("b", "def param"), null)
    verifyEq(m.get("x", "def param"), "def param")

    keys := Str[,]
    vals := Str?[,]
    m.each |Str? v, Str k| { keys.add(k); vals.add(v) }
    verifyEq(keys.sort, ["a", "b"])
    verifyEq(vals.sort, [null, "A"])
  }

//////////////////////////////////////////////////////////////////////////
// Duplicate
//////////////////////////////////////////////////////////////////////////

  Void testDup()
  {
    a := ['a':"A", 'b':"B", 'c':"C"]
    verifyEq(a.size, 3)
    verifyIsType(a, Int:Str#)
    verifyEq(a, ['a':"A", 'b':"B", 'c':"C"])

    b := a.dup
    verifyEq(b.size, 3)
    verifyIsType(b, Int:Str#)
    verifyEq(b, ['a':"A", 'b':"B", 'c':"C"])

    a['a'] = "X"
    verifyEq(a, ['a':"X", 'b':"B", 'c':"C"])
    verifyEq(b, ['a':"A", 'b':"B", 'c':"C"])

    a.clear
    verifyEq(a, Int:Str[:])
    verifyEq(b, ['a':"A", 'b':"B", 'c':"C"])
  }

//////////////////////////////////////////////////////////////////////////
// Get or Add
//////////////////////////////////////////////////////////////////////////

  Void testGetOrAdd()
  {
    m := Str:Str?[:]
    verifyEq(m.getOrAdd("a") {"_a_"}, "_a_")
    verifyEq(m.getOrAdd("a") {"_x_"}, "_a_")
    verifyEq(m.getOrAdd("a") {throw Err()}, "_a_")
    verifyEq(m, Str:Str?["a":"_a_"])

    verifyEq(m.getOrAdd("b") {"_${it}_"}, "_b_")
    verifyEq(m.getOrAdd("c") |k| {"_${k}_"}, "_c_")
    verifyEq(m, Str:Str?["a":"_a_", "b":"_b_", "c":"_c_"])

    verifyEq(m.getOrAdd("b") {throw Err()}, "_b_")

    verifyEq(m.getOrAdd("x") {null}, null)
    verifyEq(m, ["a":"_a_", "b":"_b_", "c":"_c_", "x":null])
    verifyEq(m.getOrAdd("x") {throw Err()}, null)
    verifyEq(m.getOrAdd("x") {"_x_"}, null)
    verifyEq(m, Str:Str?["a":"_a_", "b":"_b_", "c":"_c_", "x":null])

    ro := m.ro
    verifyEq(ro.getOrAdd("a") { throw Err() }, "_a_")
    verifyEq(m.getOrAdd("d") { "_${it}_" }, "_d_")
    verifyEq(m, Str:Str?["a":"_a_", "b":"_b_", "c":"_c_", "d":"_d_", "x":null])
    verifyEq(ro, Str:Str?["a":"_a_", "b":"_b_", "c":"_c_", "x":null])
    verifyErr(ReadonlyErr#) { ro.getOrAdd("d") { "x" } }
  }

//////////////////////////////////////////////////////////////////////////
// SetAll / AddAll
//////////////////////////////////////////////////////////////////////////

  Void testSetAddAll()
  {
    m := [2:2ms, 3:3ms, 4:4ms]
    verifyEq(m.setAll([1:10ms, 3:30ms]), [1:10ms, 2:2ms, 3:30ms, 4:4ms])

    m = [2:2ms, 3:3ms, 4:4ms]
    verifyEq(m.addAll([1:10ms, 5:50ms]), [1:10ms, 2:2ms, 3:3ms, 4:4ms, 5:50ms])
    verifyErr(ArgErr#) { m.addAll([1:10ms, 5:50ms]) }
  }

//////////////////////////////////////////////////////////////////////////
// SetList / AddList
//////////////////////////////////////////////////////////////////////////

  Void testSetAddList()
  {
    verifyEq([2:20, 3:30].setList([3, 4, 5]),
             [2:20, 3:3, 4:4, 5:5])

    verifyEq([2:20, 3:30].setList([3, 4, 5]) |Int v->Int| { return v*10 },
             [2:20, 3:30, 30:3, 40:4, 50:5])

    verifyEq([2:20, 3:30, 6:60].setList([3, 4, 5]) |Int v, Int i->Int| { return i },
             [0:3, 1:4, 2:5, 3:30, 6:60])

    verifyEq([2:20, 3:30].addList([4, 5]),
             [2:20, 3:30, 4:4, 5:5])

    verifyEq([2:2ms, 3:3ms].addList([4ms, 5ms]) |Duration v->Int| { return v.toMillis },
             [2:2ms, 3:3ms, 4:4ms, 5:5ms])

    verifyEq([2:2ms, 3:3ms].addList([4ms, 5ms]) |Duration v, Int i->Int| { return i },
             [2:2ms, 3:3ms, 0:4ms, 1:5ms])

    verifyErr(ArgErr#) { [2:20].addList([2]) }
    verifyErr(ArgErr#) { [2:20].addList([33]) |Int v->Int| { return 2 } }
    verifyErr(ArgErr#) { [2:20].addList([33]) |Int v, Int i->Int| { return 2 } }
  }

//////////////////////////////////////////////////////////////////////////
// AddIfNotNull
//////////////////////////////////////////////////////////////////////////

  Void testAddIfNotNull()
  {
    m := Str:Str[:]
    verifySame(m.addIfNotNull("foo", null), m)
    verifyEq(m, Str:Str[:])
    verifySame(m.addIfNotNull("foo", "bar"), m)
    verifyEq(m, Str:Str["foo":"bar"])
    verifySame(m.addIfNotNull("foo", null), m)
    verifyEq(m, Str:Str["foo":"bar"])
  }

//////////////////////////////////////////////////////////////////////////
// Clear
//////////////////////////////////////////////////////////////////////////

  Void testClear()
  {
    map := ["a":"A", "b":"B", "c":"C"]
    verifyEq(map.size, 3)
    verifyFalse(map.isEmpty)

    map.clear
    verifyEq(map.size, 0)
    verify(map.isEmpty)

    map["d"] = "D"
    verifyEq(map.size, 1)
    verifyFalse(map.isEmpty)
    verifyEq(map, ["d": "D"])
  }

  Void testReset() {
    map := [:]
    map["A"] = "B"
    map.clear
    map["A"] = "B"
    verifyEq(map["A"], "B")
  }

//////////////////////////////////////////////////////////////////////////
// Keys/Values
//////////////////////////////////////////////////////////////////////////

  Void testKeyValueLists()
  {
    m := [0:"zero"]
    verifyEq(m.keys,   [0])
    verifyEq(m.vals, ["zero"])

    m = [0:"zero", 1:"one"]
    verifyEq(m.keys.sort,   [0, 1])
    verifyEq(m.vals.sort, ["one", "zero"])

    m = [0:"zero", 1:"one", 2:"two"]
    verifyEq(m.keys.sort,   [0, 1, 2])
    verifyEq(m.vals.sort, ["one", "two", "zero"])

    m = [0:"zero", 1:"one", 2:"two", 3:"three"]
    verifyEq(m.keys.sort,   [0, 1, 2, 3])
    verifyEq(m.vals.sort, ["one", "three", "two", "zero"])

    m = [0:"zero", 1:"one", 2:"two", 3:"three", 4:"four"]
    verifyEq(m.keys.sort,   [0, 1, 2, 3, 4])
    verifyEq(m.vals.sort, ["four", "one", "three", "two", "zero"])

    x := ["a":[0], "b":[0,1], "c":[0,1,2]]
    verifyEq(x.keys.sort,   ["a", "b", "c"])
    verifyEq(x.vals.sort |Int[] a, Int[] b->Int| { return a.size <=> b.size },
             [[0], [0,1], [0,1,2]])
  }

//////////////////////////////////////////////////////////////////////////
// Join
//////////////////////////////////////////////////////////////////////////

  Void testJoin()
  {
    map := [0:"zero", 1:"one", 2:"two"]
    verifyEq([:].join(","), "")
    verifyJoin(map, ',', ["0: zero", "1: one", "2: two"], null)
    verifyJoin(map, '|', ["(0=zero)", "(1=one)", "(2=two)"]) |Str v, Int k->Str| { return "($k=$v)" }
  }

  Void verifyJoin([Int:Str] map, Int sep, Str[] expected, |Str,Int->Str|? f)
  {
    actual := map.join(sep.toChar, f).split(sep)
    verifyEq(actual.sort, expected.sort)
    verifyEq(map.join(sep.toChar), map.join(sep.toChar, null))
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq([:].toCode, "[:]")

    verifyEq(Str:Str[:].toCode, "[:]")

    s := [3:"three", 4:"four"].toCode
    echo(s)
    verify(s == "[3:\"three\", 4:\"four\"]" ||
           s == "[4:\"four\", 3:\"three\"]")

    verifyEq(Int:Num[][1:[2,3f]].toCode,
             "[1:[2, 3.0f]]")
  }

//////////////////////////////////////////////////////////////////////////
// Case Insensitive
//////////////////////////////////////////////////////////////////////////

  Void testCaseInsensitive()
  {
    m := CaseInsensitiveMap<Str,Int>()
    //m.caseInsensitive = true

    // add, get, containsKey
    m.add("a", 'a')
    verifyEq(m["a"], 'a')
    verifyEq(m["A"], 'a')
    verifyEq(m.containsKey("a"), true)
    verifyEq(m.containsKey("A"), true)
    verifyEq(m.containsKey("ab"), false)

    // add, get, containsKey
    m.add("B", 'b')
    verifyEq(m["b"], 'b')
    verifyEq(m["B"], 'b')
    verifyEq(m.containsKey("b"), true)
    verifyEq(m.containsKey("B"), true)

    // add existing
    verifyErr(ArgErr#) { m.add("B", 'x') }
    verifyErr(ArgErr#) { m.add("b", 'x') }
    verifyErr(ArgErr#) { m.add("A", 'x') }

    // get, set, containsKey
    m.set("Charlie", 'x')
    m.set("CHARLIE", 'c')
    verifyEq(m["a"], 'a')
    verifyEq(m["A"], 'a')
    verifyEq(m["b"], 'b')
    verifyEq(m["B"], 'b')
    verifyEq(m["charlie"], 'c')
    verifyEq(m["charlIE"], 'c')
    verifyEq(m.containsKey("a"), true)
    verifyEq(m.containsKey("A"), true)
    verifyEq(m.containsKey("b"), true)
    verifyEq(m.containsKey("B"), true)
    verifyEq(m.containsKey("charlie"), true)
    verifyEq(m.containsKey("CHARLIE"), true)

    // keys, values
    verifyEq(m.keys.sort, ["B", "Charlie", "a"])
    verifyEq(m.vals.sort, ['a', 'b', 'c'])

    // getOrAdd
    verifyEq(m.getOrAdd("cHaRlIe") { throw Err() }, 'c')
    verifyEq(m.getOrAdd("Delta") { 'd' }, 'd')
    verifyEq(m.getOrAdd("delta") { throw Err() }, 'd')
    verifyEq(m.keys.sort, ["B", "Charlie", "Delta", "a"])
    m.remove("delta")

    // each
    x := Str:Int[:]
    m.each |Int v, Str k| { x[k] = v }
    verifyEq(x, ["a":'a', "B":'b', "Charlie":'c'])
    //verifyEq(x, ["a":'a', "b":'b', "charlie":'c'])

    // find, findAll, exclude, reduce, map
    /*
    verifyEq(m.find |Int v, Str k->Bool| { return k == "a" }, 'a')
    verifyEq(m.find |Int v, Str k->Bool| { return k == "B" }, 'b')
    verifyEq(m.findAll |Int v, Str k->Bool| { return k == "B" }, ["B":'b'])
    verifyEq(m.exclude |Int v, Str k->Bool| { return k == "B" }, ["a":'a', "Charlie":'c'])
    verifyEq(((Str[])m.reduce(Str[,])
      |Obj r, Int v, Str k->Obj| { return ((Str[])r).add(k) }).sort,
      ["B", "Charlie", "a"])
    verifyEq(m.map |Int v, Str k->Str| { k }, ["a":"a", "B":"B", "Charlie":"Charlie"])
    */
    // dup
    d := m.dup
    verifyEq(d.keys.sort, ["B", "Charlie", "a"])
    verifyEq(d.vals.sort, ['a', 'b', 'c'])
    d["charlie"] = 'x'
    verifyEq(m["Charlie"], 'c')
    verifyEq(m["charlIE"], 'c')
    verifyEq(d["Charlie"], 'x')
    verifyEq(d["charlIE"], 'x')

    // remove
    verifyEq(m.remove("CHARLIE"), 'c')
    verifyEq(m["charlie"], null)
    verifyEq(m.containsKey("Charlie"), false)
    verifyEq(m.keys.sort, ["B", "a"])


    // addAll (both not insensitive, and insensitive)
    m.addAll(["DAD":'d', "Egg":'e'])
    q := Str:Int[:]; //q.caseInsensitive = true;
    q["foo"] = 'f'
    m.addAll(q)
    verifyEq(m.keys.sort, ["B", "DAD", "Egg", "a", "foo"])
    verifyEq(m["dad"], 'd')
    verifyEq(m["egg"], 'e')
    verifyEq(m["b"], 'b')
    verifyEq(m["FOO"], 'f')

    // setAll (both not insensitive, and insensitive)
    m.setAll(["dad":'D', "EGG":'E'])
    q["FOO"] = 'F'
    m.setAll(q)
    verifyEq(m.keys.sort, ["B", "DAD", "Egg", "a", "foo"])
    verifyEq(m["DaD"], 'D')
    verifyEq(m["eGg"], 'E')
    verifyEq(m["b"], 'b')
    verifyEq(m["Foo"], 'F')
    verifyEq(m.containsKey("EgG"), true)
    verifyEq(m.containsKey("A"), true)

    // to readonly
    r := m.ro
    //verifyEq(r.caseInsensitive, true)
    verifyEq(r.keys.sort, ["B", "DAD", "Egg", "a", "foo"])
    verifyEq(r["DaD"], 'D')
    verifyEq(r["eGg"], 'E')
    verifyEq(r["b"], 'b')
    verifyEq(r["Foo"], 'F')
    verifyEq(r.containsKey("EgG"), true)
    verifyEq(r.containsKey("A"), true)

    // to immutable
    i := m.toImmutable
    //verifyEq(i.caseInsensitive, true)
    verifyEq(i.keys.sort, ["B", "DAD", "Egg", "a", "foo"])
    verifyEq(i["DaD"], 'D')
    verifyEq(i["eGg"], 'E')
    verifyEq(i["b"], 'b')
    verifyEq(i["Foo"], 'F')
    verifyEq(i.containsKey("EgG"), true)
    verifyEq(i.containsKey("A"), true)

    // to rw
    rw := r.rw
    //verifyEq(rw.caseInsensitive, true)
    verifyEq(rw.remove("Dad"), 'D')
    rw["fOo"] = '^'
    verifyEq(r.keys.sort, ["B", "DAD", "Egg", "a", "foo"])
    verifyEq(rw.keys.sort, ["B", "Egg", "a", "foo"])
    verifyEq(r["DaD"], 'D')
    verifyEq(r["eGg"], 'E')
    verifyEq(r["b"], 'b')
    verifyEq(r["Foo"], 'F')
    verifyEq(rw["DaD"], null)
    verifyEq(rw["eGg"], 'E')
    verifyEq(rw["b"], 'b')
    verifyEq(rw["Foo"], '^')

    // set false
    /*
    m.clear
    //m.caseInsensitive = false
    m.add("Alpha", 'a').add("Beta", 'b')
    verifyEq(m["Alpha"], 'a')
    //verifyEq(m["alpha"], null)
    //verifyEq(m["ALPHA"], null)
    verifyEq(m.containsKey("Beta"), true)
    //verifyEq(m.containsKey("beta"), false)
    */

    // equals
    m.clear
    //m.caseInsensitive = true
    m.add("Alpha", 'a').add("Beta", 'b')
    verifyEq(m, ["Alpha":'a', "Beta":'b'])
    //verifyEq(m, ["alpha":'a', "beta":'b'])
    verifyNotEq(m, ["alpha":'a', "Beta":'b'])
    verifyNotEq(m, ["Alpha":'x', "Beta":'b'])
    verifyNotEq(m, ["Beta":'b'])
    verifyNotEq(m, ["Alpha":'a', "Beta":'b', "C":'c'])

    /*
    // errors
    verifyErr(UnsupportedErr#) { Int:Str[:].caseInsensitive = true }
    verifyErr(UnsupportedErr#) { Obj:Str[:].caseInsensitive = true }
    verifyErr(UnsupportedErr#) { ["a":0].caseInsensitive = true }
    verifyErr(UnsupportedErr#) { Str:Str[:] { ordered = true; caseInsensitive = true } }
    verifyErr(ReadonlyErr#) { xro := Str:Str[:].ro; xro.caseInsensitive = true }
    */
  }

//////////////////////////////////////////////////////////////////////////
// Ordered
//////////////////////////////////////////////////////////////////////////

  Void testOrdered()
  {
    m := OrderedMap<Str,Int>()

    // add, get, containsKey
    10.times |Int i| { m.add(i.toStr, i) }
    verifyEq(m["0"], 0)
    verifyEq(m["9"], 9)
    verifyEq(m.containsKey("2"), true)
    verifyEq(m.containsKey("7"), true)
    verifyEq(m.containsKey("x"), false)
    verifyErr(ArgErr#) { m.add("4", 99) }

    // keys, values
    verifyEq(m.keys, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    verifyEq(m.vals, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

    // each
    n := 0
    m.each |Int v, Str k|
    {
      verifyEq(v, n)
      verifyEq(k, n.toStr)
      n++
    }

    // find, findAll, exclude, reduce, map
    verifyEq(m.find |Int v, Str k->Bool| { return k == "4" }, 4)
    verifyEq(m.find |Int v, Str k->Bool| { return k == "x" }, null)
    verifyEq(m.findAll |Int v, Str k->Bool| { return k.toInt.isOdd  }, ["1":1, "3":3, "5":5, "7":7, "9":9])
    verifyEq(m.exclude |Int v, Str k->Bool| { return k.toInt.isOdd }, ["0":0, "2":2, "4":4, "6":6, "8":8])
    verifyEq(m.reduce("") |Str r, Int v->Obj| { return r+v }, "0123456789")

    // dup
    d := m.dup
    verifyEq(d.keys, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    verifyEq(d.vals.size, 10)
    verifyEq(d.vals, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

    // remove
    verifyEq(m.remove("5"), 5)
    verifyEq(m["5"], null)
    verifyEq(m.containsKey("5"), false)
    verifyEq(m.keys, ["0", "1", "2", "3", "4", "6", "7", "8", "9"])
    verifyEq(m.vals, [0, 1, 2, 3, 4, 6, 7, 8, 9])

    // addAll
    m.addAll(OrderedMap<Str, Int> { add("5", 5); add("10",10) })
    verifyEq(m.keys, ["0", "1", "2", "3", "4", "6", "7", "8", "9", "5", "10"])
    verifyEq(m.vals, [0, 1, 2, 3, 4, 6, 7, 8, 9, 5, 10])

    // setAll
    m["1"] = 11
    m.setAll(["6":66, "8":88])
    verifyEq(m.keys, ["0", "1", "2", "3", "4", "6", "7", "8", "9", "5", "10"])
    verifyEq(m.vals, [0, 11, 2, 3, 4, 66, 7, 88, 9, 5, 10])

    // to readonly
    r := m.ro
    //verifyEq(r.ordered, true)
    verifyEq(r.keys, ["0", "1", "2", "3", "4", "6", "7", "8", "9", "5", "10"])
    verifyEq(r.vals, [0, 11, 2, 3, 4, 66, 7, 88, 9, 5, 10])
    verifyEq(r["6"], 66)
    verifyErr(ReadonlyErr#) { r["3"] = 333 }

    // to immutable
    i := m.toImmutable
    m.clear
    //verifyEq(i.ordered, true)
    verifyEq(i.keys, ["0", "1", "2", "3", "4", "6", "7", "8", "9", "5", "10"])
    verifyEq(i.vals, [0, 11, 2, 3, 4, 66, 7, 88, 9, 5, 10])
    verifyEq(i["10"], 10)
    verifyErr(ReadonlyErr#) { i["3"] = 333 }

    // to rw
    rw := r.rw
    //verifyEq(rw.ordered, true)
    verifyEq(rw.remove("10"), 10)
    verifyEq(rw.keys, ["0", "1", "2", "3", "4", "6", "7", "8", "9", "5"])
    verifyEq(rw.vals, [0, 11, 2, 3, 4, 66, 7, 88, 9, 5])

    // set false
    /*
    if (!isJs)
    {
      m.ordered = false
      100.times |Int j| { m.add(j.toStr, j) }
      verifyNotEq(m.keys, m.keys.sort |a,b| {a.toInt <=> b.toInt })
      verifyNotEq(m.vals, m.vals.sort)
    }
    */

    /*
    // errors
    verifyErr(UnsupportedErr#) { ["a":0].ordered = true }
    verifyErr(UnsupportedErr#) { Str:Str[:] { caseInsensitive = true; ordered = true } }
    verifyErr(ReadonlyErr#) { xro := Str:Str[:].ro; xro.ordered = true }
    */
  }

//////////////////////////////////////////////////////////////////////////
// Def
//////////////////////////////////////////////////////////////////////////

  Void testDef()
  {
    a := [0:"zero"]
    verifyEq(a.defV, null)
    verifyEq(a[0], "zero")
    verifyEq(a[3], null)
    verifyEq(a.get(3, "x"), "x")

    a.defV = ""
    verifyEq(a.defV, "")
    verifyEq(a[0], "zero")
    verifyEq(a[3], "")
    verifyEq(a.get(3, "x"), "x")

    a = a.ro
    verifyEq(a.defV, "")
    verifyEq(a[0], "zero")
    verifyEq(a[3], "")
    verifyEq(a.get(3, "x"), "x")
    verifyErr(ReadonlyErr#) { a.defV = null }

    a = a.rw
    verifyEq(a.defV, "")
    verifyEq(a[0], "zero")
    verifyEq(a[3], "")
    verifyEq(a.get(3, "x"), "x")
    a.defV = "?"
    verifyEq(a[3], "?")

    a = a.toImmutable
    verifyEq(a.defV, "?")
    verifyEq(a[0], "zero")
    verifyEq(a[3], "?")
    verifyEq(a.get(3, "x"), "x")
    verifyErr(ReadonlyErr#) { a.defV = null }
    verifyEq(a.defV, "?")

    b := ["x":[0, 1]] { defV = Int[,].toImmutable }
    verifyEq(b["x"], [0, 1])
    verifyEq(b["y"], Int[,])
    verifyErr(NotImmutableErr#) { b.defV = [3] }
  }

//////////////////////////////////////////////////////////////////////////
// Each
//////////////////////////////////////////////////////////////////////////

  Void testEach()
  {
    keys := Int[,]
    vals := Str[,]

    // empty list
    [Int:Str][:].each |Str val, Int key|
    {
      vals.add(val)
      keys.add(key)
    }
    verifyEq(keys, Int[,])
    verifyEq(vals, Str[,]);

    // list of one
    keys.clear; vals.clear;
    [0:"zero"].each |Str val, Int key|
    {
      vals.add(val)
      keys.add(key)
    }
    verifyEq(keys, [0])
    verifyEq(vals, ["zero"]);

    // list of two
    keys.clear; vals.clear;
    [0:"zero", 1:"one"].each |Str val, Int key|
    {
      vals.add(val)
      keys.add(key)
    }
    verify(keys.size == 2);
    verify(keys.contains(0)); verify(keys.index(0) == vals.index("zero"));
    verify(keys.contains(1)); verify(keys.index(1) == vals.index("one"));

    // list of ten
    keys.clear; vals.clear;
    [0:"zero", 1:"one", 2:"two", 3:"three", 4:"four",
     5:"five", 6:"six", 7:"seven", 8:"eight", 9:"nine"].each |Str val, Int key|
    {
      vals.add(val)
      keys.add(key)
    }
    verify(keys.size == 10);
    verify(keys.contains(0)); verify(keys.index(0) == vals.index("zero"));
    verify(keys.contains(1)); verify(keys.index(1) == vals.index("one"));
    verify(keys.contains(2)); verify(keys.index(2) == vals.index("two"));
    verify(keys.contains(3)); verify(keys.index(3) == vals.index("three"));
    verify(keys.contains(4)); verify(keys.index(4) == vals.index("four"));
    verify(keys.contains(5)); verify(keys.index(5) == vals.index("five"));
    verify(keys.contains(6)); verify(keys.index(6) == vals.index("six"));
    verify(keys.contains(7)); verify(keys.index(7) == vals.index("seven"));
    verify(keys.contains(8)); verify(keys.index(8) == vals.index("eight"));
    verify(keys.contains(9)); verify(keys.index(9) == vals.index("nine"));
  }

//////////////////////////////////////////////////////////////////////////
// EachWhile
//////////////////////////////////////////////////////////////////////////

  Void testEachWhile()
  {
    x := [0:"0", 1:"1", 2:"2", 3:"3"]
    verifyEq(x.eachWhile |Str v->Str?| { return v == "2" ? "!" : null }, "!")
    verifyEq(x.eachWhile |Str v->Str?| { return v == "9" ? "!" : null }, null)
    verifyEq(x.eachWhile |Str v, Int k->Str?| { return k == 3 ? v : null }, "3")
    verifyEq(x.eachWhile |Str v, Int k->Str?| { return k == 9 ? v : null }, null)
  }

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testFind()
  {
    map := [0:"zero", 1:"one", 2:"two", 3:"three", 4:"four"]

    // find
    verifyEq(map.find |Str v, Int k->Bool| { return k == 2 }, "two")
    verifyEq(map.find |Str v, Int k->Bool| { return v == "four" }, "four")
    verifyEq(map.find |Str v, Int k->Bool| { return false }, null)
    verifyEq(map.find |Str v->Bool| { return false }, null)
    verifyEq(map.find |->Bool| { return false }, null)

    // typed assign
    Str x := map.find |Str v->Bool| { return v.size == 5 }
    verifyEq(x, "three")

    // findAll
    verifyEq(map.findAll|Str v, Int k->Bool| { return v.size == 3 }, [1:"one", 2:"two"])
    verifyEq(map.findAll|Str v, Int k->Bool| { return k % 2 == 0 },  [0:"zero", 2:"two", 4:"four"])
    verifyEq(map.findAll|Str v, Int k->Bool| { return false },  Int:Str[:])
    verifyEq(map.findAll|Str v->Bool| { return false },  Int:Str[:])
    verifyEq(map.findAll|->Bool| { return false },  Int:Str[:])

    // exclude
    map2 := ["off":0, "slow":50, "fast":100]
    verifyEq(map2.exclude|Int v->Bool| { return v == 0 }, ["slow":50, "fast":100])
    verifyEq(map2.exclude|Int v->Bool| { return true }, Str:Int[:])

    // typed assign
    Int:Str a := map.findAll |Str v->Bool| { return v.size == 4 }
    verifyEq(a, [0:"zero", 4:"four"])

    // ordered
    mo := OrderedMap<Str,Int>()
    //mo.ordered = true
    mo.add("one",   1)
    mo.add("two",   2)
    mo.add("three", 3)
    mo.add("four",  4)
    mx1 := mo.findAll { true }
    mx2 := mo.exclude { false }
    //verifyEq(mx1.ordered, true)
    //verifyEq(mx2.ordered, true)
    verifyEq(mx1.keys, ["one", "two", "three", "four"])
    verifyEq(mx2.keys, ["one", "two", "three", "four"])

    // case insensitive
    mc := CaseInsensitiveMap<Str,Int>()
    //mc.caseInsensitive = true
    mc.add("One",   1)
    mc.add("TWO",   2)
    mc.add("three", 3)
    mc.add("Four",  4)
    mcx1 := mc.findAll { it.isEven }
    mcx2 := mc.exclude { it.isOdd }
    //verifyEq(mx1.caseInsensitive, true)
    //verifyEq(mx2.caseInsensitive, true)
    verifyEq(mcx1["two"], 2)
    verifyEq(mcx2["two"], 2)
  }

//////////////////////////////////////////////////////////////////////////
// Any/All
//////////////////////////////////////////////////////////////////////////

  Void testAnyAll()
  {
    verifyEq([:].any |Obj o->Bool| { false }, false)
    verifyEq([:].all |Obj o->Bool| { false }, true)

    m := ['a':"Alpha", 'b': "Bravo", 'c':"Charlie", 'd':"Delta", 'e':"Echo"]

    verifyEq(m.any |Str v->Bool| { v == "Charlie" }, true)
    verifyEq(m.any |Str v->Bool| { v == "Foxtrot" }, false)
    verifyEq(m.all |Str v->Bool| { v[0].isUpper }, true)
    verifyEq(m.all |Str v->Bool| { v == "Charlie" }, false)

    verifyEq(m.any |Str v, Int k->Bool| { k == 'e' }, true)
    verifyEq(m.any |Str v, Int k->Bool| { k == 'f' }, false)
    verifyEq(m.all |Str v, Int k->Bool| { k.isLower }, true)
    verifyEq(m.all |Str v, Int k->Bool| { k == 'e' }, false)
  }

//////////////////////////////////////////////////////////////////////////
// Reduce
//////////////////////////////////////////////////////////////////////////

  Void testReduce()
  {
    map := [0:"zero", 1:"one", 2:"two", 3:"three", ]

    verifyEq(map.reduce(0) |Obj r, Str v, Int k->Obj| { return (Int)r + k }, 6)

    vals := Str[,]
    map.reduce(vals) |Obj r, Str v, Int k->Obj| { return vals.add(v) }
    verifyEq(vals.sort, ["one", "three", "two", "zero"])
  }

//////////////////////////////////////////////////////////////////////////
// Map
//////////////////////////////////////////////////////////////////////////

  Void testMap()
  {
    map := [0:"zero", 1:"one", 2:"two"]
    c := map.map |Str v->Str| { "($v)" }
    verifyEq(c, [0:"(zero)", 1:"(one)", 2:"(two)"])

    // ordered
    [Str:Str] m := OrderedMap<Str,Str>()
    //m.ordered = true
    m["foo"] = "foo"
    m["bar"] = "bar"
    m["zoo"] = "zoo"
    m["who"] = "who"
    m = m.map |v->Str| { v.upper }
    //verifyEq(m.ordered, true)
    verifyEq(m.vals, ["FOO", "BAR", "ZOO", "WHO"])

    // case insensitive
    m = CaseInsensitiveMap()
    //m.caseInsensitive = true
    m["foo"] = "foo"
    m["bar"] = "bar"
    m = m.map |v->Str| { v.upper }
    //verifyEq(m.caseInsensitive, true)
    verifyEq(m["Foo"], "FOO")
  }

//////////////////////////////////////////////////////////////////////////
// AssignOps
//////////////////////////////////////////////////////////////////////////

  Void testAssignOps()
  {
    x := ["one":1, "two":2, "three":3]

    t := x["two"]++
    verifyEq(t, 2)
    verifyEq(x["two"], 3)

    t = ++x["two"]
    verifyEq(t, 4)
    verifyEq(x["two"], 4);

    ++x["two"]
    verifyEq(x["two"], 5)

    x["three"] += 0xab00
    verifyEq(x["three"], 0xab03)
  }

//////////////////////////////////////////////////////////////////////////
// Readonly
//////////////////////////////////////////////////////////////////////////

  Void testReadonly()
  {
    // create rw map
    x := [0:"a", 1:"b", 2:"c"]
    verifyEq(x.isRW, true)
    verifyEq(x.isRO, false)
    verifySame(x.rw, x)

    // get ro list
    r := x.ro
    verifyEq(x.isRW, true)
    verifyEq(x.isRO, false)
    verifySame(x.rw, x)
    verifyEq(r.isRW, false)
    verifyEq(r.isRO, true)
    //verifySame(x.ro, r)
    //verifySame(x.ro, r)
    verifySame(r.ro, r)
    verifySame(r.ro, r)
    verifyEq(r, x)

    // verify all readonly safe methods work
    verifyIsType(r, Int:Str#)
    verifyEq(r.isEmpty, false)
    verifyEq(r.size, 3)
    verifyEq(r[0], "a")
    verifyEq(r[1], "b")
    verifyEq(r[2], "c")
    verifyEq(r.get(3, "?"), "?")
    verifyEq(r.containsKey(2), true)
    verifyEq(r.containsKey(4), false)
    verifyEq(r.keys.sort, [0, 1, 2])
    verifyEq(r.vals.sort, ["a", "b", "c"])
    verifyEq(r.dup, [0:"a", 1:"b", 2:"c"])
    r.each |Str v, Int k| { verifyEq(r[k], v) }
    verifyEq(r.find |Str s->Bool| { return s == "b" }, "b")
    verifyEq(r.findAll |Str s->Bool| { return true }, [0:"a", 1:"b", 2:"c"])
    verifyEq(r.toStr, [0:"a", 1:"b", 2:"c"].toStr)
    //verifyEq(r.caseInsensitive, false)
    //verifyEq(r.ordered, false)
    //verifyEq(r.def, null)

    // verify all modification methods throw ReadonlyErr
    verifyErr(ReadonlyErr#) { r[2] = "x" }
    verifyErr(ReadonlyErr#) { r[3] = "x" }
    verifyErr(ReadonlyErr#) { r.add(2, "?") }
    verifyErr(ReadonlyErr#) { r.setAll([1:"yikes!"]) }
    verifyErr(ReadonlyErr#) { r.addAll([1:"yikes!"]) }
    verifyErr(ReadonlyErr#) { r.setList(["foo"]) |Str v->Int| { return 99 } }
    verifyErr(ReadonlyErr#) { r.addList(["foo"]) |Str v->Int| { return 99 } }
    verifyErr(ReadonlyErr#) { r.remove(0) }
    verifyErr(ReadonlyErr#) { r.remove(5) }
    verifyErr(ReadonlyErr#) { r.clear }
    //verifyErr(ReadonlyErr#) { r.caseInsensitive = true }
    //verifyErr(ReadonlyErr#) { r.ordered = true }
    //verifyErr(ReadonlyErr#) { r.def = "" }

    // verify rw detaches ro
    x[3] = "d"
    r2 := x.ro
    //verifySame(x.ro, r2)
    verifyNotSame(r2, r)
    verifyNotSame(x.ro, r)
    verifyEq(r.isRO, true)
    verifyEq(r.size, 3)
    verifyEq(r, [0:"a", 1:"b", 2:"c"])
    verifyNotEq(r, x)
    verifyNotEq(r, r2)
    x.remove(3)
    r3 := x.ro
    //verifySame(x.ro, r3)
    verifyNotSame(r2, r3)
    verifyNotSame(r3, r)
    verifyNotSame(r2, r)
    verifyNotSame(x.ro, r)
    verifyEq(r.size, 3)
    verifyEq(r, [0:"a", 1:"b", 2:"c"])

    // verify ro to rw
    y := r.rw
    verifyEq(y.isRW, true)
    verifyEq(y.isRO, false)
    //verifySame(y.rw, y)
    //verifySame(y.ro, r)
    verifyEq(y, r)
    verifyEq(r.isRO, true)
    verifyEq(r.size, 3)
    verifyEq(r, [0:"a", 1:"b", 2:"c"])
    verifyEq(y, [0:"a", 1:"b", 2:"c"])
    y.clear
    verifyNotSame(y.ro, r)
    verifyEq(y.size, 0)
    verifySame(y.rw, y)
    verifyEq(r, [0:"a", 1:"b", 2:"c"])
    y[-1] = "!"
    verifyEq(y.size, 1)
    verifyEq(y, [-1:"!"])
    verifyEq(r.size, 3)
    verifyEq(r, [0:"a", 1:"b", 2:"c"])
  }

//////////////////////////////////////////////////////////////////////////
// ToImmutable
//////////////////////////////////////////////////////////////////////////

  Void testToImmutable()
  {
    m := [
          [0].toImmutable: [0ms:"zero"],
          [1].toImmutable: [1ms:"one"],
          [2].toImmutable :null
         ]
    mc := m.toImmutable
    m.each |v,k| {
      verify(mc.containsKey(k), "containsKey $k $v")
    }
    verifyEq(m, mc)
    verifySame(mc.toImmutable, mc)

    verifyNotSame(m, mc)
    verifyNotSame(m.ro, mc)
    verify(mc.isRO)
    verify(mc.isImmutable)
    //verifyEq(Type.of(mc).signature, "[sys::Int[]:[sys::Duration:sys::Str]?]")
    verifyEq(mc.get([0]), [0ms:"zero"])
    //verifyEq(mc.get(null), null)
    verifyEq(mc.get([2]), null)
    verify(mc.get([0]).isRO)
    verify(mc.get([0]).isImmutable)
    mc.keys.each |Int[]? k| { if (k != null) verify(k.isImmutable) }

    mx := mc.rw
    verifyEq(mx.isImmutable, false)
    verifyEq(mc.isImmutable, true)
    mx[[0].toImmutable] = [7ms:"seven"]
    verifyEq(mc.get([0]), [0ms:"zero"])
    verifyEq(mx.get([0]), [7ms:"seven"])

    verifyEq([0:"zero"].isImmutable, false)
    verifyEq([0:"zero"].ro.isImmutable, false)
    verifyEq([0:"zero"].toImmutable.isImmutable, true)

    verifyEq([0:this].isImmutable, false)
    verifyEq([0:this].ro.isImmutable, false)
    verifyErr(NotImmutableErr#) { [0:this].toImmutable }
    verifyErr(NotImmutableErr#) { [0:[this]].toImmutable }
    verifyErr(NotImmutableErr#) { [4:[8ms:this]].toImmutable }
  }

//////////////////////////////////////////////////////////////////////////
// Collisions
//////////////////////////////////////////////////////////////////////////

  Void testCollisions()
  {
    a := CollisionTest("a")
    b := CollisionTest("b")
    c := CollisionTest("c")
    d := CollisionTest("d")
    e := CollisionTest("e")

    m := CollisionTest:Str[a:"a", b:"b", c:"c", d:"d", e:"e"]
    verifyEq(m.size, 5)
    verifyEq(m, [a:"a", b:"b", c:"c", d:"d", e:"e"])
    verifyEq(m[a], "a")
    verifyEq(m[b], "b")
    verifyEq(m[c], "c")
    verifyEq(m[d], "d")
    verifyEq(m[e], "e")

    m.remove(c)
    verifyEq(m.size, 4)
    verifyEq(m, [a:"a", b:"b", d:"d", e:"e"])
    verifyEq(m[a], "a")
    verifyEq(m[b], "b")
    verifyEq(m[d], "d")
    verifyEq(m[e], "e")

    m.remove(a)
    verifyEq(m.size, 3)
    verifyEq(m, [b:"b", d:"d", e:"e"])
    verifyEq(m[b], "b")
    verifyEq(m[d], "d")
    verifyEq(m[e], "e")

    m.remove(e)
    verifyEq(m.size, 2)
    verifyEq(m, [b:"b", d:"d"])
    verifyEq(m[b], "b")
    verifyEq(m[d], "d")
  }
}

const class CollisionTest
{
  new make(Str val) { this.val = val }
  override Int hash() { 12 }
  override Bool equals(Obj? that)
  {
    (that is CollisionTest) ? that->val == val : false
  }
  override Str toStr() { val }
  const Str val
}

