class A
{
  virtual Int x := 3 { set { xTrap = it } }
  Int xTrap
}

class B : A
{
  override Int x := 7
}