class Foo {
static Str[] list() { ["a", "b"] }
static Obj test() {
  acc := Str[,]
  list.each |i|
  {
    list.each |j|
    {
      list.each |k|
      {
        i = "($i)"
        acc.add("$i $j $k")
      }
      j = "($j)"
    }
  }
  return acc
} }