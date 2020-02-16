class Foo
{
new make() { return }
static Obj m00() { return 1f..2 }
static Obj m01() { return 2..[,] }
static Obj m02() { return !4 }
static Obj m03() { return 4 && true }
static Obj m04() { return 0ms || [,] }
static Void m05(Str x) { x = true }
Obj m06() { this.make }
Obj m07() { this.m00 }
static Void m08(Str x) { m07; Foo.m07() }
Void m09(Str x) { this.sf.size }
static Void m10(Str x) { f.size; Foo.f.size }
static Void m11(Str x) { this.m06; super.hash() }
static Obj m12(Str x) { return 1 ? 2 : 3 }
static Bool m14(Str x, Duration y) { return x === y }
static Bool m15(Str x, Duration y) { return x !== y }
static Bool m16(Str x) { return x == m10("") }
static Bool m17(Str x) { return x != x.size }
static Bool m18(Int x) { return x < 2f }
static Bool m19(Int x) { return x <= Weekday.sun }
static Bool m20(Int x) { return x > "" }
static Bool m21(Int x) { return x >= m10("") }
static Int m22(Int x) { return x <=> 2f }
static Obj m23(Str x) { return (Num)x }
static Obj m24(Str x) { return x is Num}
static Obj m25(Str x) { return x isnot Type }
static Obj? m26(Str x) { return x as Num }
static Obj m27() { return Bar.make }
static Obj m28() { return "x=$v" }
static Obj? m29(Obj x) { return x as Foo? }
static Obj? m30(Obj x) { return x as Str[]? }

static Void v() {}

Str? f
const static Str? sf
}

abstract class Bar
{
}