
mixin SMix {
  static Void foo() {}
}

virtual class SBase {
  static Void foo() {}
}

class StaticTest : SBase, SMix {
  //static Void foo() {
  //}

  static Void main() {
    //m := Main()
    SMix.foo()
  }
}

