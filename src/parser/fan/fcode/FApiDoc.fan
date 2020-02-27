
**
** Parse API doc
**
class FApiDoc {
  private FPod pod
  //Bool supportFile := true
  [Str:Str[]] cache

  new make(FPod pod) {
    this.pod = pod
    this.cache = [:]
  }

  Str[] typeDoc(Str type) {
    lines := cache[type]

    if (lines == null) {
      return List.defVal
    }
    res := Str[,]
    state := 0
    for (i:=0; i<lines.size; ++i) {
      line := lines[i]
      if (line.isEmpty) {
        if (state == 0) {
          state = 1
          continue
        }
        break
      }
      if (state == 1) {
        if (line.startsWith("-- ")) break
        res.add(line)
      }
    }
    return res
  }

  Str[] slotDoc(Str type, Str slot) {
    lines := cache[type]
    if (lines == null) {
      return List.defVal
    }

    res := Str[,]
    state := -1
    for (i:=0; i<lines.size; ++i) {
      line := lines[i]
      if (line.startsWith("-- $slot")) {
        state = 0
        continue
      }
      if (state == -1) continue

      if (line.isEmpty) {
        if (state == 0) {
          state = 1
          continue
        }
        break
      }
      if (state == 1) {
        if (line.startsWith("-- ")) break
        res.add(line)
      }
    }
    return res
  }
}