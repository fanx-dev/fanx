enum class Foo
{
  a, b, c

  const static Str[] caps
  static
  {
    // verify vals are initialized first
    caps = vals.map |Foo x->Str| { x.name.upper }
  }
}