class Foo
{
Void m03() { f0 |->| {} }   // ok
Void m04() { f0 |a| {} }
Void m05() { f1 |a| {} }   // ok
Void m06() { f1 |a,b| {} }
Void m07() { f2 |a,b| {} } // ok
Void m08() { f2 |a,b,c| {} }
Void m09() { f2 |a,b,c,d| {} }

Void f0(|->| f) {}
Void f1(|Str| f) {}
Void f2(|Str,Str| f) {}
}