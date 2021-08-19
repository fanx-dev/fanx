class Foo
{
  Obj m00() { return [3] }    // ok
  Obj m01() { return [null] } // ok
  Obj m02() { return Num["x", 4ms, 6] }
  Obj m03() { return Num[null] }
  Obj m04() { return Int[][ [3], [3d] ] }
}