abstract class Foo : Whatever
{
  final Void m00() {}
  const Void m01() {}
  // readonly Void unused() {}

  public protected Void m10() {}
  public private Void m11() {}
  public internal Void m12() {}
  protected private Void m13() {}
  protected internal Void m14() {}
  internal private Void m15() {}

  override new m22() {}
  virtual new m23() {}
  abstract native Void m24()
  static abstract Void m25()
  static override Void m26() {}
  static virtual Void m27() {}

  private virtual Void m28() {}
}

abstract class Bar
{
  abstract new m20 ()
  native new m21()

  once new m30() {}
  once static Int m31() { return 3 }
  abstract once Int m32()
}

abstract class Whatever
{
  virtual Void m22() {}
  virtual Void m26() {}
}

mixin MixIt
{
  once Int a() { return 3 }
}