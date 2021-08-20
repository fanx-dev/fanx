class Foo
 {
   Int call(Int a, Int b) { a + b }
   Void test1(Foo f) { f(2, 3) }
   Void test2(Foo f) { this(2, 3) }
   Void test3()      { Foo()(2, 3) }
 }