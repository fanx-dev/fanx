

virtual class VCBase {
  //internal Str foo1() { "Hi1" }
  private  Str foo2() { "Hi2" }
}

class VCSub : VCBase {
  internal Str foo1() { "Hello1" }
  //private  Str foo2() { "Hello2" }

  static Void main() {
    VCBase s := VCSub()
    r := s->foo
    echo(r)
  }
}

