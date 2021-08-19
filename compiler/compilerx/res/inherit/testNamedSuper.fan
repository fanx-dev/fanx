mixin X
{
  virtual Str f(Int a) { return "X.f" }
  virtual Str s(Int a) { return "X.s" }
}

mixin Y
{
  virtual Str f(Int a) { return "Y.f" }
}

mixin Z : X
{
  override Str toStr() { return "Z.toStr" }
  override Str s(Int a)
  {
    switch (a)
    {
      case 'Z': return "Z.s"
      case 'X': return X.super.s(a)
    }
    throw Err.make
  }
}

class A
{
  virtual Str f(Int a) { return "A.f" }
}

class B : A
{
  override Str f(Int a) { return "B.f" }
}

class C : B, Z, Y
{
  override Str f(Int a)
  {
    switch (a)
    {
      case 'C': return "C.f"
      case 'S': return super.f(a)
      // removed named super on classes #1670
      // case 'B': return B.super.f(a)
      // case 'A': return A.super.f(a)
      case 'X': return X.super.f(a)
      case 'Y': return Y.super.f(a)
    }
    throw Err.make
  }

  Str g(Int a)
  {
    switch (a)
    {
      case 'C': return "C.f"
      case 'S': return super.f(a)
      // removed named super on classes #1670
      // case 'B': return B.super.f(a)
      // case 'A': return A.super.f(a)
      case 'X': return X.super.f(a)
      case 'Y': return Y.super.f(a)
    }
    throw Err.make
  }

  Str h(Int a)
  {
    switch (a)
    {
      case 'C': return ((C)this).f(a)
      case 'S': return ((B)this).f(a)
      case 'B': return ((B)this).f(a)
      case 'A': return ((A)this).f(a)
      case 'X': return ((X)this).f(a)
      case 'Y': return ((Y)this).f(a)
    }
    throw Err.make
  }
}