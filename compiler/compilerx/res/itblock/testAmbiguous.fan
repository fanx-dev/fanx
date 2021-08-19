class Foo
{
// instance methods
Obj m04() { Foo { x } }
Obj m05() { Bar { x } }
// instance fields
Obj m07() { Foo { y = 3 } }
Obj m08() { Bar { y = 3 } }
// static methods
Obj m10() { Foo { s } }  // ok
Obj m11() { Bar { s } }
// static fields
Obj m13() { Foo { it.y = t } }  // ok
Obj m14() { Bar { it.y = t } }
// instance in static context
static Obj m16() { Foo { echo(y) } }  // ok
static Obj m17() { Bar { echo(t) } }
static Obj m18() { Bar { echo(u) } }
Obj m19() { Bar { echo(u) } }

Void x() {}
Int y
static Void s() {}
static const Int t := 8
static const Int u := 9  // static here, instance Bar
}

class Bar
{
Void x() {}
Int y
static Void s() {}
static const Int t := 8
const Int u := 9        // static Foo, instance here
}