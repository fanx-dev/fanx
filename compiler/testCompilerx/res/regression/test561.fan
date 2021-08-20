class Foo
{
  Func f() { return |Int i->Str| { i.toStr } }
  Func g() { return |Int i->Str| { i.toStr } }

  Str a(Func f) { return f.call(36) }
  Str b(|Int i->Str| f) { return f(36) }

  Obj test0() { a(f) }
  Obj test1() { a(g) }
  Obj test2() { b(f) }
  Obj test3() { b(g) }
}