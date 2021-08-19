class Foo
{
  Str f(Int a, Int b)
  {
    c := 2
    d := 6; d = 3
    s := ""
    3.times |Int i|
    {
      n := next
      s += "($n: $a $b $c $d)"
      a++
      d++
    }
    return s
  }

  Int next() { return counter++ }
  Int counter := 0
}