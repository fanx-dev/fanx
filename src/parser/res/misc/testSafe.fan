class Foo
{
  Obj? test1() { return f(this)?.i(1) }
  Obj? test2() { return f(this)?.i(null) }
  Obj? test3() { return f(null)?.i(3) }
  Obj? test4() { return f(null)?.i(null) }

  Obj? test5() { return f(this)?.j(5) }
  Obj? test6() { return f(null)?.j(6) }
  Obj? test7() { last = null; f(this)?.j(7); return last }
  Obj? test8() { last = null; f(null)?.j(8); return last }

  Obj? test9()  { q = 9; return f(this)?.q }
  Obj? test10() { q = 10; return f(null)?.q }

  Foo? f(Foo? x) { return x }
  Int? i(Int? x) { return last = x }
  Int j(Int x) { return last = x }
  Int? last
  Int q
}