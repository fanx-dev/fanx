class Foo
{
  Int a := 2
  {
    get { return &a != 2 ? &a : -1 }
    set { aset = it; &a = it }
  }
  Int aset := 0

  Int b := 6
}

class Bar
{
  static Int geta() { return Foo.make.a }
  static Foo seta() { foo := Foo.make; foo.a = 8; return foo }

  static Int getb() { return Foo.make.b }
  static Foo setb() { foo := Foo.make; foo.b = 99; return foo }

  static Int getc()  { return make.&c }
  static Int getca() { return make.c }
  static Bar setc()  { bar := make; bar.&c = 123; return bar }
  static Bar setca() { bar := make; bar.c = 321; return bar }

  Int c := 3
  {
    get { return &c != 3 ? &c : 5 }
    set { &c = it; ctrap = it }
  }
  Int ctrap := 0
}