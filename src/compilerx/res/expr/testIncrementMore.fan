class Foo
{
Int f() { return a += b++ }
Int g() { return a += ++b }
Void h() { 3.times |->| { a = (b++) } }
Int i() { return a += b++ + (c++).toInt }
Void j() { x := 2; a = |->Int| { return x++ }.call; b = x } // cvar field

Int a := 2
Int b := 3
Float c := 4f
}