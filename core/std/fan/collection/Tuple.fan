//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

rtconst class Tuple<A, B, C> {
  private Bool immutable := false

  A first { private set }
  B second { private set }
  C third { private set }

  new make(|This| f) { f(this) }

  new make1(A a) {
    this.first = a
  }

  new make2(A a, B b) {
    this.first = a
    this.second = b
  }

  new make3(A a, B b, C c) {
    this.first = a
    this.second = b
    this.third = c
  }

  override Bool isImmutable() {
    return immutable
  }

  override Tuple<A, B, C> toImmutable() {
    if (immutable) return this

    t := Tuple<A, B, C>(
      this.first?.toImmutable,
      this.second?.toImmutable,
      this.third?.toImmutable
    )
    t.immutable = true
    return t
  }
}

