class Foo
{
  static Obj? f(Obj? obj)
  {
    Obj? x := null
    switch (obj)
    {
      case "a":
      case "A":
        return 'a'
      case Str#:
        return "Str type!"
      case zero():
        x = 0
    }
    return x
  }

  static Int zero() { return 0 }
}