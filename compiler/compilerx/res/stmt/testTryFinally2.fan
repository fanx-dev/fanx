class Foo
{
  static Int[] f(Int[] r, Bool b)
  {
    r.add(0)
    try
    {
      r.add(1)
      if (b) throw ArgErr.make
      r.add(2)
    }
    finally
    {
      r.add(3)
    }
    r.add(4)
    return r
  }
}