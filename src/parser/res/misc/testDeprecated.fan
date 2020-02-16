class Foo
{
  Obj? m01() { oldf }
  Obj? m02() { oldm }
  Obj? m03() { Old.m }
  Obj? m04() { Old() }

  @Deprecated Obj? oldf
  @Deprecated { msg = "dont use!" } Obj? oldm() { null }
}

@Deprecated { msg = "hum bug" }
class Old
{
  static Obj? m() { null }
}