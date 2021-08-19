class Foo
{
  Int geta() { return x }
  Int gets() { return &x }

  virtual Int x := 3
}

class Bar : Foo, Mix
{
  override Int x := 4
}

mixin Mix
{
  abstract Int x
}