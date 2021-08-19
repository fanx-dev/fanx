class Foo
{
// fields
Int f00
const Int f01 := 1
const static Int f02 := 2

// methods
Void m00() {}
Int? m01(List? list) { return null }
static Void m02(Obj x) {}
static Str[]? m03(Int a, Int b) { return null }

// closures
static Func c00() { return |->| {} }
Func c01() { return |->Int| { a := 3; return a; } }
Func c02() { return |->Obj| { return m01(null) } }
static Func c03() { a := 3; return |->Obj| { return a } }
static Func c04() { a := 3; m := |->Func| { return |->Obj| { return ++a } }; return m() }
Func c05() { a := 3; m := |->Func| { return |->Obj| { return this } }; return m() }
Func c06() { list := [0,1]; return |->Obj| { return m01(list) } }
}