class Bar : Foo, Goo
{
  Foo? a() { return null }
  protected Void b([Str:Foo] x) {}
  Foo? f
  protected Foo[]? g
  |Foo|? h
  |Str->Foo|? i
  internal Foo? ai(Foo x) { return null } // ok
  internal Foo? fi // ok
}

virtual internal class Foo {}
internal mixin Goo {}