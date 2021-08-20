class Foo
{
  Int[] list := [10, 20, 30]
  Bar bar := Bar()
  @Operator Int get(Int key) { list[key] }
  @Operator Void set(Int key, Int val) { list[key] = val }

  Int testA() { this[1] }
  Int[] testB() { this[2] = 40; return list }
  Int[] testC() { this[2]++; return list }
  Int[] testD() { this[2] += 100; return list }

  Str testE() { bar[1] }
  Str[] testF() { bar[2] = "C"; return bar.list }
  Str[] testG() { bar[2] += "_add"; return bar.list }

  Int[] testH() { list[0]++; return list }
  Int[] testI() { list[0] *= 2; return list }
}

class Bar
{
  Str[] list := ["a", "b", "c"]
  @Operator Str get(Int key) { list[key] }
  @Operator Void set(Int key, Str val) { list[key] = val }
}