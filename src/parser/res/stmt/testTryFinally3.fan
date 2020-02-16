class Foo
{
  static Int[] f(Int[] r)
  {
    r.add(0)
    try
    {
      r.add(1)
      return r
    }
    finally
    {
      r.add(2)
    }
  }
}