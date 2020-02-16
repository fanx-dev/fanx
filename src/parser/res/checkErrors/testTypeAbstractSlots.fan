virtual class A { abstract Void x()  }
virtual class B { abstract Void x(); abstract Void y(); }
class C : B {}
class D : A { abstract Void y(); }
class E : B, X { override Void a() {} override Void x() {} }
mixin X { abstract Void a(); abstract Void b(); }