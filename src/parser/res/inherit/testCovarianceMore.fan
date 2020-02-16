abstract class AA
{
  abstract Obj y()
}

abstract class A : AA
{
  abstract Obj x()
  override abstract Num y()
}

mixin M
{
  abstract Obj x()
  virtual Obj y() { return 4 }
}

class B : A, M
{
  override B x() { return this }
  static Obj xA(A a) { return a.x }
  static Obj xM(M m) { return m.x }
  static B xB(B b) { return b.x }

  override Num y() { return 8 }
  static Obj yAA(AA a) { return a.y }
  static Num yA(A a) { return a.y }
  static Obj yM(M m) { return m.y }
  static Num yB(B b) { return b.y }
}