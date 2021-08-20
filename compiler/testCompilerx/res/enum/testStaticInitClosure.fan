enum class Foo
{
  a, b, c

  const static Str:Foo map
  static
  {
    m := Str:Foo[:]
    vals.each |Foo t| { m[t.name.upper] = t }
    map = m
  }
}