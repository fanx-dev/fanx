class Foo
{
  Void func()
  {
    x?.i = 5
    x?.x.i = 5
    x?.x?.i = 5
    y()?.i = 5
    x?.i += 5
    nn?.y
    temp := nn?.i
    foo1 := x ?: 5 // ok
    foo2 := nn ?: 5 // not-ok
    int1 := 5; int2 := int1 ?: 7
  }

  static Foo someFoo() { throw Err() }

  Foo? y() { return this }
  Foo? get(Int x) { return null }
  Void set(Int x, Int y) {}
  Foo? x
  Foo nn := someFoo()
  Int i
}