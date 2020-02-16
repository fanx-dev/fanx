@A
@B { x = 77 }
class Foo
{
 @sys::Transient @C { y = "foo"; z = [1, 2, 3] }
 Int f
}

facet class A {}
facet class B { const Int x; const Int y }
facet class C { const Str x := "x"; const Str y := "y"; const Int[]? z }