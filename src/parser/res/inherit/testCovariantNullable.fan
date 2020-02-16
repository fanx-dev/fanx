class Foo : Base
{
  override Obj  a() { return this }
  override Obj? b() { return this }
  override Str[]? c
  override Str:Int d
  override Int e
  override Int? f
}

class Base
{
  virtual Obj? a() { return this }
  virtual Obj  b() { return this }
  virtual Str[] c
  virtual [Str:Int]? d
  virtual Int? e() { return 4 }
  virtual Int f() { return 4 }
}