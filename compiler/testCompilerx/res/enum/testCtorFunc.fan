enum class Foo
{
  a(|Int i->Int| { i+1 }),
  b(|Int i->Int| { i+2 }),
  c(|Int i->Int| { i+3 })

  private new make(|Int->Int| f) { this.f = f; this.x = f(ordinal) }

  Int call(Int x) { f(x) }

  const Int x
  const |Int->Int| f
}