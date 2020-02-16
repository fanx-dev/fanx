class A
{
  virtual Int x { get { return y } set { y = it } }
  Int y
}

class B : A
{
  override Int x
}