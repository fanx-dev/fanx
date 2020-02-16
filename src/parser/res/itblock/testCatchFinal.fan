class Acme
{
  Obj m(Str a)
  {
    try
    {
      if (a == \"throw\") throw ArgErr()
      else return Obj[,] { add(a) }
    }
    catch (Err e)
    {
      list := Obj[,] { add(e.toStr) }
      list.add(Type.of(e).name)
      return list
    }
  }
}