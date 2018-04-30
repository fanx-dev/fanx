

/*
class GenericType<T> {
  Str? s
  T? bar
  T? foo() { bar }

  GenericType self() { return this }
}

class GenericTypeTest
{
  //GenericType<Str> x := GenericType<Str>()
  Str[] fs := ["a", "b"]

  Void main() {
    //Fix this
    //x := GenericType<Str>()
    //x.bar = "Hi"
    //echo(x.bar.size)
    //x := fs[0]
    echo(fs.get(0).size)
  }
}
*/