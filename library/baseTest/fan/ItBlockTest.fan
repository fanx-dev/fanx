
class ItBlockTest {
  Void foo1(|->| f) { f() }
  Void foo2(|->Str| f) { Str s := f(); echo(s) }
  Void foo3(|Int->Void| f) { f(1) }
  Void foo4(|Int->Str| f) { Str s := f(0); echo(s) }

  Void main() {
    foo1 { echo("H1") }
    foo2 { "H2" }
    foo2 { lret "H22" }
    foo3 { echo("H3"+it) }
    foo4 { lret "H3" }
  }
}