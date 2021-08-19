//
// Copyright (c) 2019, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2019-11-24 Jed Young Creation
//

internal rtconst class ListView<V> : List<V> {
  private List<V> base
  private const Int offset

  override Int size {
    set {
      if (it > &size) throw ReadonlyErr()
      else &size = it
    }
  }

  override Int capacity {
    set {
      throw ReadonlyErr()
    }
  }

  new make(List<V> base, Int offset, Int size) {
    if (base is ListView<V>) {
      ListView<V> b := base
      offset += b.offset
      base = b.base
    }
    this.base = base
    this.offset = offset
    this.&size = size
  }

  @Operator override V get(Int index) {
    if (index < 0) {
      index = size + index
    }
    if (index < 0 || index >= size) {
      throw IndexErr("index is out of range. size:$size, index:$index")
    }

    return base[offset + index]
  }

  @Operator override V[] getRange(Range r) {
    start := r.startIndex(size)
    end := r.endIndex(size)
    ++end
    //if (end > size) throw IndexErr("range illegal")
    len := end - start
    if (len < 0) throw IndexErr("range illegal")

    nlist := ArrayList<V>(len)
    if (base is ArrayList<V>) {
      ArrayList<V> a := base
      Array.arraycopy(a.array, start+offset, nlist.array, 0, len)
      nlist.size = len
    }
    else {
      for (i:=start; i<end; ++i) {
        nlist.add(get(i))
      }
    }
    return nlist
  }

  @Operator override This set(Int index, V item) {
    if (index < 0) {
      index = size + index
    }
    if (index < 0 || index >= size) {
      throw IndexErr("index is out of range. size:$size, index:$index")
    }
    
    base[offset + index] = item
    return this
  }

  @Operator override This add(V item) {
    throw ReadonlyErr()
  }

  override List<V> dup() {
    nlist := ArrayList<V>(size)
    if (base is ArrayList<V>) {
      ArrayList<V> a := base
      Array.arraycopy(a.array, offset, nlist.array, 0, size)
      nlist.size = size
    }
    else {
      for (i:=0; i<size; ++i) {
        nlist.add(get(i))
      }
    }
    return nlist
  }

  override This addAll(V[] list) { throw ReadonlyErr() }

  override This insert(Int index, V item) { throw ReadonlyErr() }

  override This insertAll(Int index, V[] list) { throw ReadonlyErr() }

  override V? removeAt(Int index) { throw ReadonlyErr() }

  override This removeRange(Range r) { throw ReadonlyErr() }

  override This clear() { size = 0; return this }

  override Bool isRO() { base.isRO }

  override Bool isImmutable() { base.isImmutable }
}