class Foo
{
  static Int f(Str s)
  {
    x := '?'
    switch (s)
    {
      case "a": x = 'a'
      case "b": x = 'b'
    }
    return x
  }
}