class Foo
{
  static Int f()
  {
    Int x := 7
    Int echo := 10
    3.times |Int i| {}
    return |->Int| { return x+echo }.call
  }
}