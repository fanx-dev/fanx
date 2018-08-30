//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

rtconst struct class Tuple<A, B, C> {
  private readonly Bool immutable := false

  readonly A first
  readonly B second
  readonly C third

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

  new makeConst(A a, B b, C c) {
    this.first = a?.toImmutable
    this.second = b?.toImmutable
    this.third = c?.toImmutable
    this.immutable = true
  }

  override Bool isImmutable() {
    return immutable
  }

  override Tuple<A, B, C> toImmutable() {
    if (immutable) return this

    t := Tuple<A, B, C>.makeConst(
      this.first,
      this.second,
      this.third
    )
    return t
  }
}

