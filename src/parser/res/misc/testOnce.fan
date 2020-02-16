class A
{
  virtual once DateTime x() { return DateTime.now(null) }
  once DateTime bad() { throw Err.make }
}

class B : A
{
  override DateTime x() { return DateTime.now(null) }
}