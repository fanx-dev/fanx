class Foo
{
  Int f
  {
    get
    {
      x := 2
      return [0,1,2,3].find |Int v->Bool| { return v == x }
    }
    set
    {
      s = ""
      it.times |Int i|
      {
        2.times |Int j| { s += "($i,$j)" }
      }
    }
  }

  Str? s
}