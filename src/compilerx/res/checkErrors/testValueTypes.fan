class Foo
{
  Int m00() { return (Int)(Obj)5ms } // ok - runtime failure
  Float? m01() { return (Float?)(Obj)5ms } // ok - runtime failure
  Bool m02() { return m00 === 0  }
  Bool m03() { return 2f !== m01  }
}