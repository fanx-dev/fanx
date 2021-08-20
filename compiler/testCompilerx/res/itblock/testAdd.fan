class Acme
{
  Obj a() { return Foo { it.a=2 } }
  Obj b() { return Foo { 5, } }
  Obj c() { return Foo { 5, 7 } }
  Obj d() { return Foo { it.a=33; 5, 7; it.b=44; 9,12, } }
  Obj e() { return Widget { foo.b = 99 } }
  Obj f() { return Widget { Widget{name="a"}, } }
  Obj g() { return Widget { Widget.make {name="a"}, } }
  Obj h() { return Widget { $podName::Widget{name="a"}, } }
  Obj i() { return Widget { $podName::Widget.make {name="a"}, } }
  Obj j() { return Widget { kid1, } }
  Obj k() { return Widget { kid2, } }
  Obj l() { return Widget { Foo.kid3, } }
  Obj m()
  {
    return Widget
    {
      name = "root"
      Widget
      {
        kid1 { name = "a.1" },;
        name = "a"
        Widget.make { name = "a.2" },
      },
      $podName::Widget
      {
        name = "b"
        Widget { name = "b.1" },;
        foo.a = 999
      }
    }
  }

  static Widget kid1() { return Widget{name="a"} }
  Widget kid2() { return Widget{name="a"} }
}

class Foo
{
  @Operator This add(Int i) { list.add(i); return this }
  Int a := 'a'
  Int b := 'b'
  Int[] list := Int[,]
  static Widget kid3() { return Widget{name="a"} }
}

class Widget
{
  @Operator This add(Widget w) { kids.add(w); return this }
  Str? name
  Widget[] kids := Widget[,]
  Foo foo := Foo { a = 11; b = 22 }
}