class Foo
{
  Void m0() { s = "m0" }
  Void m1(|->| f := |->| { s="m1" }) { f() }
  Void m2(Str x, |Str y| f := |Str y| { s=y }) { f(x) }
  Str? s
}