class Foo
{
Void m00(This x) {}
Void m01(Void x) {}
Void m02() { This? x := null }
Void m03() { Void? x := null }
static This m04() { return Foo.make }
This m05() { return 3 }
This? m06() { return this }
This m07() { return null }
}