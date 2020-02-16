virtual class A : A {}
virtual class B : C {}
virtual class C : D {}
virtual class D : B {}
mixin X : Z {}
mixin Y : X {}
mixin Z : X {}