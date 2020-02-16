virtual const class Q {}
const mixin X {}
const mixin Y {}
mixin Z {}

class A : Q {}
class B : X {}
class C : Q, X, Y {}
class D : Z, X {}
mixin E : X {}
mixin F : Z, Y {}