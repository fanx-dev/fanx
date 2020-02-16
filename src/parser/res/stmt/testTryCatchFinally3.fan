class Foo
{
  static Void f(Int[] r, Err? err)
  {
    r.add(0)
    try
    {
      r.add(1)
      if (err != null) throw err
      r.add(2)
    }
    catch
    {
      r.add(3)
      throw err
      r.add(4)
    }
    finally
    {
      r.add(99)
    }
  }
}