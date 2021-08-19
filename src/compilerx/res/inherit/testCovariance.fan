mixin Q
{
  virtual Q? m() { return null }
  virtual Q? n() { return null }

  virtual Obj[] e() { return [2ms, 3] }
  virtual Num[] f() { return [2, 3f] }
}

mixin P : Q
{
  override P? n() { return this }
  override Int[] f() { return [2, 3] }
}

class A
{
  virtual A? x() { return null }
}

mixin M
{
  virtual M? y() { return null }
}

class B : A, M, P
{
  override B? x() { return this }
  static A? xA(A a) { return a.x }
  static B xB(B b) { return b.x }

  override B? y() { return this }
  static M? yM(M a) { return a.y }
  static B yB(B b) { return b.y }

  override B? m() { return this }
  static Q? mQ(Q q) { return q.m }
  static B mB(B b) { return b.m }

  override B? n() { return this }
  static Q? nQ(Q q) { return q.n }
  static P nP(P p) { return p.n }
  static B nB(B b) { return b.n }

  override Str[] e() { return [\"hello\"] }
  static Obj[] eQ(Q q) { return q.e }
  static Str[] eB(B b) { return b.e }

  static Num[] fQ(Q q) { return q.f }
  static Int[] fP(P p) { return p.f }
  static Int[] fB(B b) { return b.f }
}