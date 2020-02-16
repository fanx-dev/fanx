class Foo
{
  static Str f(Int a)
  {
    b := 2
    s := ""
    2.times |Int c|
    {
      d := c+10
      2.times |Int e|
      {
        s += "[$a $b $c $d $e]"
        a++
        b*=2
      }
    }
    return s
  }
}