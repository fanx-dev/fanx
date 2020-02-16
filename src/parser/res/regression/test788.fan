class Foo
{
  Int[] list := Int[2, 3, 4]
  Int[] test(Int? i)
  {
    list[i] += 1
    return list
  }
}