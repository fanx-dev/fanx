class Foo
{
  static Void f(Int[] r)
  {
    r.add(0)
    try
    {
      for (i:=0; i<5; ++i)
      {
        r.add(10+i)
        try
        {
          try
          {
            if (i == 2) throw IOErr.make
            r.add(20+i)
          }
          finally
          {
            r.add(30+i)
          }

          try
          {
            xxx := 555
          }
          finally
          {
            r.add(300+i)
          }
        }
        catch
        {
          try
          {
            r.add(900+i)
            throw IOErr.make
            r.add(910+i)
          }
          catch (IOErr e)
          {
            r.add(920+i)
          }
          finally
          {
            r.add(930+i)
          }
          break
        }
        r.add(50+i)
      }
    }
    finally
    {
      r.add(99)
    }
    r.add(999)
  }
}