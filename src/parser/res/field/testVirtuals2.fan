class A
{
  Int get() { return x }
  Void set(Int v) { x = v }

  virtual Int x
  {
    get { aGets++; return &x }
    set { aSets++; &x = it }
  }
  Int aGets := 0
  Int aSets := 0
}

class B : A
{
  override Int x
  {
    get { bGets++; return super.x }
    set { bSets++; super.x = it }
  }
  Int bGets := 0
  Int bSets := 0
}

class C : B
{
  override Int x
  {
    get { cGets++; return super.x }
    set { cSets++; super.x = it }
  }
  Int cGets := 0
  Int cSets := 0
}