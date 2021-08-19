struct class Bar {
  Str x := "hi"
}

struct class Bar2 {
  readonly Str x := "hi"
  new make(|This|? f := null) { f?.call(this) }
}

class Main {
  Void main() {
    b2 := Bar2 { x = "" }
    echo(b2)
  }
}