enum class Foo
{
  a(10),
  b(11),
  c(12)

  private new make(Int x) { this.x = x }

  const Int x
}