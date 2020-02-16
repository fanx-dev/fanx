class Foo
{
  static Str testAc() { return c("1234567890").z }
  static Str testBc() { return c("1234567890", 255).z }
  static Str testCc() { return c("1234567890", 255, "foo").z }

  static Str testAi() { return make.i("1234567890") }
  static Str testBi() { return make.i("1234567890", 255) }
  static Str testCi() { return make.i("1234567890", 255, "foo") }

  static Str testAs() { return s("1234567890") }
  static Str testBs() { return s("1234567890", 255) }
  static Str testCs() { return s("1234567890", 255, "foo") }

  new c(Str a, Int b := a.size, Str c := b.toHex) { z = [a, b, c].join(",") }
  Str i(Str a, Int b := a.size, Str c := b.toHex) { [a, b, c].join(",") }
  static Str s(Str a, Int b := a.size, Str c := b.toHex) { [a, b, c].join(",") }

  new make() {}
  Str? z
}