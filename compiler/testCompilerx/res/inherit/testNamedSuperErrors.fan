mixin X
{
  virtual Str f() { return "X.f" }
}

mixin Y : X
{
  //Str m00() { return super.f }  Unknown slot before CheckErrors
  Str m01() { return super.toStr }
  Str m02() { return Obj.super.toStr }
}

class A
{
  virtual Str a() { return "A.f" }
}

class Foo
{
  virtual Str f() { return "Foo.f" }
}

class B : A, Y
{
  Str m00() { return Foo.super.f }
  Str m03() { return A.super.a }
}