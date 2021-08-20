class A
{
  static Str sa() { return "sa" }
  Str ia() { return "ia" }
  virtual Str vx() { return "A.vx" }
}

class B : A
{
  static Str sb() { return sa }
  Str ib() { return ia }
  override Str vx() { return "B.vx" }
}