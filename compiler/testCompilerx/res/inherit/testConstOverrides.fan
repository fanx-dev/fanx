mixin X
{
  virtual Str x() { return "X.a" }
  Str xToStr() { return x.toStr }
}

mixin Y
{
  abstract Str y()
  Str yToStr() { return y.toStr }
}

abstract class A
{
  virtual Str a1() { return "A.a1" }
  abstract Str a2()

  Str aToStr() { return "$a1,$a2" }
}

class Foo : A, X, Y
{
  new make(Str? x := null, Str? y := null)
  {
    if (x != null) this.x = x
    if (y != null) this.y = y
  }
  override const Str x := "Foo.x"
  override const Str y := "Foo.y"
  override const Str a1 := "Foo.a1"
  override const Str a2 := "Foo.a2"

  override Str toStr() { return "$x,$y,$a1,$a2" }
}