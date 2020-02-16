class Foo
{
Int a() { 7 }
Int b(Bool b) { b ? 2 : 3 }
Str[] c(Str[] x) { x.sort |Str a,Str b->Int| { a.size <=> b.size } }
Void v0() { return vi0 }
Void v1() { vi1 }
Void vi0() { n++ }
Int vi1() { n++; return n }
Int n := 0
}