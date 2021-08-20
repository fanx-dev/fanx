class Foo
{
Str a() { Str x := this->toStr; return x }
Str b() { return thru(x("B")) }
Int c() { return x(7) }
Int d() { f := |Int x->Int| { return x }; return f(x(9)) }
Int e() { return x(true) ? 2 : 3 }
Int f() { if (x(false)) return 2; else return 3 }
Int g() { throw x(ArgErr.make) }
Int[] h() { acc := Int [,]; for (i:=0; x(i<3); ++i) acc.add(i); return acc }
Int[] i() { acc := Int [,]; while (x(acc.size < 4)) acc.add(acc.size); return acc }
Bool j(Bool a) { return !x(a) }
Bool k(Bool a, Bool b) { return x(a) && x(b) }
Int l(Num a) { return a }
Int m(Num a) { Int i := a; return i }
Int n(Num a) { return thrui(a) }
Int[] o(Obj[] a) { return a }

Str thru(Str x) { return x }
Int thrui(Int x) { return x }
Obj x(Obj x) { return x }
override Str toStr() { return "Foo!" }
}