

class Whatever {
  extension static Str[] splitBy(Str str, Str sp, Int max := Int.maxVal) {
    if (sp.size == 0) {
      return [str]
    }
    res := Str[,]
    while (true) {
      if (res.size == max-1) {
        res.add(str)
        break
      }
      i := str.index(sp)
      if (i == null) {
        res.add(str)
        break
      }

      part := str[0..<i]
      res.add(part)

      start := i + sp.size
      if (start < str.size) {
        str = str[start..-1]
      } else {
        str = ""
      }
    }

    return res
  }
}

class ExtensionTest {
  Void main() {
    str := "->A->B->C->"
    fs := str.splitBy("->", 3)
    fs2 := Whatever.splitBy(str, "->", 3)

    echo("$fs == $fs2")
  }
}