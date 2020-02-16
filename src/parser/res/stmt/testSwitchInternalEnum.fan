enum class Foo { a, b, c }
class Bar
{
  static Int f(Foo foo)
  {
    switch (foo)
    {
      case Foo.a: return 10
      case Foo.c: return 12
      default:    return 99
    }
  }
}