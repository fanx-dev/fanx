class Foo
{
  Void m03() { bar := Bar(); bar.a |Str f| {} }
  Void m04() { bar := Bar(); bar.b |Str f| {} }
  Void m05() { bar := Bar(); bar.a |Bar f| {} } // ok
  Void m06() { bar := Bar(); bar.b |Bar f| {} } // ok
  Void m07() { bar := Bar(); bar.a(null) }
  Void m08() { bar := Bar(); bar.b(null) } // ok
  Void m09(|This| f) { Bar().a(f) }
  static Void m10(|This| f) { Bar().a(f) }
  Void m11(|Bar| f)  { Bar().a(f) } // ok
  Void m12(|Bar|? f) { Bar().a(f) } // ok
  Void m13(|Bar| f)  { Bar().b(f) } // ok
  Void m14(|Bar|? f) { Bar().b(f) } // ok
  Void m15() { bar := SubBar(); bar.a |Bar f| {} } // ok
  Void m16() { bar := SubBar(); bar.b |Bar f| {} } // ok
  Void m17() { bar := Bar(); bar.a |SubBar f| {} } // ok
  Void m18() { bar := Bar(); bar.b |SubBar f| {} } // ok
  Void m19() { bar := SubBar(); bar.a |Int f| {} }
  Void m20() { bar := SubBar(); bar.b |Int f| {} }
}

virtual class Bar
{
  Void a(|This| f) {}
  Void b(|This|? f) {}
}

class SubBar : Bar
{
}