class Acme
{
  Obj a() { Foo().m1(null) { it.x = 'a' } }
  Obj b() { Foo().m1(null) { x = 'b' } }
  Obj c() { Foo().m2 { it.x = 'c' } }
  Obj d() { Foo().m2 { x = 'd' } }
  Obj e() { Foo().m2(5, null) { it.x = 'e' } }
  Obj f() { Foo().m2(5, null) { x = 'f' } }
  Obj g() { Foo().m3 { x = 'g' } }
  Obj h() { Foo().m4 { fill(2, 2) } }
  Obj i() { Foo().m4(9) { fill(3, 3) } }
  static Obj j() { Foo { z =  'j' } }
  static Obj k() { Acme { z =  'k' } }

  Int z
}

class Foo
{
  Foo m1(|Str|? f := null) { return this }
  Foo m2(Int a := 5, |Str|? f := null) { return this }
  This m3() { return this }
  Int[] m4(Int a := 5) { return Int[,] }
  Int x
  Int z
}