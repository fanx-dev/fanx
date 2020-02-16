class Foo : Base, A
{
  override Void b(Int a := 0, Int b:= 1) { super.b }
  override Void a(Str a, Str? b := null) { A.super.a(a) }
  Void c() { super.b(3) } // ok
  Void d() { A.super.a("x") } // ok
}

abstract class Base
{
  virtual Void b(Int a := 0, Int b := 1) {}
}

mixin A
{
  virtual Void a(Str a, Str? b := null) {}
}