class Acme
{
  static Obj a() { return Foo.make { i = 77 } }
  static Obj b() { return Foo.make { i = 9; j += 6 } }
  static Obj c() { return Foo.make { inc } }
  static Obj d() { return Foo { i = 10; j = 11; inc } }
  static Obj e() { return Str?[,] { size = 33 } }
  static Obj f()
  {
    return Foo
    {
      i=10;
      kid = Foo
      {
        i=20;
        kid = Foo {i=30}
        kid.j = 300
      }
    }
  }

  Foo x := Foo { i=-3; j=-5 }
}


class Foo
{
  Foo inc() { i++; j++; return this }
  Int i := 2
  Int j := 5
  Foo? kid
}