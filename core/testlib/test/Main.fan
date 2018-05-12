

mixin Mix {
  static Void foo() {}
}

class Base {
  static Void foo() {}
}

class Main : Base, Mix {
  //static Void foo() {
  //}

  static Void main() {
    //m := Main()
    Mix.foo()
  }
}


