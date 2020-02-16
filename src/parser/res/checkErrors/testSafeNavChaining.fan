class Foo
{
  Void func(Str? x)
  {
    x?.size.toHex
    x?.size->toHex
    x?->size.toStr
    x?->size->toStr
    x?.size?.toHex   // ok
    x?.size?.toHex.hash
    x?.size?.toHex?.hash.toStr.size
    y := foo?.foo.foo
    foo?.foo.toStr

    Uri? uri := null
    echo(uri?.query["x"])
  }
  Foo? foo
  Uri? list
}