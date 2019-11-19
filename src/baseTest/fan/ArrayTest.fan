
class ArrayTest {  
  
  static Void testStr() {
    x := Array<Str>(2)

    x[0] = "a"
    t := x[0]

    echo(t)

    s := x.size
    echo(s)
  }

  static Void testInt() {
    x := Array<Int>(2)

    x[0] = 1
    t := x[0]

    echo(t)

    s := x.size
    echo(s)
  }
}