class Foo
{
  static Int a()
  {
    x := 3
    if (true) x = 4
    return x
  }

  static Int b()
  {
    x := 2
    if (true) x = 6
    else x = 8
    return x
  }

  static Int c()
  {
    x := 10
    if (false) x = 5
    return x
  }

  static Int d()
  {
    x := 99
    if (false) x = 15
    else x = 76
    return x
  }
}