class Bar<V> {
  const V a
  V b

  new make(V x) {
    a = x
    b = x
  }

  V get(V d) { d }
}

class Main {
  Void main() {

    bar := Bar<Int>(1)
    bar.b = 1
    Int x := bar.a
    Int y := bar.get(1)
    Int z := bar.b
    assert(x == y)
    assert(y == z)
  }
}