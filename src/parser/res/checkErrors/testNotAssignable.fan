class Foo
{

Void m00(Int a) { 3 = a }
Void m01(Int a) { 3 += a }
Void m02(Int a) { i = a }
Void m03(Int a) { i += a }
Void m04(Int a) { i++ }
Void m05(Foo a) { this = a }
//Void m06(Foo a) { super = a }
Void m07(Foo a) { this += a }
Void m08(Foo a) { this++ }

Int i() { return 3 }
@Operator Foo plus(Foo a) { return this }
@Operator Int plusInt(Int x) { x }
@Operator Int increment() { 3 }
}