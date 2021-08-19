class Foo
{
Int x() { return 1972 }
Int xc1() { return |->Int| { return x }.call }
Int xc2() { return |->Int| { return this.x }.call }

static Int y() { return 72 }
Int yc1() { return |->Int| { return y }.call }
Int yc2() { return |->Int| { return Foo.y }.call }

Int f := 66
Int fc1() { return |->Int| { return f }.call }
Int fc2() { return |->Int| { return this.f }.call }
}