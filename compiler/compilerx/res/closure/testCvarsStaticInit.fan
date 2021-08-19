class Foo
{
  const static Int f
  static
  {
    Int x := 0
    3.times
    {
      2.times { x++ }
    }
    f = |->Int| { return x }.call
  }

  const static Str g
  static
  {
    Str x := "";
    [0ms, 1ms, 2ms].each|Duration d|
    {
      x += d.toStr
    }
    g = x
  }
}