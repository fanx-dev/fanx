class Foo
 {
   Str m01() { return Str
     <|
      x
     |>}

   Str m02() { return
     Str<|
           x|>}

   Str m03() { return
     Str<|
         x|>}

   Str m04() { return  // ok
     Str<|
          x|>}
 }