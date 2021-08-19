class Foo : Goo
{
  private static Int x() { return 'x' }
  static Int testX()
  {
    f := |->Int| { return x }
    return f.call
  }

  protected static Int y() { return 'y' }
  static Int testY()
  {
    f := |->Int|
    {
      g := |->Int| { return y  }
      return g.call
    }
    return f.call
  }

  static Int testZ()
  {
    f := |->Int| { return z }
    return f.call
  }
}

virtual class Goo
{
  protected static Int z() { return 'z' }
}