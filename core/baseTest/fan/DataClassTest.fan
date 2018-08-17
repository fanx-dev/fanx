

class DataClassTest {
  Void main() {
    c := Coord(1,2)
    c2 := Coord(1,2)
    c3 := Coord(2,3)

    assert(c.toStr == "x:1,y:2")
    assert(c.hash == 994)
    assert(c == c2)
    assert(c != c3)
    assert(c <=> c2 == 0)
    assert(c <=> c3 == -1)
    assert(c3 <=> c == 1)

    p := Point(1,2)
    assert(p.hash == 994)
    assert(p.toStr == "x:1,y:2")
  }
}

data class Coord {
  Int x
  Int y
}

data class Point {
   Int x
   Int y

   new make(Int x, Int y) {
     this.x = x
     this.y = y
   }

   override Int hash() {
    h := 1
    h = h * 31 + x.hash
    h = h * 31 + y.hash
    return h
   }
}