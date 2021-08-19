class A
{
  virtual Int x { get { return &y } set { &y = it } }
  Int y
}

class B : A
{
  Int get() { return x }
  Void set(Int v) { x = v }

  override Int x
  {
    get { bGets++; return super.x }
    set { bSets++; super.x = it }
  }

  private Int bGets := 0
  private Int bSets := 0
}