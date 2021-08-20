class A
{
|->Int| f0 := |->Int| { 99 }
|Int a->Int| f1 := |Int a->Int| { a }
|Int a, Int b->Int| f2 := |Int a, Int b->Int| { a + b }
A ref := this

Int m00() { f0() }
Int m01() { this.f0() }
Int m02() { f1(2) }
Int m03() { this.f1(3) }
Int m04() { x := this; return x.f1(4) }
Int m05() { ref.f2(2, 3) }
Int m06() { this.ref.f2(2, 4) }
Int m07() { x := this; return x.ref.f2(3, 4) }
}