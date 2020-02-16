abstract class AA
{
  abstract Obj f()
}

abstract class A : AA
{
  abstract A x()
  abstract Obj y()
  abstract A z()
  override Num f() { return 3 }
}

mixin M
{
  abstract M x()
  abstract A y()
  abstract Obj z()
  abstract Num f()
}

class B : A, M
{
  override B x() { return this }
  override A y() { return this }
  override B z() { return this }
}