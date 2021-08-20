class A
{
  Int testA() { return x.a }
  This x() { return this }
  Int a() { return 'A' }
  virtual This o() { return this }
  This n() { return this }
}

class B : A
{
  Int testB1() { return x.b }
  Int testB2() { return x.y.b }
  Int testB3() { return o.b }
  This y() { return this }
  Int b() { return 'B' }
  override This o() { return this }
}

class C : B
{
  Int testC1() { return x.y.z.c }
  Int testC2() { return this.o.c }
  Int testC3(C p) { return p.y.x.o.c }
  C testC4(C p) { return p.x }
  Int testC5() { x.y; return 'X' }
  This z() { return this }
  Int c() { return 'C' }
}