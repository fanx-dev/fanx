class Foo
{
  static Void f(Int[] r)
  {
    try
    {
      try
      {
        r.add(0)
        for (i:=1; true; ++i)
        {
          try
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
          finally
          {
            r.add(99)
          }
        }
        r.add(999)
      }
      finally
      {
        r.add(9999)
      }
    }
    finally
    {
      r.add(99999)
    }
  }
}