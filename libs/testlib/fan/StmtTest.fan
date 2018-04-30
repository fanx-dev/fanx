
class StmtTest
{
  static Int testVar(Int s) {
    b := 0
    if (s > 2) {
      a := 10
      b = a * b
    } else {
      a := "11"
      b = a.size * b
    }
    return b
  }

  static Void testCmp(Obj l) {
    Obj r := "hi"
    if (r == l) {
      echo(1)
    }
    if (r === l) {
      echo(2)
    }
    if (r > l) {
      echo(3)
    }
  }

  static Void testExpr(Int a) {
    i := a + 2 * (a>0?3:4)
    echo("" + i)
  }

  static Void testFor() {
    Int a := 0
    Int sum := 0
    for (i := a; i < 1000000; ++i) {
      sum += i
    }
    echo(sum)
  }

  static Void testBranch() {
    Str s := "Hello"
    if (s.size > 0) {
      echo(s)
    } else {
      echo("empty")
    }
  }

  static Void main() {
    testExpr(1)
    testBranch
    testFor
  }
}


