mixin Q
{
  virtual Obj q() { return 'q' }
}

abstract class A
{
  abstract Obj x()
}

class B : A, Q
{
  override Str x := "x"
  override Str q := "q"

  //static Decimal v1(B o) { return o.x }
  //static Num v2(A o) { return o.x }
  //static Decimal v3(B o) { return o.q++ }
  //static Num v4(Q o) { return o.q }
}