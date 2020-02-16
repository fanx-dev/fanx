class Foo
{
  static Obj a() { return A { x } }          // missing comma
  static Obj b() { return B { 5, } }         // can't add Int
  static Obj c() { return B { A(), 5, } }    // can't add Int
  static Obj d() { return B { A.make, } }    // ok
  static Obj e() { return B { A { x=3 }, } } // ok
  static Obj f() { return B { A() } }        // missing comma
  static Obj g() { return B { A() {} } }     // missing comma
  static Obj h() { return B { A {} } }       // missing comma
  static Obj i(Foo f) { f { it = f } }       // not assignable
  static Obj j() { return A { return } }     // return not allowed
  static Obj k() { return |C c| { c.x = 3 } }          // const outside it-block
  static Obj l() { c := C(); return |->| { c.x = 3 } }  // const outside it-block
  static Obj m() { return D { A.make, } }    // missing @Op facet
  static Obj n() { return D { A { x=3 }, } } // missing @Op facet
}

class A { Int x; Int y}
class B { @Operator This add(A x) { return this } }
class C { const Int x }
class D { This add(A x) { return this } }