class Tester
{
  Obj t00() { Foo("a") }
  Obj t01() { Foo("a", true) }
  Obj t02() { Foo("a", 3) }
  Obj t03() { Foo("a", true, 3) } // ok
  Obj t04() { Foo() }
  Obj t05() { Foo(4f) }
}
class Foo
{
  new make1(Str x) {}
  new make2(Str x, Bool y := true) {}
  static new make3(Str x, Bool y, Int z := 3) {}
  private new make4(Str x) {}
}