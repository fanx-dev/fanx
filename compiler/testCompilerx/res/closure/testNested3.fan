class Foo
{
  Str? f()
  {
    2.times |Int i|
    {
      2.times |Int j|
      {
        counter++
      }
    }
    return null
  }

  Int counter := 0
}