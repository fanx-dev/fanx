class Foo
{
  Str a(Int x) { v := x.isOdd ? x + 100 : throw ArgErr(); return v.toHex }
  Str b(Int x) { v := x.isOdd ? throw ArgErr() : x + 100; return v.toHex }
  Str c(Int x) { x.isOdd ? throw ReadonlyErr() : throw IOErr() }
  //Str d(Str x) { v := Int.fromStr(x, 10, false) ?: throw IOErr(); return v.toHex }
}