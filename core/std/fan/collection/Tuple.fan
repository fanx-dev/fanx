//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

rtconst class Tuple<A, B, C, D> {
  private Bool immutable := false

  A first { set { onModify; &first = it } }
  B second { set { onModify; &second = it } }
  C third { set { onModify; &third = it } }
  D fourth { set { onModify; &fourth = it } }

  private Void onModify() {
    if (immutable) {
      throw ReadonlyErr()
    }
  }

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

  new make4(A a, B b, C c, D d) {
    this.first = a
    this.second = b
    this.third = c
    this.fourth = d
  }

  override Bool isImmutable() {
    return immutable
  }

  override Tuple<A, B, C, D> toImmutable() {
    if (immutable) return this

    t := Tuple<A, B, C, D>{}
    t.first = this.first.toImmutable
    t.second = this.second.toImmutable
    t.third = this.third.toImmutable
    t.fourth = this.fourth.toImmutable
    t.immutable = true
    return t
  }
}

