class Foo
{
  static Int? f(Str? s)
  {
    Int? x := null
    switch (s)
    {
      case "a": x = 'a'
      case "b": x = 'b'
      default: x = '?'
    }
    return x
  }
}