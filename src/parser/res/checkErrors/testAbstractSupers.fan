class Foo : Base, A
{
  override Int x { get { return super.x } set { A.super.x = it } }
  override Void n() { super.n }
  override Void m() { A.super.m() }
}

abstract class Base
{
  abstract Int x
  abstract Void n()
}

mixin A
{
  abstract Int x
  abstract Void m()
}