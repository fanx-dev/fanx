class Foo
{
  static Int f(Str? s)
  {
    switch (s)
    {
      case "a": return 'a'
      case "b": return 'b'
    }
    return '?'
  }
}