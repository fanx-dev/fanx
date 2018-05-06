

const struct class Point {
  const Int x
  const Int y

  new make(|This| f) { f(this) }
}

class StructTest {
  Void main() {
    p := Point{x=1; y=2}
    echo("$p.x")
  }
}

