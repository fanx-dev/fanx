

class Bar<T> {
  T? t
  Void say(|T|? f) {
    if (f != null) f(t)
  }

  Bar<Int>? self() { null }
}

class Main {
  static Void main() {
    //Str[] t := Str["a", "b", "c"]
    //echo(t[0].size)
    //t.each |x|{ echo(x.size) }
    //b := Bar<Str>()
    //s := b.self
    //s.t = "hi"
    //echo(s.t.size)
    //b.say |x| { echo(x.size) }
    b := Bar<Str>()
    b.t = "hi"
    echo(b.t.size)
  }
}


