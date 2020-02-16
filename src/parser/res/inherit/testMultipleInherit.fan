mixin A
{
  abstract Str a()
  abstract Str b()
  override Int hash() { return 77 }
}

class B : A
{
  override Str a() { return "B.a" }
  override Str b := "B.b"
}

mixin C : A      {
  override Str toStr() { return "C.toStr" }
}

class D : B, C
{
}