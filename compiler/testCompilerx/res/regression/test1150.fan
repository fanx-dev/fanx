class Foo {
   Void foo(Int x) { }
   Int test1(Int x)
   {
     foo(x)
     ++x
     return x
   }
 }