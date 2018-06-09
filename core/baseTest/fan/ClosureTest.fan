
class ClosureTest
{
  static Int foo(|Int a, Int b->Int| f) {
    return f(1, 2) * 10
  }

  static Int test() {
    p := 10
    return foo |a| {
      return a + p
    }
  }

  static Void main() {
    echo(test)
  }
}


