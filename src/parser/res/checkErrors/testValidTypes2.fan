class Foo
{
 Void[]? m03() { throw Err() }
 |This| m04() { throw Err() }
 Void m05(Void a) { }
 Void m06(This a) { }
 Void m07(Void? a) { }
 Void m08(This? a) { }
 Void m09(|->This|? a) {}
 Str m10() { Void? x; return x.toStr }
 Str m11() { This? x; return x.toStr }
 Str m12() { Void[]? x; return x.toStr }
 Str m13() { |This|? x; return x.toStr }
}