class Acme
{
  Obj a() { Foo { x = 'a' } }
  Obj b() { Foo() { x = 'b' } }
  Obj c() { f := Foo(); f { x = 'c' }; return f }
  Obj d() { f := Foo(); return f { x = 'd' } }
  Obj e() { foos(Foo { x ='e' }) }
  Obj f() { fooi(Foo { x ='f' }) }
  Obj g() { foos(Foo()) { x ='g' } }
  Obj h() { fooi(Foo()) { x ='h' } }
  Obj i() { Foo.fromStr(\"ignore\") { x = 'i' } } // we don't support short form

  Foo s := Foo { x = 's' }
  Foo t := Foo() { x = 't' }
  Foo u := fooi(Foo {x=3}) { x += 20 }
  static const ConstFoo v := ConstFoo {}
  static const ConstFoo w := ConstFoo { x = 'w' }
  static const ConstFoo c_x0 := ConstFoo.x0
  static const ConstFoo c_x2 := ConstFoo.x2

  static Foo foos(Foo f) { return f }
  Foo fooi(Foo f) { return f }
}

class Foo
{
  static Foo fromStr(Str s) { return make }
  new make() {}
  Int x
}

const class ConstFoo
{
  new make(|This|? f := null) { if (f != null) f(this) }
  static const ConstFoo x0 := ConstFoo {}
  static const ConstFoo x2 := ConstFoo { it.x = 2 }
  const Int x
}