class Foo
{
  Int geta() { return x }
  Int gets() { return &x }

  Void seta(Int v) { x = v }
  Void sets(Int v) { &x = v }

  Int x := 3
  {
    get { xGets++; return &x }
    set { xSets++; this.&x = it }
  }

  Int xGets := 0
  Int xSets := 0
}