class Foo {
 Str a := "
  foo"
 Str baa := "

              bar
            x"
  Void f00()
  {
    g := "
                             x"

    h := "
          x" // ok

    i :=
    "
       x"
  }

 Str c := """
            bad"""
}