virtual class A
{
 new make(Int x) { this.x = x }
 Int x
 A? f
 @Operator A plus(A that) { this.typeof.make([x + that.x]) }
 @Operator This mult(A that) { (A)this.typeof.make([x * that.x]) }
 @Operator A minus(A that) { (A)this.typeof.make([x - that.x]) }

 Obj t0() { x := A(2); x += A(3); return x }
 Obj t1() { x := A(2); x += B(4); return x }
 Obj t2() { x := B(2); x += A(5); return x }
 Obj t3() { x := B(2); x += B(6); return x }

 Obj t4() { f = A(2); f *= A(3); return f }
 Obj t5() { f = A(2); f *= B(4); return f }
 Obj t6() { f = B(2); f *= A(5); return f }
 Obj t7() { f = B(2); f *= B(6); return f }

 Obj t8() { a := [A(2)]; a[0] -= A(3); return a.first }
 Obj t9() { a := [A(2)]; a[0] -= B(4); return a.first }
 Obj tA() { a := [B(2)]; a[0] -= A(5); return a.first }
 Obj tB() { a := [B(2)]; a[0] -= B(6); return a.first }
}

class B : A { new make(Int i) : super(i) {} }