class Foo
{
  Str test(List list)
  {
    list.join(",") |item| { item->toHex }
  }
}