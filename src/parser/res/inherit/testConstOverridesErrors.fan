class Foo : A
{
  override const Str a { get { return 5 } }
  override const Str b { set {} }
  override const Str c { get { return 5 } set { &c = 6 } }
}

class A
{
  virtual Int a
  virtual Int b
  virtual Int c
}