class Foo
 {
   Void m03() { x := 7; x = x }
   Void m04() { f = f }
   Void m05() { f = this.f }
   Void m06() { this.f = f }
   Void m07() { this.f = this.f }
   Void m08() { foo.f = foo.f }
   Void m09() { foo.f = this.foo.f }
   Obj m10(Int f) { Foo { f = f } }
   Obj m11(Int f) { Foo { it.f = it.f } }
   Obj m12(Int f) { Foo { this.f = this.f } }

   const static Str bar := Foo.bar

   Void ok01(Foo foo) { this.foo = foo }
   Void ok03(Foo x) { f = x.f }
   Void ok04(Foo x) { foo.f = x.foo.f }
   Void ok05() { Obj a := 1; [2].each |Obj b| { a = b } } // ok
   Obj ok06(Int f) { Foo { it.f = f } }
   Obj ok07(Int f) { Foo { it.f = this.f } }
   Obj ok08(Int f) { Foo { this.f = it.f } }
   Obj ok09(Int f) { Foo { this.f = f } }
   Obj ok10(Int f) { Foo { f = it.f } }
   Obj ok11(Int f) { Foo { f = this.f } }


   Int f
   Foo? foo
 }