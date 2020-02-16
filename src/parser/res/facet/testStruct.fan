facet class Foo
{
 const Int i
 const Str s := "foo"
 const Duration d := 5min
}
class Test
{
 Foo t1() { Foo() }
 Foo t2() { Foo {} }
 Foo t3() { Foo { i = 4 } }
 Foo t4() { Foo { s = "bar" } }
 Foo t5() { Foo { s = "baz"; d = 1day } }
}