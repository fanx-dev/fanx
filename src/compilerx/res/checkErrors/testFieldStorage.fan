class Foo : Root
{
  Int m00() { return &r00 }
  Int m01() { return this.&r00 }

  Int f00 { get { return f00 } }
  Int f01 { set { f01 = it } }
  Int f02 { get { return f02 } set { f02 = it } }
  Int f03 { get { return f02 } set { this.f02 = it } }
  Int f04 { set { child.f04 = it } } // ok

  override Int r01 { set { &r01 = it } }
  Foo? child
}

mixin M
{
  abstract Int x
  Void foo() { &x = 2 }
  Int bar() { &x }
}

class Root
{
  Int r00
  virtual Int r01
}