class Foo
{
  const Int[]? a
  const Int[]? b := null
  const Int[] c := [2,3]
  const Int[]? d := wrap(null)
  const Int[] e := wrap([4])
  const Int[]? f
  const Int[] g

  const [Int:Str]? h := null
  const [Int:Str]? i := map(null)
  const [Int:Str] j := map(c)
  const [Int:Str] k := map(c)

  const Type? l := null
  const Type m := Str#
  const Type? n
  const Type o

  const Buf p := "abc".toBuf
  const Buf q := Buf()

  new make(|Foo|? x := null)
  {
    f = wrap(null)
    g = wrap([5,6])
    k = map(g)
    n = thru(null)
    o = thru(Bool#)
    if (x != null) x(this)
  }

  Foo withIt()
  {
    return make
    {
      it.f = Foo.wrap(null)
      it.g = Foo.wrap([5,6])
      it.k = Foo.map(this.g)
      it.n = Foo.thru(null)
      it.o = Foo.thru(Bool#)
    }
  }

  static Int[]? wrap(Int[]? x) { return x }
  static Type? thru(Type? t) { return t }

  static [Int:Str]? map(Int[]? x)
  {
    if (x == null) return null
    m := Int:Str[:]
    x.each |Int i| { m[i] = i.toStr }
    return m
  }

}