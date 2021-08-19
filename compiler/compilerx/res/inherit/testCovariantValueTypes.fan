class Foo : Base
{
  override Float? a() { return null}
  override Int    b() { return 0 }
  override Int    c() { return 0 }
  override Int d
}

class Base
{
  virtual Obj? a() { return this }
  virtual Obj  b() { return this }
  virtual Num  c() { return 0 }
  virtual Num  d() { return 0 }
}