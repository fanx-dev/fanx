class Foo
{
 @Operator Int plu03() { 5 }
 @Operator Void plusFoo(Int x) { }
 @Operator Foo negate(Int x) { this }
 @Operator Int plus06() { 5 }
 @Operator Int minus07(Int x, Int y) { 5 }
 @Operator Foo get08() { this }
 @Operator Void set(Int x) { }
 @Operator Void setFoo(Int x, Int y) { }
 @Operator Int get11(Int x, Int y := 0) { y } // ok
 @Operator Foo add(Obj x) { this }
}