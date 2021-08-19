class Foo
{
 static Num a(Num a, Num b, |Num a, Num b->Num| f) { return f(a, b) }
 // diff return types
 static Int a01() { return a(1,5) |Num a, Num b->Num?| { return a.toInt+b.toInt } }
 static Int a02() { return a(1,6) |Num a, Num b->Int|  { return a.toInt+b.toInt } }
 static Int a03() { return a(1,7) |Num a, Num b->Obj?| { return a.toInt+b.toInt } }
 // diff parameter types
 static Int a04() { return a(1,9)  |Int a, Num b->Int|  { return a+b.toInt } }
 static Int a05() { return a(1,10) |Num a, Int b->Obj|  { return a.toInt+b } }
 static Int a06() { return a(1,11) |Int? a, Int b->Num| { return a+b } }
 static Int a07() { return a(1,12) |Obj a, Obj? b->Obj| { return (Int)a + (Int)b } }
 // diff arity
 static Int a08() { return a(14,1) |Num? a->Int| { return a.toInt*2 } }
 static Int a09() { return a(15,1) |Int a->Int| { return a*2 } }
 static Int a10() { return a(16,1) |Obj a->Int| { return (Int)a*2 } }
}