class Acme
{
  Obj a() { Foo { add(1).add(2) } }
}

class Foo
{
  This add(Int x) { list.add(x); return this }
  Int[] list := Int[,]
}