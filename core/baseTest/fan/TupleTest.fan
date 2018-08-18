
class TupleTest {
  Void main() {
    t := Tuple<Str,Int>("Hi", 1)
    echo(t.first.size)
    echo(t.second.isOdd)
  }
}