

class GcNode {
  Int i := 0
  GcNode? next
}

class GcTest
{
  Int t := 0

  static Void test1() {
    GcNode? root := GcNode()
    GcNode cur := root
    for (i := 0; i<10000; ++i) {
      m := GcNode()
      m.i = i
      cur.next = m
      cur = m
    }
  }

  static Void test2() {
    GcNode? cur := GcNode()
    for (i := 0; i<10000; ++i) {
      m := GcNode()
      m.i = i
      cur.next = m
      cur = m
    }
  }

  static Void main() {
    test1
    test2
  }
}


