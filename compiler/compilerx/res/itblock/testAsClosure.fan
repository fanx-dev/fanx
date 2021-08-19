class Acme
{
  Int[] m03() { x := Int[,]; "abc".each { x.add(it) }; return x }
  Int[] m04() { x := Int[,]; "abc".each { u := upper; x.add(u) }; return x }
  Int[] m05() { return ['d','e','f'].map { upper} }
  Int[] m06() { return ['G','H','I'].map { it.upper.toChar } }
}