class Foo
{
  static Int f(Str? s)
  {
    switch (s)
    {
      case "a":
      case "A": return 'a'
      case "b":
      case "B": return 'b'
      case "c":
      case "C":
      default: return '?'
    }
  }
}