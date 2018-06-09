
class CmpTest
{
  static Void check(Bool b) {
    echo("$b")
  }

  static Void testCmp() {
    Obj o := 1
    Obj o2 := 5
    Int i := 2
    Int j := 3
    Int? k := 4

    check((o <=> i) > 0)
    check((j <=> i) > 0)
    check((j <=> k) > 0)
    check((o <=> k) > 0)

    check(o < i)
    check(j > i)
    check(j < k)
    check(o < k)

    check(o > i)
    check(j < i)
    check(j > k)
    check(o > k)

    check(o <= i)
    check(j >= i)
    check(j <= k)
    check(o <= k)

    check(o == i)
    check(j == i)
    check(j == k)
    check(o == k)

    check(o === o2)
    check(o !== o2)

    check(o != i)
    check(j != i)
    check(j != k)
    check(o != k)

    check(k == null)
  }

  static Void testCmp2() {
    Obj o := 1
    Obj o2 := 5
    Int i := 2
    Int j := 3
    Int? k := 4

    check(o < i)
    check(j < k)
    check(o <= i)
    check(j <= k)
    check(o != i)
    check(j != k)
  }

  static Void main() {
    testCmp2
  }
}


