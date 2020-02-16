virtual class A { new make(Str n) {}  }
virtual class B { private new make() {} }
class C : A { }
class D : B { }
class E : A { new makeIt() {} }
class F : B { new makeIt() {} }
mixin G { new make() {} }
class H { Void f(Int a := 3, Int b) {} }