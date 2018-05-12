
mixin SMix {
  static Void foo() {}
}

class SBase {
  static Void foo() {}
}

class StaticTest : SBase, SMix {
  //static Void foo() {
  //}

  static Void main() {
    //m := Main()
    Mix.foo()
  }
}

