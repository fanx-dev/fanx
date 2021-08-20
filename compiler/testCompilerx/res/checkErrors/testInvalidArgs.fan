class Foo
{
static Obj m00() { return 3.increment(true) }
static Obj m01() { return 3.plus }
static Obj m02() { return 3.plus(3ms) }
static Obj m03() { return 3.plus(4, 5) }
static Obj m04() { return sys::Str.spaces }
static Obj m05() { return sys::Str.spaces(true) }
static Obj m06() { return sys::Str.spaces(1, 2) }
static Obj m07() { return "abcb".index("b", true) }
static Void m08() { m := |Int a| {}; m(3ms) }
static Void m09() { m := |Str a| {}; m() }
}