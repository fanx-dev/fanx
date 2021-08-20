class RecImpl : Rec
{
  override Str foo() { return "foo" }
  override Str baz() { return "baz 2" }
}

class SubRecImpl : RecImpl, SubRec
{
  override Str bar() { return "bar" }
  override Str baz() { return "baz 3" }
}

mixin Rec
{
  abstract Str foo()
  abstract Str baz()
}

mixin SubRec : Rec
{
  abstract Str bar()
  override Str baz() { return "baz 1" }
  Str goo() { return "goo" }
}


class Derived : SubRecImpl {}