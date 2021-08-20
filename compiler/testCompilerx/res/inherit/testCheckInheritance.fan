virtual class C {}
mixin M {}

mixin C1 : C {}
mixin C2 : Buf {}

//class D1 : C[] {}
//class D2 : M:C {}
//class D3 : Str[] {}

//class E : |Int x->M| {}
//mixin F : Int:C {}

virtual class G : Str {}
class H : LocalFile {}
class I : M {} // OK!

enum class J : G { a }

virtual class K : C1, G {}
class L : C1, Test, C2 {}
class N : G, C1, K {}