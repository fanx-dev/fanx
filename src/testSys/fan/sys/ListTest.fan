//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 06  Brian Frank  Creation
//

**
** ListTest
**
class ListTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Play
//////////////////////////////////////////////////////////////////////////

  Void testPlay()
  {
    x := [0, 1, 2, 3]
    //verify(Type.of(x) == Int[]#)
    //verify(Type.of(x) === Int[]#)
    a := x[-1]
    verify((Obj?)a is Int)
    verify(Type.of(a) == Int#)
    verify(a == 3)
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    verifyEq([0, 1], [0, 1])
    verifyEq([0, 1].hash, [0, 1].hash)
    verifyNotEq([0, 1], null)
    verifyNotEq(null, [0, 1])
    verifyNotEq([1, 0], [0, 1])
    verifyNotEq([0, 1], [0, 1, 2])
    verifyNotEq([0, 1, 2], [0, 1])
    verifyNotEq([0, 1, 2], "string")
  }

//////////////////////////////////////////////////////////////////////////
// Hash
//////////////////////////////////////////////////////////////////////////

  Void testHash()
  {
    verifyNotEq([1, 2, 3].hash, [3, 2, 1].hash)
    verifyNotEq([1, null, 3].hash, [null, 1, 3].hash)
  }

//////////////////////////////////////////////////////////////////////////
// Is Operator
//////////////////////////////////////////////////////////////////////////

  Void testIsExplicit()
  {
    // Obj[]
    Obj a := Obj[,]
    verify(a is Obj)
    verify(a is Obj[])
    verifyFalse(a is Str)
    //verifyFalse(a is Str[])

    // Str[]
    Obj b := Str[,]
    verify(b is Obj)
    verify(b is Obj[])
    verify(b is Str[])
    verifyFalse(b is Str)
    //verifyFalse(b is Int[])

    // Field[]
    Obj c := Field[,]
    verify(c is Obj)
    verify(c is Obj[])
    verify(c is Slot[])
    verify(c is Field[])
  }
/*
  Void testInference()
  {
    verifyType([,],     Obj?[]#)
    verifyType(Obj?[,], Obj?[]#)
    verifyType(Obj[,],  Obj[]#)
    verifyType([null],  Obj?[]#)
    verifyType([null,null], Obj?[]#)
    verifyType([2,null],  Int?[]#)
    verifyType([null,2],  Int?[]#)
    verifyType([2,null,2f], Num?[]#)
    verifyType([null,3,2f], Num?[]#)

    // expressions used to create list literal
    [Str:Int]? x := null
    verifyType([this->toStr], Obj?[]#)
    verifyType([Pod.find("xxxx", false)], Pod?[]#)
    verifyType([this as Test], Test?[]#)
    verifyType([(Obj?)this ?: "foo"], Obj?[]#)
    verifyType([x?.toStr], Str?[]#)
    //verifyType([x?.defV], Int?[]#)
    verifyType([x?.caseInsensitive], Bool?[]#)
    verifyType([x?->foo], Obj?[]#)
    verifyType([returnThis], ListTest[]#)
    verifyType([x == null ? "x" : null], Str?[]#)
    verifyType([x == null ? null : 4f], Float?[]#)
  }
*/
  This returnThis() { return this }

  Void testIsInfered()
  {
    // Obj[]
    verify([2,"a"] is Obj)
    verify([3,"b"] is Obj[])
    verify([,] is Obj?[])
    verify([null] is Obj?[])
    verify([2,null] is Obj?[])
    verify([null,"2"] is Obj?[])
    verifyFalse((Obj)[Type.of(this),8f] is Str)
    //verifyFalse((Obj)["a",this] is Str[])

    // Int[]
    verify([3] is Obj)
    verify([6] is Obj[])
    verify([3] is Obj)
    verify([4,3] is Int[])
    verify([4,null] is Int[])  // null doesn't count
    verify([null, null, 9] is Int[])  // null doesn't count
    verifyFalse((Obj)[-1,9] is Int)
    //verifyFalse((Obj)[4,6,9] is Str[])
  }

//////////////////////////////////////////////////////////////////////////
// As Operator
//////////////////////////////////////////////////////////////////////////

  Void testAsExplicit()
  {
    Obj x := [,];

    o  := x as Obj;    verifySame(o , x)
    b  := x as Bool;   verifySame(b , null)
    s  := x as Str;    verifySame(s , null)
    l  := x as List;   verifySame(l , x)
    ol := x as Obj[];  verifySame(ol , x)
    il := x as Int[];  verifySame(il , x)  // no runtime check
    sl := x as Str[];  verifySame(sl , x)  // no runtime check
    s2 := x as Str?[];  verifySame(s2 , x) // no runtime check

    x  = ["a", "b"]
    o  = x as Obj;    verifySame(o , x)
    b  = x as Bool;   verifySame(b , null)
    s  = x as Str;    verifySame(s , null)
    l  = x as List;   verifySame(l , x)
    ol = x as Obj[];  verifySame(ol , x)
    il = x as Int[];  verifySame(il , x) // no runtime check
    sl = x as Str[];  verifySame(sl , x) // no runtime check
    s2 = x as Str?[]; verifySame(sl , x) // no runtime check

    x = "s"
    o  = x as Obj;    verifySame(o , x)
    b  = x as Bool;   verifySame(b , null)
    s  = x as Str;    verifySame(s , x)
    l  = x as List;   verifySame(l , null)
    ol = x as Obj[];  verifySame(ol , null)
    il = x as Int[];  verifySame(il , null) // no runtime check
    sl = x as Str[];  verifySame(sl , null) // no runtime check
    s2 = x as Str?[]; verifySame(sl , null) // no runtime check
  }

//////////////////////////////////////////////////////////////////////////
// Cast
//////////////////////////////////////////////////////////////////////////

  Void testCast()
  {
    Obj x := [2, 4f]
    verifyEq(((Num[])x)[1], 4f)
    verifyEq(((Int[])x)[0], 2)

    strs := (Str[])x  // no runtime check
    verifyErr(CastErr#) { strs[1].size }

    strs = (Str[])(x as Str[]) // no runtime check
    verifyNotNull(strs)
    verifyErr(CastErr#) { strs[1].size }
  }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////
/*
  Void testReflect()
  {
    verifyEq(["a"].of, Str#)
    verifyEq([[2]].of, Int[]#)

    x := [,]
    t := Type.of(x)
    verifyEq(t.base,      List#)
    verifyEq(t.base.base, Obj#)
    verifyEq(t.pod.name,  "sys")
    verifyEq(t.name,      "List")
    verifyEq(t.qname,     "sys::List")
    verifyEq(t.signature, "sys::Obj?[]")
    verifyEq(t.toStr,     "sys::Obj?[]")
    verifyEq(t.method("isEmpty").returns,  Bool#)
    verifyEq(t.method("first").returns,    Obj?#)
    verifyEq(t.method("get").returns,      Obj?#)
    verifyEq(t.method("add").returns,      Obj?[]#)
    verifyEq(t.method("add").params[0].type, Obj?#)
    verifyEq(t.method("each").params[0].type, |Obj? a, Int i->Void|#)
    verifyNotEq(t.method("each").params[0].type, |Str a, Int i->Void|#)

    y := [7]
    t = Type.of(y)
    verifyEq(t.base,      List#)
    verifyEq(t.base.base, Obj#)
    verifyEq(t.pod.name,  "sys")
    verifyEq(t.name,      "List")
    verifyEq(t.qname,     "sys::List")
    verifyEq(t.signature, "sys::Int[]")
    verifyEq(t.toStr,     "sys::Int[]")
    verifyEq(t.method("isEmpty").returns,  Bool#)
    verifyEq(t.method("first").returns,    Int?#)
    verifyEq(t.method("get").returns,      Int#)
    verifyEq(t.method("add").returns,      Int[]#)
    verifyEq(t.method("add").params[0].type, Int#)
    verifyEq(t.method("each").params[0].type, |Int a, Int i->Void|#)
    verifyNotEq(t.method("each").params[0].type, |Obj a, Int i->Void|#)

    z := [[8ms]]
    t = Type.of(z)
    verifyEq(t.base,      List#)
    verifyEq(t.base.base, Obj#)
    verifyEq(t.pod.name,  "sys")
    verifyEq(t.name,      "List")
    verifyEq(t.qname,     "sys::List")
    verifyEq(t.signature, "sys::Duration[][]")
    verifyEq(t.toStr,     "sys::Duration[][]")
    verifyEq(t.method("isEmpty").returns,   Bool#)
    verifyEq(t.method("first").returns,     Duration[]?#)
    verifyEq(t.method("get").returns,       Duration[]#)
    verifyEq(t.method("add").returns,       Duration[][]#)
    verifyEq(t.method("add").params[0].type, Duration[]#)
    verifyEq(t.method("insert").params[1].type, Duration[]#)
    verifyEq(t.method("removeAt").returns,    Duration[]#)
    verifyEq(t.method("each").params[0].type, |Duration[] a, Int i->Void|#)
    verifyEq(t.method("map").returns, Obj?[]#)
    verifyNotEq(t.method("map").returns, Duration[]#)
    verifyNotEq(t.method("each").params[0].type, |Obj a, Int i->Void|#)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Get
//////////////////////////////////////////////////////////////////////////

  Void testGet()
  {
    // empty
    (-10..10).each |i| { verifyGetErr(Str[,], i) }

    // size one
    verifyGet(["a"], 0, "a")
    verifyGet(["a"], -1, "a")
    (-10..-2).each |i| { verifyGetErr(Str[,], i) }
    (1..10).each |i| { verifyGetErr(Str[,], i) }

    // size two
    verifyGet(["a", "b"], 0,  "a")
    verifyGet(["a", "b"], 1,  "b")
    verifyGet(["a", "b"], -1, "b")
    verifyGet(["a", "b"], -2, "a")
    (-10..-3).each |i| { verifyGetErr(Str[,], i) }
    (2..10).each |i| { verifyGetErr(Str[,], i) }

    // underflow
    verifyEq(["a"].getSafe(0xffff_ffff), null)
  }

  Void verifyGet(Str[] list, Int i, Str expected)
  {
    verifyEq(list.get(i), expected)
    verifyEq(list.getSafe(i), expected)
  }

  Void verifyGetErr(Str[] list, Int i)
  {
    verifyErr(IndexErr#) { list.get(i) }
    verifyEq(list.getSafe(i), null)
    verifyEq(list.getSafe(i, "!"), "!")
  }

//////////////////////////////////////////////////////////////////////////
// Items
//////////////////////////////////////////////////////////////////////////

  Void testItems()
  {
    // add, insert, removeAt, get, size
    Obj? r;
    list := Int?[,]
    list.add(10); verifyEq(list, Int?[10]); verifyEq(list.size, 1);
    list.add(20); verifyEq(list, Int?[10, 20]); verifyEq(list.size, 2);
    list.add(30); verifyEq(list, Int?[10, 20, 30]); verifyEq(list.size, 3);
    list.insert(0, 40); verifyEq(list, Int?[40, 10, 20, 30]); verifyEq(list.size, 4);
    list.insert(1, 50).add(60); verifyEq(list, Int?[40, 50, 10, 20, 30, 60]); verifyEq(list.size, 6);
    list.insert(-1, 70); verifyEq(list, Int?[40, 50, 10, 20, 30, 70, 60]); verifyEq(list.size, 7);
    list.insert(-3, 80); verifyEq(list, Int?[40, 50, 10, 20, 80, 30, 70, 60]); verifyEq(list.size, 8);
    verify(list.removeAt(0) == 40); verifyEq(list, Int?[50, 10, 20, 80, 30, 70, 60]); verifyEq(list.size, 7);
    verify(list.removeAt(6) == 60); verifyEq(list, Int?[50, 10, 20, 80, 30, 70]); verifyEq(list.size, 6);
    list.removeAt(3); verifyEq(list, Int?[50, 10, 20, 30, 70]); verifyEq(list.size, 5);
    list.removeAt(-1); verifyEq(list, Int?[50, 10, 20, 30]); verifyEq(list.size, 4);
    list.removeAt(-4); verifyEq(list, Int?[10, 20, 30]); verifyEq(list.size, 3);
    list.add(40); verifyEq(list, Int?[10, 20, 30, 40]); verifyEq(list.size, 4);
    verify(list.insert(2, 50) === list); verifyEq(list, Int?[10, 20, 50, 30, 40]); verifyEq(list.size, 5);
    list.removeAt(2); verifyEq(list, Int?[10, 20, 30, 40]); verifyEq(list.size, 4);
    verifyEq(list[0], 10); verifyEq(list[-4], 10);
    verifyEq(list[1], 20); verifyEq(list[-3], 20);
    verifyEq(list[2], 30); verifyEq(list[-2], 30);
    verifyEq(list[3], 40); verifyEq(list[-1], 40);
    list[0] = -10; verifyEq(list, Int?[-10, 20, 30, 40]); verifyEq(list.size, 4);
    list[2] = -30; verifyEq(list, Int?[-10, 20, -30, 40]); verifyEq(list.size, 4);
    list[-1] = -40; verifyEq(list, Int?[-10, 20, -30, -40]); verifyEq(list.size, 4);
    list[-3] = -20; verifyEq(list, Int?[-10, -20, -30, -40]); verifyEq(list.size, 4);
    list[-2] = null; verifyEq(list, Int?[-10, -20, null, -40]); verifyEq(list.size, 4);
    list[0] = null; verifyEq(list, Int?[null, -20, null, -40]); verifyEq(list.size, 4);

    // IndexErr - no items
    list = Int[,]
    verifyErr(IndexErr#) { x:=list[0] }
    verifyErr(IndexErr#) { x:=list[1] }
    verifyErr(IndexErr#) { x:=list[-1] }
    verifyErr(IndexErr#) { x:=list[-2] }

    // IndexErr - one items
    list = [77]
    verifyErr(IndexErr#) { x:=list[1] }
    verifyErr(IndexErr#) { x:=list[-2] }
  }

//////////////////////////////////////////////////////////////////////////
// Duplicate
//////////////////////////////////////////////////////////////////////////

  Void testDup()
  {
    a := [0, 1, 2]
    verifyEq(a.size, 3)
    //verifyType(a, Int[]#)
    verifyEq(a, [0, 1, 2])

    b := a.dup
    verifyEq(b.size, 3)
    //verifyType(b, Int[]#)
    verifyEq(b, [0, 1, 2])

    a[1] = 99
    verifyEq(a, [0, 99, 2])
    verifyEq(b, [0, 1, 2])

    a.clear
    verifyEq(a.size, 0)
    verifyEq(b.size, 3)
    verifyEq(a, Int[,])
    verifyEq(b, [0, 1, 2])
  }

//////////////////////////////////////////////////////////////////////////
// AddAll/InsertAll
//////////////////////////////////////////////////////////////////////////

  Void testInsertAll()
  {
    a := Str[,]
    x := Str[,]

    verifyEq(a.addAll(x), Str[,])
    verifyErr(IndexErr#) { a.insertAll(-1, x) }

    a.add("a")
    verifyEq(a.addAll(x), ["a"])
    verifyEq(a.insertAll(0, x), ["a"])

    x.add("x")
    verifyEq(a.addAll(x), ["a", "x"])
    verifyEq(a.insertAll(0, x), ["x", "a", "x"])

    x.add("y")
    verifyEq(a.addAll(x), ["x", "a", "x", "x", "y"])
    verifyEq(a.insertAll(1, x), ["x", "x", "y", "a", "x", "x", "y"])

    a = ["a", "b", "c"]
    verifyEq(a.insertAll(1, a), ["a", "a", "b", "c", "b", "c"])
    verifyEq(a.insertAll(-2, ["x", "y"]), ["a", "a", "b", "c", "x", "y", "b", "c"])

    verifyEq(Str[,].insertAll(0, ["a"]), ["a"])
    verifyErr(IndexErr#) { [,].insertAll(1, [,]) }
    verifyErr(IndexErr#) { [,].insertAll(-1, ["a"]) }

    verifyEq(["a"].insertAll(0, ["b"]), ["b", "a"])
    verifyEq(["a"].insertAll(1, ["b"]), ["a", "b"])
    verifyEq(["a"].insertAll(-1, ["b"]), ["b", "a"])
    verifyErr(IndexErr#) { ["a"].insertAll(2, ["b"]) }
    verifyErr(IndexErr#) { ["a"].insertAll(-3, ["b"]) }
  }

//////////////////////////////////////////////////////////////////////////
// Size/Capacity
//////////////////////////////////////////////////////////////////////////

  Void testSizeCapacity()
  {
    x := Str?[,]

    verifyEq(x.size, 0)
    verifyEq(x.capacity, 0)

    x.capacity = 2
    verifyEq(x.size, 0)
    verifyEq(x.capacity, 2)

    x.add("a").add("b")
    verifyEq(x.size, 2)
    verifyEq(x.capacity, 2)
    verifyErr(ArgErr#) { x.capacity = 1 }

    x.add("c")  // auto-grow
    verifyEq(x.size, 3)
    verify(x.capacity > 3)
    verifyEq(x, Str?["a", "b", "c"])

    x.capacity = 3 // manual trim
    verifyEq(x.size, 3)
    verifyEq(x.capacity, 3)
    verifyEq(x, Str?["a", "b", "c"])

    x->size = 4
    verifyEq(x.size, 4)
    verifyEq(x.capacity, 4)
    verifyEq(x, ["a", "b", "c", null])

    x->size = 2
    verifyEq(x.size, 2)
    verifyEq(x.capacity, 4)
    verifyEq(x, Str?["a", "b"])

    x->size = 5
    verifyEq(x.size, 5)
    verifyEq(x.capacity, 5)
    verifyEq(x, ["a", "b", null, null, null])
    x.add("z")

    verifyEq(x, ["a", "b", null, null, null, "z"])
    verifyEq(x.size, 6)
    verify(x.capacity > 7)

    x->size = 0
    verifyEq(x.size, 0)
    verify(x.capacity > 7)
    verifyEq(x, Str?[,])

    x.add("x")
    verifyEq(x.size, 1)
    verify(x.capacity > 7)
    verifyEq(x, Str?["x"])

    x->size = 2
    verifyEq(x.size, 2)
    verify(x.capacity > 7)
    verifyEq(x, Str?["x", null])

    x[1] = "foo"
    x->size = 0
    x->size = 3
    verifyEq(x.size, 3)
    verify(x.capacity > 7)
    verifyEq(x, Str?[null, null, null])

    y := Str["a", "b", "c"]
    y->size = 2
    verifyEq(y, ["a", "b"])
    //echo("$y.of $y.of.isNullable")
    verifyErr(ArgErr#) { y.size = 3 }
  }

//////////////////////////////////////////////////////////////////////////
// Slicing
//////////////////////////////////////////////////////////////////////////

  Void testSlicing()
  {
    /* Ruby
    irb(main):001:0> a = [0, 1, 2, 3] => [0, 1, 2, 3]
    irb(main):002:0> a[0..3]   => [0, 1, 2, 3]
    irb(main):003:0> a[0..2]   => [0, 1, 2]
    irb(main):004:0> a[0..1]   => [0, 1]
    irb(main):005:0> a[0..0]   => [0]
    irb(main):006:0> a[0...0]  => []
    irb(main):007:0> a[0...1]  => [0]
    irb(main):008:0> a[0...2]  => [0, 1]
    irb(main):009:0> a[0...3]  => [0, 1, 2]
    irb(main):010:0> a[1..3]   => [1, 2, 3]
    irb(main):011:0> a[1..4]   => [1, 2, 3]
    irb(main):012:0> a[1..5]   => [1, 2, 3]
    irb(main):013:0> a[1..1]   => [1]
    irb(main):014:0> a[1..-1]  => [1, 2, 3]
    irb(main):015:0> a[1..-2]  => [1, 2]
    irb(main):016:0> a[1..-3]  => [1]
    irb(main):017:0> a[1..-4]  => []
    irb(main):018:0> a[1...-1] => [1, 2]
    irb(main):019:0> a[1...-2] => [1]
    irb(main):020:0> a[1...-3] => []
    irb(main):021:0> a[-3..-1] => [1, 2, 3]
    irb(main):022:0> a[-3..-2] => [1, 2]
    irb(main):023:0> a[-3..-3] => [1]
    */

    list := [0, 1, 2, 3]

    verifyEq(list[0..3],  [0, 1, 2, 3])
    verifyEq(list[0..2],  [0, 1, 2])
    verifyEq(list[0..1],  [0, 1])
    verifyEq(list[0..0],  [0])
    verifyEq(list[0..<0], Int[,])
    verifyEq(list[0..<1], [0])
    verifyEq(list[0..<2], [0, 1])
    verifyEq(list[0..<3], [0, 1, 2])
    verifyEq(list[0..<4], [0, 1, 2, 3])
    verifyEq(list[1..3], [1, 2, 3])
    verifyEq(list[1..1], [1])
    verifyEq(list[1..-1], [1, 2, 3])
    verifyEq(list[1..-2], [1, 2])
    verifyEq(list[1..-3], [1])
    verifyEq(list[1..-4], Int[,])
    verifyEq(list[1..<-1], [1, 2])
    verifyEq(list[1..<-2], [1])
    verifyEq(list[1..<-3], Int[,])
    verifyEq(list[-3..-1], [1, 2, 3])
    verifyEq(list[-3..-2], [1, 2])
    verifyEq(list[-3..-3], [1])
    verifyEq(list[4..-1], Int[,])

    // examples
    ex := [0, 1, 2, 3]
    verifyEq(ex[0..2], [0, 1, 2])
    verifyEq(ex[3..3], [3])
    verifyEq(ex[-2..-1], [2, 3])
    verifyEq(ex[0..<2], [0, 1])
    verifyEq(ex[1..-2], [1, 2])

    // errors
    verifyErr(IndexErr#) { x:=list[0..4] }
    verifyErr(IndexErr#) { x:=list[0..<5] }
    verifyErr(IndexErr#) { x:=list[2..<1] }
    verifyErr(IndexErr#) { x:=list[3..1] }
    verifyErr(IndexErr#) { x:=list[-5..-1] }
    verifyErr(IndexErr#) { x:=list[1..4] }
    verifyErr(IndexErr#) { x:=list[1..5] }
  }

//////////////////////////////////////////////////////////////////////////
// Remove
//////////////////////////////////////////////////////////////////////////

  Void testRemove()
  {
    //isJs  := Env.cur.runtime == "isJs"
    foo := "foobar"[0..2]
    list := Str?["a", "b", foo, null, "a"]
    if (!isJs) verifyEq(list.indexSame("foo"), -1)
    verifyEq(list.remove("b"), "b");     verifyEq(list, Str?["a", "foo", null, "a"])
    verifyEq(list.remove("a"), "a");     verifyEq(list, Str?["foo", null, "a"])
    verifyEq(list.remove("x"), null);    verifyEq(list, Str?["foo", null, "a"])
    verifyEq(list.remove("a"), "a");     verifyEq(list, Str?["foo", null])
    verifyEq(list.remove(null), null);   verifyEq(list, Str?["foo"])
    if (!isJs) verifyEq(list.removeSame("foo"), null);  verifyEq(list, Str?["foo"])
    verifyEq(list.remove("foo"), "foo"); verifyEq(list, Str?[,])
    verifyEq(list.remove("a"), null);    verifyEq(list, Str?[,])
  }

//////////////////////////////////////////////////////////////////////////
// RemoveAll
//////////////////////////////////////////////////////////////////////////

  Void testRemoveAll()
  {
    list := [0, 1, 2, 3, 4, 5, 6, 7, 8]
    verifyRemoveAll(list, [0, 6, 7, 8], [1, 2, 3, 4, 5])
    verifyRemoveAll(list, Int[,], [1, 2, 3, 4, 5])
    verifyRemoveAll(list, [2, 4], [1, 3, 5])
    verifyRemoveAll(list, [5], [1, 3])
    verifyRemoveAll(list, [1, 9], [3])
    verifyRemoveAll(list, [3, 4], Int[,])
    list.addAll([10, 20, 30, 40])
    verifyRemoveAll(list, [20, 30], [10, 40])
  }

  Void verifyRemoveAll(Int[] list, Int[] toRemove, Int[] expected)
  {
    verifySame(list.removeAll(toRemove), list)
    verifyEq(list.size, expected.size)
    verifyEq(list, expected)
  }

//////////////////////////////////////////////////////////////////////////
// RemoveRange
//////////////////////////////////////////////////////////////////////////

  Void testRemoveRange()
  {
    verifyEq(Int[,].removeRange(0..-1), Int[,])
    verifyEq(Int[1].removeRange(0..-1), Int[,])
    verifyEq(Int[1].removeRange(1..-1), [1])
    verifyEq(Int[1,2].removeRange(0..-1), Int[,])
    verifyEq(Int[1,2].removeRange(0..1), Int[,])
    verifyEq(Int[1,2].removeRange(0..<1), [2])
    verifyEq(Int[1,2].removeRange(1..1), [1])
    verifyEq(Int[1,2].removeRange(1..-1), [1])
    verifyEq(Int[1,2,3].removeRange(0..-1), Int[,])
    verifyEq(Int[1,2,3].removeRange(1..1), [1,3])
    verifyEq(Int[1,2,3].removeRange(1..<2), [1,3])
    verifyEq(Int[0,1,2,3,4,5].removeRange(0..2), [3,4,5])
    verifyEq(Int[0,1,2,3,4,5].removeRange(4..-1), [0,1,2,3])
    verifyEq(Int[0,1,2,3,4,5].removeRange(1..4), [0,5])
    verifyEq(Int[0,1,2,3,4,5].removeRange(1..<4), [0,4,5])
    verifyEq(Int[0,1,2,3,4,5].removeRange(-3..-1), [0,1,2])
    verifyEq(Int[0,1,2,3,4,5].removeRange(-3..4), [0,1,2,5])
  }

//////////////////////////////////////////////////////////////////////////
// Clear
//////////////////////////////////////////////////////////////////////////

  Void testClear()
  {
    list := ["a", "b", "c"]
    verifyEq(list.size, 3)
    verifyFalse(list.isEmpty)

    list.clear
    verifyEq(list.size, 0)
    verify(list.isEmpty)
  }

//////////////////////////////////////////////////////////////////////////
// Fill
//////////////////////////////////////////////////////////////////////////

  Void testFill()
  {
    list := Int[,]
    verifyEq(list.fill(0, 3), [0, 0, 0])
    verifyEq(list.size, 3)
    verifyEq(list.fill(0xff, 2), [0, 0, 0, 0xff, 0xff])
    verifyEq(list.size, 5)
  }

//////////////////////////////////////////////////////////////////////////
// Contains/Index
//////////////////////////////////////////////////////////////////////////

  Void testContainsIndex()
  {
    //isJs  := Env.cur.runtime == "isJs"
    foo := "foobar"[0..2]
    // TODO: this is not true under isJs:
    if (!isJs) verify(foo !== "foo")
    list := Str?["a", "b", null, "c", null, "b", foo]

    //verifyEq([,].contains(null), false)
    verifyEq([,].contains("a"), false)

    verify(list.contains("a"))
    verify(list.contains("foo"))

    verifyEq(list.index("a"), 0)
    verifyEq(list.index("foo"), 6)
    verifyEq(list.index("b"), 1)

    verifyEq(list.indexr("b"), 5)
    verifyEq(list.indexr("b", -3), 1)
    verifyEq(list.indexr(null), 4)
    verifyEq(list.indexr("xx"), -1)

    verifyEq(list.indexSame("a"), 0)
    if (!isJs) verifyEq(list.indexSame("abc"[0..0]), -1)
    if (!isJs) verifyEq(list.indexSame("foo"), -1)

    verify(list.contains("b"))
    verifyEq(list.index("b"), 1)

    verify(list.contains("c"))
    verifyEq(list.index("c"), 3)

    verify(list.contains(null))
    verifyEq(list.index(null), 2)

    verifyFalse(list.contains("d"))
    verifyEq(list.index("d"), -1)

    verifyEq(list.containsAll(Str[,]), true)
    verifyEq(list.containsAll(["a"]), true)
    verifyEq(list.containsAll(["c"]), true)
    verifyEq(list.containsAll(Str?[null]), true)
    verifyEq(list.containsAll(["x"]), false)
    verifyEq(list.containsAll(["b", "a"]), true)
    verifyEq(list.containsAll(["b", null, "a"]), true)
    verifyEq(list.containsAll(["b", "a", "c"]), true)
    verifyEq(list.containsAll(["b", "x"]), false)
    verifyEq(list.containsAll(["b", null, "foo"]), true)

    verifyEq(list.containsAny(Str?[,]), false)
    verifyEq(list.containsAny(["x"]), false)
    verifyEq(list.containsAny(["x", "b"]), true)
    verifyEq(list.containsAny(["x", "y", "z"]), false)
    verifyEq(list.containsAny(["x", "y", "z", null]), true)

    verifyEq(list.index("a", -5), -1)
    verifyEq(list.index("a", -7), 0)
    verifyEq(list.index("b", 1), 1)
    verifyEq(list.index("b", 2), 5)
    verifyEq(list.index("b", -2), 5)
    verifyEq(list.index("b", -6), 1)
    verifyEq(list.index("foo", -1), 6)
    if (!isJs) verifyEq(list.indexSame("foo", -1), -1)

    verifyEq(list.index(null, 0), 2)
    verifyEq(list.index(null, 2), 2)
    verifyEq(list.index(null, 3), 4)

    //verifyErr(IndexErr#) { list.index("a", 7) }
    //verifyErr(IndexErr#) { list.index("a", -8) }
  }

//////////////////////////////////////////////////////////////////////////
// FirstLast
//////////////////////////////////////////////////////////////////////////

  Void testFirstLast()
  {
    verifyEq([,].first, null)
    verifyEq([,].last, null)

    verifyEq([5].first, 5)
    verifyEq([5].last,  5)

    verifyEq([1,2].first, 1)
    verifyEq([1,2].last,  2)

    verifyEq([1,2,3].first, 1)
    verifyEq([1,2,3].last,  3)
  }

//////////////////////////////////////////////////////////////////////////
// Stack
//////////////////////////////////////////////////////////////////////////

  Void testStack()
  {
    s := Int[,]

    verifyEq(s.peek, null); verifyEq(s.pop,  null)

    s.push(1)
    verifyEq(s.peek, 1);    verifyEq(s.pop,  1)
    verifyEq(s.peek, null); verifyEq(s.pop,  null)

    s.push(1);
    s.push(2)
    verifyEq(s.peek, 2);    verifyEq(s.pop,  2)
    verifyEq(s.peek, 1);    verifyEq(s.pop,  1)
    verifyEq(s.peek, null); verifyEq(s.pop,  null)
  }

//////////////////////////////////////////////////////////////////////////
// Each
//////////////////////////////////////////////////////////////////////////

  Void testEach()
  {
    values  := Int[,]
    indexes := Int[,]

    // empty list
    Int[,].each |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  Int[,])
    verifyEq(indexes, Int[,])

    // list of one
    values.clear;
    indexes.clear;
    [ 7 ].each |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  [7])
    verifyEq(indexes, [0])

    // list of two
    values.clear;
    indexes.clear;
    [ -9, 0xab ].each |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  [-9, 0xab])
    verifyEq(indexes, [0, 1])

    // list of four
    values.clear;
    indexes.clear;
    [ 10, 20, 30, 40 ].each |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  [10, 20, 30, 40])
    verifyEq(indexes, [0, 1, 2, 3])
  }

//////////////////////////////////////////////////////////////////////////
// Eachr
//////////////////////////////////////////////////////////////////////////

  Void testEachr()
  {
    values  := Int[,]
    indexes := Int[,]

    // empty list
    Int[,].eachr |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  Int[,])
    verifyEq(indexes, Int[,])

    // list of one
    values.clear;
    indexes.clear;
    [ 7 ].eachr |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  [7])
    verifyEq(indexes, [0])

    // list of two
    values.clear;
    indexes.clear;
    [ -9, 0xab ].eachr |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  [0xab, -9])
    verifyEq(indexes, [1, 0])

    // list of four
    values.clear;
    indexes.clear;
    [ 10, 20, 30, 40 ].eachr |Int value, Int index|
    {
      values.add(value)
      indexes.add(index)
    }
    verifyEq(values,  [40, 30, 20, 10])
    verifyEq(indexes, [3, 2, 1, 0])

    // just value
    values.clear;
    indexes.clear;
    [ 1, 2, 3, 4, 5, 6, 7, 8 ].eachr |Int value|
    {
      values.add(value)
    }
    verifyEq(values,  [8, 7, 6, 5, 4, 3, 2, 1])
  }

//////////////////////////////////////////////////////////////////////////
// EachRange
//////////////////////////////////////////////////////////////////////////

  Void testEachRange()
  {
    x := ["a", "b", "c", "d", "e"]
    acc := Str[,]
    f := |str| { acc.add(str) }
    acc.clear; x.eachRange(1..2,   f); verifyEq(acc, ["b", "c"])
    acc.clear; x.eachRange(3..-1,  f); verifyEq(acc, ["d", "e"])
    acc.clear; x.eachRange(-4..-2, f); verifyEq(acc, ["b", "c", "d"])
    acc.clear; x.eachRange(-4..2,  f); verifyEq(acc, ["b", "c"])
    acc.clear; x.eachRange(-4..<3, f); verifyEq(acc, ["b", "c"])
    acc.clear; x.eachRange(1..-1,  f); verifyEq(acc, ["b", "c", "d", "e"])
    acc.clear; x.eachRange(1..<-1, f); verifyEq(acc, ["b", "c", "d"])

    acc.clear
    indices := Int[,]
    x.eachRange(2..<5) |v,i| { acc.add(v); indices.add(i) }
    verifyEq(acc, ["c", "d", "e"])
    verifyEq(indices, [2, 3, 4])

    verifyErr(IndexErr#) { x.eachRange(0..5) {} }
    verifyErr(IndexErr#) { x.eachRange(0..<6) {} }
  }

//////////////////////////////////////////////////////////////////////////
// EachWhile
//////////////////////////////////////////////////////////////////////////

  Void testEachWhile()
  {
    x := ["a", "b", "c", "d"]
    n := 0
    verifyEq(x.eachWhile |Str s->Str?| { return s == "b" ? "B" : null }, "B")
    verifyEq(x.eachWhile |Str s->Str?| { return s == "x" ? "X" : null }, null)
    verifyEq(x.eachWhile |Str s, Int i->Str?| { return i == 2 ? s : null }, "c")
    verifyEq(x.eachrWhile |Str s, Int i->Str?| { return i == 1 ? s : null }, "b")

    n = 0; x.eachWhile |Str s->Obj?| { n++; return s == "b" ? true : null }; verifyEq(n, 2)
    n = 0; x.eachWhile |Str s->Obj?| { n++; return s == "c" ? true : null }; verifyEq(n, 3)
    n = 0; x.eachWhile |Str s->Obj?| { n++; return s == "x" ? true : null }; verifyEq(n, 4)

    n = 0; x.eachrWhile |Str s->Obj?| { n++; return s == "b" ? true : null }; verifyEq(n, 3)
    n = 0; x.eachrWhile |Str s->Obj?| { n++; return s == "c" ? true : null }; verifyEq(n, 2)
    n = 0; x.eachrWhile |Str s->Obj?| { n++; return s == "x" ? true : null }; verifyEq(n, 4)
  }

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testFind()
  {
    list := [0, 10, 20, 30, 40, 60]

    // find
    verifyEq(list.find |Int v, Int i->Bool| { return v == 20 }, 20)
    verifyEq(list.find |Int v, Int i->Bool| { return i == 3 }, 30)
    verifyEq(list.find |Int v, Int i->Bool| { return false }, null)
    verifyEq(list.find |Int v->Bool| { return false }, null)
    verifyEq(list.find |->Bool| { return false }, null)

    // findIndex
    verifyEq(list.findIndex |Int v, Int i->Bool| { return v == 20 }, 2)
    verifyEq(list.findIndex |Int v, Int i->Bool| { return i == 3 }, 3)
    verifyEq(list.findIndex |Int v, Int i->Bool| { return false }, -1)
    verifyEq(list.findIndex |Int v->Bool| { return false }, -1)
    verifyEq(list.findIndex |->Bool| { return false }, -1)

    // typed assign
    Int x := list.find |Int v->Bool| { return v.toStr == "40" }
    verifyEq(x, 40)

    // findAll
    verifyEq(list.findAll|Int v, Int i->Bool| { return v % 20 == 0 }, [0, 20, 40, 60])
    verifyEq(list.findAll|Int v, Int i->Bool| { return i % 2 == 0 },  [0, 20, 40])
    verifyEq(list.findAll|Int v, Int i->Bool| { return false },  Int[,])
    verifyEq(list.findAll|Int v->Bool| { return false },  Int[,])
    verifyEq(list.findAll|->Bool| { return false },  Int[,])

    // findType
    verifyEq(["a", 3, "b", 6sec].findType(Str#), ["a", "b"])
    verify(["a", 3, "b", 6sec].findType(Str#) is Str[])
    verifyEq(["a", 3, "b", 6sec, 5f].findType(Num#), [3, 5f])
    verify(["a", 3, "b", 6sec, 5f].findType(Num#) is Num[])
    verifyEq([null, "a", 3, "b", null, 5ms].findType(Duration#), [5ms])
    verifyEq(["a", 3, "b", 6sec, 5f].findType(Obj#), ["a", 3, "b", 6sec, 5f])

    // exclude
    verifyEq(list.exclude|Int v, Int i->Bool| { return v % 20 == 0 }, [10, 30])
    verifyEq(list.exclude|Int v, Int i->Bool| { return i % 2 == 0 },  [10, 30, 60])
    verifyEq(list.exclude|Int v, Int i->Bool| { return true },  Int[,])
    verifyEq(list.exclude|Int v->Bool| { return true },  Int[,])
    verifyEq(list.exclude|->Bool| { return true },  Int[,])

    // typed assign
    Int[] a := list.findAll |Int v->Bool| { return v.toStr.size == 1 }
    verifyEq(a, [0])

    // regression test for #1039
    verifyEq(["x", null].findAll { it != null }, Str?["x"])
  }

//////////////////////////////////////////////////////////////////////////
// Reduce
//////////////////////////////////////////////////////////////////////////

  Void testReduce()
  {
    list := [3, 4, 5]
    verifyEq(list.reduce(0) |Int r, Int v->Obj| { return v*2 + (Int)r }, 24)
    verifyEq(list.reduce(0) |Int r, Int v->Obj| { return v*2 + r }, 24)
    verifyEq(list.reduce(10) |Int r, Int v, Int i->Obj| { return v + (Int)r + i }, 25)
  }

//////////////////////////////////////////////////////////////////////////
// Map
//////////////////////////////////////////////////////////////////////////

  Void testMap()
  {
    list := [3, 4, 5]
    verifyEq(list.map |Int v->Obj| { v*2 },  Obj[6, 8, 10])
    verifyEq(list.map |Int v->Int| { v*2 },  Int[6, 8, 10])
    verifyEq(list.map |Int v->Obj?| { return null }, [null, null, null])
    verifyEq(list.map |Int v, Int i->Bool| { return i%2==0 },  [true, false, true])
  }

//////////////////////////////////////////////////////////////////////////
// FlatMap
//////////////////////////////////////////////////////////////////////////

  Void testFlatMap()
  {
    list := ['a', 'b']
    verifyEq(list.flatMap |v| { [v.toChar, v.toChar.upper] }, Obj?["a", "A", "b", "B"])
    verifyEq(list.flatMap |v->Str[]| { [v.toChar, v.toChar.upper] }, Str["a", "A", "b", "B"])
    verifyEq(list.flatMap |v->Str?[]| { [v.toChar, v.toChar.upper] }, Str?["a", "A", "b", "B"])
    verifyEq(list.flatMap |v, i->Int[]| { [v, i] }, ['a', 0, 'b', 1])
  }

//////////////////////////////////////////////////////////////////////////
// Any/All
//////////////////////////////////////////////////////////////////////////

  Void testAnyAll()
  {
    // empty
    list := Str[,]
    verifyEq(list.any |Str s->Bool| { return s.size == 3 }, false)
    verifyEq(list.all |Str s->Bool| { return s.size == 3 }, true)

    // all 3
    list = ["foo", "bar"]
    verifyEq(list.any |Str s->Bool| { return s.size == 3 }, true)
    verifyEq(list.all |Str s->Bool| { return s.size == 3 }, true)
    verifyEq(list.any |Str s->Bool| { return s.size == 4 }, false)
    verifyEq(list.all |Str s->Bool| { return s.size == 4 }, false)

    // one 3, one 4
    list = ["foo", "pool"]
    verifyEq(list.any |Str s->Bool| { return s.size == 3 }, true)
    verifyEq(list.all |Str s->Bool| { return s.size == 3 }, false)
    verifyEq(list.any |Str s->Bool| { return s.size == 4 }, true)
    verifyEq(list.all |Str s->Bool| { return s.size == 4 }, false)

    // one 3, one 4 with index
    list = ["foo", "pool"]
    verifyEq(list.any |Str s,Int i->Bool| { return s.size == 3 }, true)
    verifyEq(list.all |Str s,Int i->Bool| { return s.size == 3 }, false)
    verifyEq(list.any |Str s,Int i->Bool| { return s.size == 4 }, true)
    verifyEq(list.all |Str s,Int i->Bool| { return s.size == 4 }, false)
  }

//////////////////////////////////////////////////////////////////////////
// Min/Max
//////////////////////////////////////////////////////////////////////////

  Void testMinMax()
  {
    // empty
    list := Str[,]
    verifyEq(list.min, null)
    verifyEq(list.max, null)
    verifyEq(list.min |Str a, Str b->Int| { return a.size <=> b.size }, null)
    verifyEq(list.max |Str a, Str b->Int| { return a.size <=> b.size }, null)

    // doc example
    list = Str["albatross", "dog", "horse"]
    verifyEq(list.min, "albatross")
    verifyEq(list.max, "horse")
    verifyEq(list.min |Str a, Str b->Int| { return a.size <=> b.size }, "dog")
    verifyEq(list.max |Str a, Str b->Int| { return a.size <=> b.size }, "albatross")

    // with null
    list = Str?["a", null, "b"]
    verifyEq(list.min, null)
    verifyEq(list.max, "b")
  }

//////////////////////////////////////////////////////////////////////////
// Unique
//////////////////////////////////////////////////////////////////////////

  Void testUnique()
  {
    verifyEq(Str[,].unique, Str[,])
    verifyEq(["a"].unique, ["a"])
    verifyEq(["a", "b"].unique, ["a", "b"])
    verifyEq(["a", "b", "c"].unique, ["a", "b", "c"])
    verifyEq(["a", "a", "b", "c"].unique, ["a", "b", "c"])
    verifyEq(["a", "b", "a", "c"].unique, ["a", "b", "c"])
    verifyEq(["a", "b", "c", "a"].unique, ["a", "b", "c"])
    verifyEq(["a", null, "b", "c", "a"].unique, ["a", null, "b", "c"])
    verifyEq(["a", null, "b", "b", "c", "a", null, "c", "a", "a"].unique, ["a", null, "b", "c"])

    // test for mutable entries
    m1 := StrBuf().add("1")
    m2 := StrBuf().add("2")
    m3 := StrBuf().add("3")
    verifyEq([m1, m2, m3].unique, [m1, m2, m3])
    verifyEq([m1, m1, m2, m2, m3, m3].unique, [m1, m2, m3])
  }

//////////////////////////////////////////////////////////////////////////
// Union
//////////////////////////////////////////////////////////////////////////

  Void testUnion()
  {
    //verifyType([0, 1, 2].union([2]), Int[]#)
    verifyEq(Int[,].union([2]), [2])
    verifyEq(Int[6].union(Int[,]), [6])
    verifyEq(Int[0, 1, 2].union(Int[1, 2, 3]), [0, 1, 2, 3])
    verifyEq(Int[0, 1, 2].union(Int[10, 20]), [0, 1, 2, 10, 20])
    verifyEq(Int[0, 1, 2, 1, 2, 0].union(Int[10, 20, 10, 10]), [0, 1, 2, 10, 20])
    verifyEq(Int?[null, 0, 1, 2].union(Int?[10, null, 20, 2]), [null, 0, 1, 2, 10, 20])
  }

//////////////////////////////////////////////////////////////////////////
// Intersection
//////////////////////////////////////////////////////////////////////////

  Void testIntersection()
  {
    //verifyType([0, 1, 2].intersection([2]), Int[]#)
    verifyEq(Int[,].intersection([2]), Int[,])
    verifyEq(Int[6].intersection(Int[,]), Int[,])
    verifyEq([4].intersection([5]), Int[,])
    verifyEq([0, 1, 2].intersection([2]), [2])
    verifyEq([0, 1, 2].intersection([0, 2]), [0,2])
    verifyEq([0, 1, 2].intersection([2, 0]), [0,2])
    verifyEq([0, 1, 2].intersection([0, 1, 2]), [0, 1, 2])
    verifyEq([0, 1, 2].intersection([0, 1, 2, 3]), [0, 1, 2])
    verifyEq([0, 1, 2].intersection([3, 2, 1, 0]), [0, 1, 2])
    verifyEq([0, 1, 2, 3].intersection([5, 3, 1]), [1, 3])
    verifyEq([0, null, 2].intersection([0, 1, 2, 3]), Int?[0, 2])
    verifyEq([0, null, 2].intersection([null, 0, 1, 2, 3]), [0, null, 2])
    verifyEq([0, 1, 2, 2, 1, 1].intersection([2, 2, 1, 0]), [0, 1, 2])
    verifyEq([0, 1, null, 2, 1, null, 1].intersection([2, null, 2, 1, 0]), [0, 1, null, 2])
  }

//////////////////////////////////////////////////////////////////////////
// Sort
//////////////////////////////////////////////////////////////////////////

  Void testSort()
  {
    x := Int[,]
    x.sort
    verifyEq(x, Int[,])

    x = [6, 3, 5, 2, 4, 1]
    x.sort
    verifyEq(x, Int[1, 2, 3, 4, 5, 6])
    x.sort
    verifyEq(x, Int[1, 2, 3, 4, 5, 6])
    x.sortr
    verifyEq(x, Int[6, 5, 4, 3, 2, 1])
    x.sortr
    verifyEq(x, Int[6, 5, 4, 3, 2, 1])

    x = [3, 1, 6, 4, 2, 5]
    x.sort |Int a, Int b->Int| { return a <=> b }
    verifyEq(x, Int[1, 2, 3, 4, 5, 6])
    x.sortr |Int a, Int b->Int| { return a <=> b }
    verifyEq(x, Int[6, 5, 4, 3, 2, 1])

    x = [3, 1, 6, 4, 2, 5]
    names := ["zero", "one", "two", "three", "four", "five", "six" ]
    comparator := |Int a, Int b->Int| { return names[a] <=> names[b] }
    x.sort(comparator)
    verifyEq(x, Int[5, 4, 1, 6, 3, 2])
    x.sortr(comparator)
    verifyEq(x, Int[2, 3, 6, 1, 4, 5])
  }

//////////////////////////////////////////////////////////////////////////
// Binary Search
//////////////////////////////////////////////////////////////////////////

  Void testBinarySearch()
  {
    x := Int[,]
    verifyEq(x.binarySearch(0), -1)
    verifyEq(x.binarySearch(99), -1)

    x = [4]
    verifyEq(x.binarySearch(0), -1)
    verifyEq(x.binarySearch(4), 0)
    verifyEq(x.binarySearch(5), -2)

    x = [4, 4]
    verifyEq(x.binarySearch(0), -1)
    verifyEq(x.binarySearch(4), 0)
    verifyEq(x.binarySearch(5), -3)

    x = [4, 6]
    verifyEq(x.binarySearch(3), -1)
    verifyEq(x.binarySearch(4), 0)
    verifyEq(x.binarySearch(5), -2)
    verifyEq(x.binarySearch(6), 1)
    verifyEq(x.binarySearch(7), -3)

    x = [4, 6, 11]
    verifyEq(x.binarySearch(-99), -1)
    verifyEq(x.binarySearch(3), -1)
    verifyEq(x.binarySearch(4), 0)
    verifyEq(x.binarySearch(5), -2)
    verifyEq(x.binarySearch(6), 1)
    verifyEq(x.binarySearch(7), -3)
    verifyEq(x.binarySearch(10), -3)
    verifyEq(x.binarySearch(11), 2)
    verifyEq(x.binarySearch(12), -4)
    verifyEq(x.binarySearch(99), -4)

    x = [4, 6, 11, 11]
    verifyEq(x.binarySearch(3), -1)
    verifyEq(x.binarySearch(4), 0)
    verifyEq(x.binarySearch(5), -2)
    verifyEq(x.binarySearch(6), 1)
    verifyEq(x.binarySearch(8), -3)
    verifyEq(x.binarySearch(11), 2)
    verifyEq(x.binarySearch(12), -5)

    y := ["4", "6", "11", "11"]
    f := |Str a, Str b->Int| { return a.toInt <=> b.toInt }
    verifyEq(y.binarySearch("3", f), -1)
    verifyEq(y.binarySearch("4", f), 0)
    verifyEq(y.binarySearch("5", f), -2)
    verifyEq(y.binarySearch("6", f), 1)
    verifyEq(y.binarySearch("8", f), -3)
    verifyEq(y.binarySearch("11", f), 2)
    verifyEq(y.binarySearch("12", f), -5)

    x = [2, 5, 7, 10, 11, 12, 15]
    verifyEq(x.binarySearch(1), -1)
    verifyEq(x.binarySearch(2), 0)
    verifyEq(x.binarySearch(3), -2)
    verifyEq(x.binarySearch(5), 1)
    verifyEq(x.binarySearch(6), -3)
    verifyEq(x.binarySearch(7), 2)
    verifyEq(x.binarySearch(9), -4)
    verifyEq(x.binarySearch(10), 3)
    verifyEq(x.binarySearch(11), 4)
    verifyEq(x.binarySearch(12), 5)
    verifyEq(x.binarySearch(13), -7)
    verifyEq(x.binarySearch(15), 6)
    verifyEq(x.binarySearch(16), -8)

    x.clear
    Int.random(100..113).times |Int a| { x.add(Int.random()) }
    x.sort
    //Fix bug
    x = x.unique
    x.each |Int v, Int i| { verifyEq(x.binarySearch(v), i) }
  }

//////////////////////////////////////////////////////////////////////////
// Binary Find
//////////////////////////////////////////////////////////////////////////

  Void testBinaryFind()
  {
    // list of list of numbers sorted by sum
    x := [[2, 2], [1, 2, 3], [3, 4], [8]]
    sum := |Int r, Int v->Int| { r + v }
    // calculate sum by item
    f := |Int[] item->Int| { item.reduce(0, sum) }
    // find element by sum
    verifyEq(x.binaryFind { 0 - f(it) }, -1)
    verifyEq(x.binaryFind { 5 - f(it) }, -2)
    verifyEq(x.binaryFind { 7 - f(it) },  2)
    verifyEq(x.binaryFind { 9 - f(it) }, -5)
    // find element by index
    x.each |Int[] val, Int index|
    {
      verifyEq(index, x.binaryFind |Int[] v, Int i->Int| { index - i })
    }
  }

//////////////////////////////////////////////////////////////////////////
// Reverse
//////////////////////////////////////////////////////////////////////////

  Void testReverse()
  {
    verifyEq(Int[,].reverse, Int[,])
    verifyEq(Int[5].reverse, Int[5])
    verifyEq(Int[1,2].reverse, Int[2,1])
    verifyEq(Int[1,2,3].reverse, Int[3,2,1])
    verifyEq(Int[1,2,3,4].reverse, Int[4,3,2,1])
    verifyEq(Int[1,2,3,4,5].reverse, Int[5,4,3,2,1])
    verifyEq(Int[1,2,3,4,5,6].reverse, Int[6,5,4,3,2,1])
    verifyEq(Int[1,2,3,4,5,6,7].reverse, Int[7,6,5,4,3,2,1])
    verifyEq(Int[1,2,3,4,5,6,7,8].reverse, Int[8,7,6,5,4,3,2,1])
  }

//////////////////////////////////////////////////////////////////////////
// Swap
//////////////////////////////////////////////////////////////////////////

  Void testSwap()
  {
    x := [0, 1, 2, 3, 4]
    verifyEq(x.swap(0, 1),   [1, 0, 2, 3, 4])
    verifyEq(x.swap(-1, -2), [1, 0, 2, 4, 3])
    verifyEq(x.swap(2, -2),  [1, 0, 4, 2, 3])
  }

//////////////////////////////////////////////////////////////////////////
// MoveTo
//////////////////////////////////////////////////////////////////////////

  Void testMoveTo()
  {
    x := [0, 1, 2, 3, 4]
    Int? nil := null
    verifyEq(x.moveTo(4, 0),  [4, 0, 1, 2, 3])
    verifyEq(x.moveTo(4, 1),  [0, 4, 1, 2, 3])
    verifyEq(x.moveTo(4, -1), [0, 1, 2, 3, 4])
    verifyEq(x.moveTo(4, -2), [0, 1, 2, 4, 3])
    verifyEq(x.moveTo(9, -2), [0, 1, 2, 4, 3])
    verifyEq(x.moveTo(4, -3), [0, 1, 4, 2, 3])
    verifyEq(x.moveTo(4, 2),  [0, 1, 4, 2, 3])
    verifyEq(x.moveTo(4, -3), [0, 1, 4, 2, 3])
    verifyEq(x.moveTo(4, 3),  [0, 1, 2, 4, 3])
    verifyEq(x.moveTo(4, 4),  [0, 1, 2, 3, 4])
    verifyEq(x.moveTo(nil, 2), [0, 1, 2, 3, 4])
  }

//////////////////////////////////////////////////////////////////////////
// Flatten
//////////////////////////////////////////////////////////////////////////

  Void testFlatten()
  {
    verifyEq([,].flatten, [,])
    verifyNotSame([,].flatten, [,])
    verifyEq([2].flatten, Obj?[2])
    verifyEq([2,3].flatten, Obj?[2,3])
    verifyEq([2,[3,4],5].flatten, Obj?[2,3,4,5])
    verifyEq([2,[3,[4,5]],[6,7]].flatten, Obj?[2,3,4,5,6,7])
    verifyEq([[[[34]]]].flatten, Obj?[34])
    verifyEq([[[[,]]]].flatten, Obj?[,])
    verifyEq([[[[1,2],3],4],5].flatten, Obj?[1,2,3,4,5])
  }

//////////////////////////////////////////////////////////////////////////
// Random
//////////////////////////////////////////////////////////////////////////

  Void testRandom()
  {
    verifyEq([,].random, null)

    10.times { verifyEq([4].random, 4) }

    list := (0..<20).toList
    map := Int:Bool[:]
    1000.times { map.set(list.random, true) }
    20.times { verify(map[it]) }
  }

//////////////////////////////////////////////////////////////////////////
// Shuffle
//////////////////////////////////////////////////////////////////////////

  Void testShuffle()
  {
    // empty
    verifyEq([,].shuffle, [,])

    // one
    x := [2]
    verifySame(x.shuffle, x)
    verifyEq(x.shuffle, [2])

    // combos
    verifyShuffle([1, 2], 2)
    verifyShuffle([1, 2, 3], 6)
    verifyShuffle([1, 2, 3, 4], 24)
  }

  Void verifyShuffle(Obj?[] x, Int expectedCombos)
  {
    combos := Str:Str[:]
    for (i := 0; true; ++i)
    {
      if (i > 10000) fail
      x.shuffle
      s := x.join(",")
      combos[s] = s
      if (combos.size == expectedCombos) { verify(true); break }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

  Void testStr()
  {
    o := [,]
    verifyEq(o.toStr,     "[,]")
    verifyEq(o.join,      "")
    verifyEq(o.join("-"), "")
    verifyEq(o.join("-") |Obj x->Str| { return "($x)" }, "")

    s := ["foo"]
    verifyEq(s.toStr,      "[foo]")
    verifyEq(s.join,       "foo")
    verifyEq(s.join("-"),  "foo")
    verifyEq(s.join("; "), "foo")
    verifyEq(s.join("-") |Str x->Str| { return "($x)" }, "(foo)")

    s = [(Str?)null]
    verifyEq(s.toStr,      "[null]")
    verifyEq(s.join,       "null")
    verifyEq(s.join("-"),  "null")
    verifyEq(s.join("; "), "null")
    verifyEq(s.join("-") |Str? x->Str| { return "($x)" }, "(null)")

    s = ["a", "b", "c"]
    verifyEq(s.toStr,      "[a, b, c]")
    verifyEq(s.join,       "abc")
    verifyEq(s.join("-"),  "a-b-c")
    verifyEq(s.join("; "), "a; b; c")
    verifyEq(s.join("-") |Str x->Str| { return "($x)" }, "(a)-(b)-(c)")

    s = [null, "foo", null]
    verifyEq(s.toStr,      "[null, foo, null]")
    verifyEq(s.join,       "nullfoonull")
    verifyEq(s.join("-"),  "null-foo-null")
    verifyEq(s.join("; "), "null; foo; null")
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq(Obj?[,].toCode, "[,]")
    verifyEq(Str[,].toCode, "[,]")
    verifyEq([4, -8, 3].toCode, "[4, -8, 3]")
    verifyEq([2, 3f].toCode, "[2, 3.0f]")
    //verifyEq([2, 3f, 4d].toCode, "sys::Num[2, 3.0f, 4d]")
    verifyEq(["foo", `bar`].toCode, "[\"foo\", `bar`]")
  }

//////////////////////////////////////////////////////////////////////////
// AssignOps
//////////////////////////////////////////////////////////////////////////

  Void testAssignOps()
  {
    x := [1]
    x[0] += 1
    verifyEq(x.first, 2)
    verifyEq(x[0]++, 2); verifyEq(x.first, 3)
    verifyEq(++x[0], 4); verifyEq(x.first, 4)
    x[0] += x[0]
    verifyEq(x[0], 8)
    x.add(0xabcd)
    x[1] = x[1].shiftl(4)
    verifyEq(x, [8, 0xabcd0])

    f := [3f, 2f]
    f[1] *= 8f
    verifyEq(f, [3f, 16f])

    s := ["x"]
    s[0] += "y"
    verifyEq(s, ["xy"])
  }

//////////////////////////////////////////////////////////////////////////
// Readonly
//////////////////////////////////////////////////////////////////////////

  Void testReadonly()
  {
    // create rw list
    x := ["a", "b", "c"].trim
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
    //verifyType(r, Str[]#)
    verifyEq(r.isEmpty, false)
    verifyEq(r.size, 3)
    verifyEq(r.capacity, 3)
    verifyEq(r[0], "a")
    verifyEq(r[1], "b")
    verifyEq(r[2], "c")
    verifyEq(r[0..1], ["a", "b"])
    verifyEq(r.contains("b"), true)
    verifyEq(r.contains("x"), false)
    verifyEq(r.index("c"), 2)
    verifyEq(r.first, "a")
    verifyEq(r.last, "c")
    verifyEq(r.peek, "c")
    verifyEq(r.dup, ["a", "b", "c"])
    r.each |Str s, Int i| { verifyEq(r[i], s) }
    r.eachr |Str s, Int i| { verifyEq(r[i], s) }
    verifyEq(r.find |Str s->Bool| { s == "b" }, "b")
    verifyEq(r.findAll |Str s->Bool| { true }, ["a", "b", "c"])
    verifyEq(r.exclude |Str s->Bool| { s == "c" }, ["a", "b"])
    verifyEq(r.any |Str s->Bool| { true }, true)
    verifyEq(r.all |Str s->Bool| { true }, true)
    verifyEq(r.reduce(0) |Obj result, Str ignore->Obj| { result }, 0)
    verifyEq(r.map |Str s->Int| { s.size}, [1, 1, 1])
    verifyEq(r.min, "a")
    verifyEq(r.max, "c")
    verifyEq(r.unique, ["a", "b", "c"])
    verifyEq(r.union(["a", "d"]), ["a", "b", "c", "d"])
    verifyEq(r.intersection(["a", "d"]), ["a"])
    verifyEq(r.toStr, "[a, b, c]")
    verifyEq(r.join, "abc")

    // verify all modification methods throw ReadonlyErr
    verifyErr(ReadonlyErr#) { r->size = 10 }
    verifyErr(ReadonlyErr#) { r.capacity = 10 }
    verifyErr(ReadonlyErr#) { r[2] = "x" }
    verifyErr(ReadonlyErr#) { r.add("x") }
    verifyErr(ReadonlyErr#) { r.addAll(["x"]) }
    verifyErr(ReadonlyErr#) { r.insert(2, "x") }
    verifyErr(ReadonlyErr#) { r.insertAll(2, ["x"]) }
    verifyErr(ReadonlyErr#) { r.remove("a") }
    verifyErr(ReadonlyErr#) { r.removeAt(5) }
    verifyErr(ReadonlyErr#) { r.removeSame("a") }
    verifyErr(ReadonlyErr#) { r.removeAll(["a", "b"]) }
    verifyErr(ReadonlyErr#) { r.clear }
    verifyErr(ReadonlyErr#) { r.trim }
    verifyErr(ReadonlyErr#) { r.fill("", 3) }
    verifyErr(ReadonlyErr#) { r.pop }
    verifyErr(ReadonlyErr#) { r.push("x") }
    verifyErr(ReadonlyErr#) { r.sort }
    verifyErr(ReadonlyErr#) { r.sortr }
    verifyErr(ReadonlyErr#) { r.reverse }
    verifyErr(ReadonlyErr#) { r.swap(0, 1) }
    verifyErr(ReadonlyErr#) { r.shuffle }

    // verify rw detaches ro
    x.add("d")
    r2 := x.ro
    //verifySame(x.ro, r2)
    verifyNotSame(r2, r)
    verifyNotSame(x.ro, r)
    verifyEq(r.isRO, true)
    verifyEq(r.size, 3)
    verifyEq(r, ["a", "b", "c"])
    x.remove("b")
    r3 := x.ro
    //verifySame(x.ro, r3)
    verifyNotSame(r2, r3)
    verifyNotSame(r3, r)
    verifyNotSame(r2, r)
    verifyNotSame(x.ro, r)
    verifyEq(r.size, 3)
    verifyEq(r, ["a", "b", "c"])

    // verify ro to rw
    y := r.rw
    verifyEq(y.isRW, true)
    verifyEq(y.isRO, false)
    verifySame(y.rw, y)
    //verifySame(y.ro, r)
    verifyEq(y, r)
    verifyEq(r.isRO, true)
    verifyEq(r.size, 3)
    verifyEq(r, ["a", "b", "c"])
    verifyEq(y, ["a", "b", "c"])
    y.sortr
    verifyNotSame(y.ro, r)
    verifyEq(y.size, 3)
    verifyEq(y, ["c", "b", "a"])
    verifySame(y.rw, y)
    verifyEq(r, ["a", "b", "c"])
    y.add("d")
    verifyEq(y.size, 4)
    verifyEq(y, ["c", "b", "a", "d"])
    verifyEq(r.size, 3)
    verifyEq(r, ["a", "b", "c"])
  }

//////////////////////////////////////////////////////////////////////////
// ToImmutable
//////////////////////////////////////////////////////////////////////////

  Void testToImmutable()
  {
    a := ["a"]
    b := ["b"]
    c := ["c"]

    x := [a, b, c]
    Str[][] xc := x.toImmutable

    y := [x]
    Str[][][] yc := y.toImmutable

    verifyNotSame(x.ro, xc)
    verifyEq(xc.isRO, true)
    verifyEq(xc.isImmutable, true)
    verifySame(xc.toImmutable, xc)
    verifyEq(xc[0], a)
    verifyEq(xc[1], b)
    verifyEq(xc[2], c)
    verifyEq(xc[0].isRO, true)
    verifyEq(xc[1].isRO, true)
    verifyEq(xc[2].isRO, true)

    verifyNotSame(y.ro, yc)
    verifyEq(yc.isRO, true)
    verifyEq(yc.isImmutable, true)
    verifySame(yc.toImmutable, yc)
    verifyEq(yc[0][0].isRO, true)
    verifyEq(yc[0][0].isImmutable, true)

    m := [0:"zero", 99:null]
    z := [m, null]
    [Int:Str?]?[] zc := z.toImmutable
    //verifyEq(Type.of(zc).signature, "[sys::Int:sys::Str?]?[]")
    verify(zc.isRO)
    verify(zc[0].isRO)
    verify(zc[0].isImmutable)
    verifyEq(zc[0], m)
    verify(zc[1] == null)

    xrw := xc.rw
    verifyEq(xrw.isImmutable, false)
    verifyEq(xc.isImmutable, true)
    xrw[0] = ["Z"]
    verifyEq(xc[0], ["a"])
    verifyEq(xrw[0], ["Z"])

    verifyEq([,].isImmutable, false)
    verifyEq([,].ro.isImmutable, false)
    verifyEq([,].toImmutable.isImmutable, true)

    verifyEq([1,2].isImmutable, false)
    verifyEq([1,2].ro.isImmutable, false)
    verifyEq([1,2].toImmutable.isImmutable, true)

    verifyEq([this].isImmutable, false)
    verifyEq([this].ro.isImmutable, false)
    verifyErr(NotImmutableErr#) { [this].toImmutable }
    verifyErr(NotImmutableErr#) { [0, this, 2].toImmutable }
    verifyErr(NotImmutableErr#) { [0, [this], 2].toImmutable }
  }

}