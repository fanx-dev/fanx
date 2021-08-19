class Foo
{
  Int[] foo()
  {
    Obj x := Foo()
    acc := Int[,]
    x->things->each |t| { acc.add(t) }
    return acc
  }

  Int[] things := [1, 2, 3]
}