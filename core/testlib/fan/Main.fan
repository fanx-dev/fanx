
class Main {
  static Void main() {
    Str[] t := Str["a", "b", "c"]
    //echo(t[0].size)
    t.each |x|{ echo(x.size) }
  }
}


