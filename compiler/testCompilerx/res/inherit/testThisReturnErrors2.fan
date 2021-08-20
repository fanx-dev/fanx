class A
{
  virtual This x() { return this }
}

class B : A
{
  override B x() { return this }
}