mixin MixIt
{
  Str a
  virtual Int b
  abstract Int c { get { return &c } }
  abstract Int d { set { &d = it } }
  abstract Int e { get { return &e } set { &e = it } }
  const Int f := 3
  abstract Int g := 5
}

abstract class Foo
{
  abstract Int c { get { return &c } }
  abstract Int d { set { &d = it } }
  abstract Int e { get { return &e } set { &e = it } }
  abstract Int f := 3
}