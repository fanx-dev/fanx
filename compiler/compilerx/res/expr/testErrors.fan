class Foo
{
static Obj a() { return foobar }
static Obj b() { return 3.foobar }
static Obj c() { return 3.noway() }
static Obj d() { return 3.nope(3) }
static Obj e() { return sys::Str.foo }
static Obj f() { return sys::Str.foo() }
static Obj g(Int x) { x := 3 }
static Obj h(Int y) { Int y; }
static Obj i() { z := 3; z := 5 }
static Obj j() { return foobar.x }
static Obj k() { return 8f.foobar().x.y }
static Obj l() { return foo + bar }
static Obj m() { return (4.foo.ouch + bar().boo).rightOn }
static Obj n(Str x) { return x++ }
static Obj o(Str x) { return --x }
static Obj q(Str x) { return x / 3 }
static Obj r(Str x) { return x -= 3 }
static Obj s(Str x) { return x?.foo }
static Obj t(Str x) { return x?.foo() }
static Obj u() { return Str#bad }
static Obj v() { return #bad }
}