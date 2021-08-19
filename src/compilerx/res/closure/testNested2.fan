class Foo
{
  static Str f(Int a)
  {
    s := ""
    b := 2
    c := 3
    2.times |Int i|
    {
      a++
      s += "i=$i "
      2.times |Int j|
      {
        2.times |Int k|
        {
          s += "[$a $b $i $j $k]"
        }
        b *= 2
      }
      s += "\n"
    }
    d := 4
    return s + " | $a $b $c $d"
  }
}