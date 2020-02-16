class Foo
{
  Void x(Int i, Str s, Obj o)
  {
    true;               // 5
    3;                  // 6
    i + 2;              // 7
    f;                  // 8
    this.f;             // 9
    (Int)o;             // 10
    o is Int;           // 11
    o as Int;           // 12
    i == 4 ? 0ms : 1ms; // 13
    |->| {}             // 14
    i == 2;             // 15
    s === o;            // 16
    Foo()               // 17
    Foo() {}            // 18
    Foo {}              // 19
  }

  Int f
}