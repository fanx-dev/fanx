class Foo
{
  static Int[] f(Int[] r)
  {
    r.add(0)
    for (i:=1; true; ++i)
    {
      try
      {
        if (i % 2 == 0) continue
        if (i == 5) break
        r.add(i)
      }
      finally
      {
        r.add(100+i)
      }
    }
    return r.add(99)
  }
}