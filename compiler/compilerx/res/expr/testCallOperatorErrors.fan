class Foo
{
  static Void a(Str x) { x() }
  static Void b() { Str x; x() }
  static Void c() { x := 44; x() }
  static Void d()
  {
    //m := |Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int j| {}
    //m(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
  }

  static Void m9(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int j) {}
}