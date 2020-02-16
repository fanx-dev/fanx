class Foo : Test
{
  static Str x(Int[] a, [Int:Str] b, |Int x| c) { return a.toStr }
  Obj testIt() { Type.of(this).method("x").call([1, 2, 3], [4:4.toStr], |Int x| {}) }
}