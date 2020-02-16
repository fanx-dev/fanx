class Foo
{
  static Int[] f(Int[] r, Int? a)
  {
    r.add(0)
    try
    {
      r.add(a+1)
    }
    finally
    {
      r.add(99)
    }
    return r
  }
}