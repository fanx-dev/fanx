
class BoxingTest
{
  static Int foo(Int a, Int? b) {
     Int? c := a + b
     Int d := b + a
     Str str := a.toStr
     Str str2 := b.toStr
     Obj obj := d
     return obj
  }

  static Void main() {
    echo(2)
    echo(foo(1, 2))
  }
}


