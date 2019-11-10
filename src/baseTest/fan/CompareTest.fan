

class CompareTest {


  static Void testCompInt() {
    Int? a := null
    Int? b := 0
    Int c := 1
    Int d := 0
    Int? e := 0
    
    assert(a < b)
    assert(b > a)
    assert(b < c)
    assert(c > b)
    assert(b == d)
    assert(d == b)
    assert(c > d)
    assert(d < c)
    assert(b == e)
    assert(d == e)
  }

  static Void testCompStr() {
    Str? a := null
    Str? b := "0"
    Str c := "1"
    Str d := "0"
    Str? e := "0"
    
    assert(a < b)
    assert(b > a)
    assert(b < c)
    assert(c > b)
    assert(b == d)
    assert(d == b)
    assert(c > d)
    assert(d < c)
    assert(b == e)
    assert(d == e)
  }
  
  static Void main() {
    testCompInt
    testCompStr
  }
  
}