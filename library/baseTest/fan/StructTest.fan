

const struct class SPoint {
  const Int x
  const Int y

  //new make(|This| f) { f(this) }
  new make(Int x, Int y) {
  	this.x = x
  	this.y = y
  }
}

class StructTest {
  Void main() {
    //p := SPoint{x=1; y=2}
    p := SPoint(1, 2)
    echo("$p.x")
  }
}

