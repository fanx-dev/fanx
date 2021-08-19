class Foo
{
  static Obj a() { return A {} }
  static Obj b() { return it.toStr }
  Obj c() { return it.toStr }
  static Void d() { v { echo(9) } }
  static Void e() { f0 {} }
  static Void f() { f1 {} }  // ok
  static Void g() { f2 {} }  // ok
  static Obj h() { return B { x = 4 } }
  static Obj i() { return B { 6, } }

  static Void v() {}
  static Void f0(|->| f) {}
  static Void f1(|Obj?| f) {}
  static Void f2(|Obj?,Obj?| f) {}
}

class A { new mk() {} }
class B { }