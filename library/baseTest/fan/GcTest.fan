

class GcNode {
  Int i := 0
  GcNode? next
}

class GcTest
{
  Int t := 0
  GcNode? root

  Void doST() {
    sum := 0
    for (i := 0; i<100;++i) {
      sum += i;
    }
  }

  Void test2() {
    root = GcNode()
    echo("======root:$root")
    GcNode cur := root
    for (i := 0; i<100000; ++i) {
      m := GcNode()
      m.i = i
      cur.next = m
      cur = m
      doST
    }
  }

  Void test1() {
    GcNode? cur := GcNode()
    for (i := 0; i<100000; ++i) {
      m := GcNode()
      m.i = i
      cur.next = m
      cur = m
      doST
    }
  }

  Void main() {
    echo("======run1")
    test1
    Env.cur.gc
    echo("======run2")
    test2
    Env.cur.gc
    echo("======end:$root.next")
  }
}


