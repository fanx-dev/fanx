virtual class Foo
{
  Foo b(Str s) { return Bar(s) }
  Foo? fromStr(Str s) { return null }
}

class Bar : Foo
{
  new make(Str s) { this.s = s}
  Str s
}