


class GenericType<T> {
  Str? s
  T? bar
  T? foo() { bar }

  GenericType self() { return this }

  Void say(|T|? f) {
    if (f != null) f(t)
  }

  GenericType<Int>? self2() { null }
}

class GenericTypeTest
{
  //GenericType<Str> x := GenericType<Str>()
  Str[] fs := ["a", "b"]

  Void main() {
    //Fix this
    x := GenericType<Str>()
    x.bar = "Hi"
    echo(x.bar.size)
    echo(fs.get(0).size)
  }
}

