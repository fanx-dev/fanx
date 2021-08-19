class Foo
{
  Void a(Str? x := null) { }
  Void b(Int[] y := Int[,] , Str z := "hi\n") {}
  Void c(Int x := 7, Int y := x-x , Int z := - y) {}
  Void d(Str? x := mi(), Str? y := ms(5)) {}

  Str? mi() { return null }
  static Str? ms(Int i) { return null }
}