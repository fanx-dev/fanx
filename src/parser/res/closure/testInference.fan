class Foo
{
Obj m03(Obj x, Obj y) { s := ""; f := |a, b| { s = "$a $b.toStr.size" }; f(x,y); return s }
Obj m04(Obj x, Obj y) { f := |a, b->Str| { "$a $b.hash" }; return f(x, y) }
Obj m05(Str[] x) { x.sort |a, b->Int| { a.size <=> b.size } }
Obj m06(Str[] x) { x.sortr |a, b| { a.size <=> b.size } }
Obj m07(Str[] x) { r := Obj[,]; x.each |s,i| { r.add(s).add(i) }; return r }
Obj m08(Str[] x) { return x.map |s,i| { i.toStr + s  } }
Obj m09(Str[] x) { return x.map |s,i->Str| { q := i.toStr; return q + s  } }
Obj m10(Str[] x)
{
  return x.sort |a,b|
  {
    if (a == "first") return -1
    if (b == "first") return +1
    return a <=> b
  }
}

Type m11() { foo { 4 } }
Type m12() { foo |a| { 4 } }
Type m13() { foo |a,b| { 4 } }
Type m14() { foo |Int a,b| { 4 } }
Type m15() { foo |a,Int b| { 4 } }
Type m16() { foo |a,b->Int| { 4 } }
Type m17() { foo |Int a,b->Int| { 4 } }
Type m18() { foo |Int a, Float b->Int| { 4 } }

Type foo(|Num,Num->Num| f) { Type.of(f) }
}