class Foo : A, X
{
  override const Float a
  override Int b // shouldn't work with non-const either
  override const Int c
  override const Int d
}

class A
{
  virtual Float a
}

mixin X
{
  virtual Int b(Int x) { return x}
  virtual Int c(Int x) { return x}
  abstract Int d
}