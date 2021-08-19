class A {
  new make(|This| f) { f(this) }
  Int p
  private Int x
}

class B
{
  Int x := 99
  Obj t0() { A { p = x } }
  Obj t1(Int x) { A { p = x } }
}