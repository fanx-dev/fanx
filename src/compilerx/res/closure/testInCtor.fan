class Foo
{
  new make() { f := |->| { i = 4 }; f()  }
  const Int i

  static const Int j
  static  { f := |->| { j = 7 }; f()  }
}