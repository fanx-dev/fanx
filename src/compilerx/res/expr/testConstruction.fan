class Tester
{
  Str t00() { Foo("a").toStr }
  Str t01() { Foo("a", "b").toStr }
  Str t02() { Foo(9).toStr }
  Str t03() { M("x").toStr }
  Str t04() { M("x", "y").toStr }
}
class Foo : M
{
  new make1(Str x) { toStr = x }
  new make2(Str x, Str y) { toStr = x + "," + y }
  static new make3(Int x)  { make1("Int " + x) }
  const override Str toStr
}
mixin M
{
  static new make1(Str x) { Foo(x) }
  static new make2(Str x, Str y) { Foo(x, y) }
}