class Foo
{
  static Void f(Int[] r)
  {
    r.add(0)
    try
    {
      r.add(1)
      try
      {
        r.add(2)
        return
      }
      finally
      {
        r.add(3)
      }
      r.add(4)
      return
    }
    finally
    {
      r.add(5)
    }
    return
  }
}