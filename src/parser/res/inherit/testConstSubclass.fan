virtual class X
{
  const Int x := 1
}

class Y : X
{
  const Int y := 2
  new make() { x += 10 }
}