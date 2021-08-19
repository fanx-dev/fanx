class Foo
{
  Void a(|Int a, Str b| f) {}
  Void b(|Int a, Str| f) {}
  Void c(|Int, Str a| f) {}
  Void d(|Int, Str| f) {}
  Void e(|Duration| f) {}
  Void f(|Duration->Int| f) {}
  Void x() { a |Int x, Str y| { } }
}