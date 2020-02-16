class Base
{
  virtual Int x() { return 3 }
}

class Foo : Base
{
  override Int x() { return 4 }
  static Int  a() { return |->Int| { return this.x }.call }
  static Void b() { |->| { |->| { this.x } }.call }
  Int  c() { return |->Int| { return super.x }.call }
  Void d() { |->| { |->| { super.x } }.call }
}