mixin Mixin
{
  static Int mgeta() { return s }
  //static Int mgets() { return &s } not allowed

  static const Int s := 5
  static const Int? x
  abstract Int a
}

class Foo : Mixin
{
  Int geta() { return a }
  Int gets() { return &a }

  override Int a { get { return s } }
}