class Foo
{
  static Void baz(Int[] x) { x[0] += 3 }
  static Int wow(Int[] x) { return ++x[0] }
  static Int wee(Int[] x) { return x[0]++ }

  Int[] f := [99, 2]
  Void fbaz() { f[1] += 3 }
  Int fwow() { return ++f[1] }
  Int fwee() { return f[1]++ }
}