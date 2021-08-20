class Foo
{
  static Int[] f(Int[] r)
  {
    r.add(0)
    for (i:=1; i<=3; ++i)
    {
      try
      {
        if (i == 3) throw ArgErr.make
        r.add(10+i)
      }
      finally
      {
        r.add(100+i)
      }
    }
    return r.add(1)
  }
}