class Foo
{
  Void f(Int a)
  {
    b := 2
    a := true
    b := true;

    3.times |Int a| { return };
    2.times |->| { |Int x, Int b| {} };

    |->| { a := true }.callList;
    |->| { |->| { b := 4 } }.callList;
  }
}