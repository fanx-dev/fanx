class Foo
{
  static Int f(Int? x)
  {
    switch (x)
    {
      case zero(): return 100
      case one():  return 101
    }
    return -1
  }

  static Int zero() { return 0 }
  static Int? one()  { return 1 }
}