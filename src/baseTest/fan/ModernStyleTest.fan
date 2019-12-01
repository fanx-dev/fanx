

class ModernStyle {
  var age: Int
  let name: Str

  new make(n: Str) {
    name = n
  }

  fun foo() : Str {
    return name
  }

  static fun main() {
    p : ModernStyle = ModernStyle("pick")
    s := p.foo
    echo(s)
  }
}

