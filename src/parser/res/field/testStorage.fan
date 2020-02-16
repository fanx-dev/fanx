class Foo
{
  // storage
  Int a
  Int b := 99
  Int c { get { return &c } }
  Int d { set { &d = it } }
  Int e { get { return &e } set { &e = it } }
  Int f { get { return 2 } }
  Int g { set { } }
  Int h { get { return 777 } set {} }
  Void hs() { &h = 2 }

  // no storage
  Int o { get { return 2 } set {} }
  Int p { get { return a } set { a = it } }
  Int q { get { return x } set { x = it } }

  Bar bar := Bar.make
  Int x { get { return bar.x } set { bar.x = it } }
}

class Bar
{
  Int x := 77
}

abstract class Goo
{
  virtual Int abc
  abstract Int xyz
}