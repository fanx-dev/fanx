mixin M
{
  Str i() { return priI + " " + intI  }
  static Str s() { return priS + " " + intS }
  private Str priI() { return "private instance" }
  private Str intI() { return "internal instance" }
  private static Str priS() { return "private static" }
  private static Str intS() { return "internal static" }
}

class Foo : M {}