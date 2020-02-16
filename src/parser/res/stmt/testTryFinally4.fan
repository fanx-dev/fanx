class Foo
{
  static Int[] f(Int[] r)
  {
    r.add(0)
    try
    {
      r.add(1)
      try
      {
        return r.add(2)
      }
      finally
      {
        r.add(3)
      }
      return r.add(4)
    }
    finally
    {
      r.add(5)
    }
    return r.add(6)
  }
}