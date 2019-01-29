

class Whatever {
  extension static Str foo(Str str) {
    return str + "?"
  }
}

class ExtensionTest {
  Void main() {
    str := ">A>B>C>"
    fs := str.foo()
    fs2 := Whatever.foo(str)

    echo("$fs == $fs2")
  }
}