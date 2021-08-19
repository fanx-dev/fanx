class Foo
{
  Func funcField := Foo#.method("m4").func

  static Int nine() { return 9 }
  static Func nineFunc() {  return Foo#.method("nine").func }

  static Int m1(Int a) { return a }
  static Int m4(Int a, Int b, Int c, Int d) { return d }
  static Int m8(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h) { return h }

  Int i1(Int a) { return a }
  Int i4(Int a, Int b, Int c, Int d) { return d }
  Int i7(Int a, Int b, Int c, Int d, Int e, Int f, Int g) { return g }

  static Int callClosure(|->Int| c) { return c() }

  static Obj a()
  {
    m := Foo#.method("nine").func
    return m()
  }

  static Obj b()
  {
    m := |->Int| { return 69 }
    return m()
  }

  static Obj c(Int a, Int b)
  {
    m := |Int x, Int y->Int| { return x + y }
    return m(a, b)
  }

  static Obj d() { return Foo#.method("nine").func()() }

  static Obj e() { return ((Func)Foo#.method("nineFunc").func()())() }

  static Int f()
  {
    m := (|-> |->Int| |)Foo#.method("nineFunc").func
    return m()()
  }

  static Obj g() { return Foo#.method("m1").func()(7) }
  static Obj h() { return Foo#.method("m4").func()(10, 11, 12, 13) }
  static Obj i() { return Foo#.method("m8").func()(1, 2, 3, 4, 5, 6, 7, 8) }

  Obj j() { return Foo#.method("i1").func()(this, 6) }
  Obj k() { return Foo#.method("i4").func()(this, 101, 111, 121, 131) }
  Obj l() { return Foo#.method("i7").func()(this, -1, -2, -3, -4, -5, -6, -7) }

  Int m(Int p)
  {
    list := [ (|Int a->Int|) Type.of(this).method("m1").func() ]
    return list[0](p)
  }

  Obj o(Int p)
  {
    return (funcField)(0, 1, 2, p)
  }

  Obj q(Int p)
  {
    return Foo#.method("callClosure").func()() |->Int| { return p }
  }
}