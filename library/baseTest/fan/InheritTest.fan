
class Base {
  Int i
  new make(Int x) {
    i = x
  }

  virtual Str say(Str name) { "hi $name" }
}

mixin Bar {
  virtual Str foo() { "bar" }
}

class Sub : Base, Bar {
  Int j
  new make(Int j) : super(0) {
    this.j = j
  }

  override Str say(Str name) { "hello $name" }

  override Str foo() { "sub" }

  static Void main() {
    m := Sub(1)

    Base base := m
    echo(base.say("Q"))

    Bar bar := m
    echo(bar.foo)
  }
}