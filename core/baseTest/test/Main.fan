using std
using reflect

class Main {
  static Void main() {
    o := Tx()
    t := o.typeof
    m := t.method("testMe")
    echo(m)
    m.callOn(o, null)
    echo(t)
  }
}


class Tx : Test {

  Void testMe() {
    h := "123"
    verifyEq(h, 123.toStr)
  }
}

