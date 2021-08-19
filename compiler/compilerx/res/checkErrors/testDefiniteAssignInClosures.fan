class Foo
{
  new make(Bool c) { f := |->| { x = "ok" }; if (c) f(); }
  Str x
}