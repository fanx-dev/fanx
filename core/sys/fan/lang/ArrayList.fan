//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

rtconst class ArrayList<V> : List
{
  private ObjArray array
  //private Type type
  private Bool readOnly
  private Bool immutable

  private Void modify() {
    if (readOnly) {
      throw ReadonlyErr()
    }
  }

  new make(Int capacity) : super.privateMake() {
    array = ObjArray(capacity)
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  override Bool equals(Obj? other) {
    if (other == null) return false
    if (other isnot List) return false
    that := other as List

    //if (this.of != that.of) return false
    if (this.size != that.size) return false

    for (Int i:=0; i<size; ++i) {
      if (this[i] != that[i]) return false
    }
    return true
  }

  //override Type? of() { type }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////
  override Int size {
    set {
      modify
      if (it == &size) {
        return
      }
      else if (it < &size) {
        for (i := it; i<&size; ++i) {
          array[i] = null
        }
        &size = it
      } else if (it > &size) {
        //if (type.isNullable == false) {
        //  throw ArgErr("growing non-nullable list")
        //}
        if (it > capacity) {
          capacity = it
        }
        &size = it
      }
    }
  }

  override Int capacity {
    set {
      modify
      if (it < size) {
        throw ArgErr("attempting to set capacity less than size")
      }

      if (it == array.size) {
        return
      }

      array.realloc(it)
      //&capacity = it
    }
    get {
      return array.size
    }
  }

  @Operator override V get(Int index) {
    /*
    I think JVM already do this
    if (index < 0) {
      index += size
    }

    if (index >= size) {
      throw IndexErr("index is out of range. size:$size, index:$index")
    }
    */
    return array[index]
  }

  @Operator override List getRange(Range r) {
    start := r.start
    if (start < 0) start += size
    if (start >= size) throw IndexErr("range illegal")
    end := r.end
    if (end < 0) end += size
    if (r.inclusive) {
      ++end
    }
    if (end > size) throw IndexErr("range illegal")
    len := end - start
    if (len < 0) throw IndexErr("range illegal")

    nlist := ArrayList(len)
    nlist.array.copyFrom(array, 0, start, len)
    nlist.&size = len
    return nlist
  }

  override Bool containsAll(List list) {
    for (i:=0; i<list.size; ++i) {
      obj := list[i]
      if (!contains(obj)) {
        return false
      }
    }
    return true
  }

  override Bool containsAny(List list) {
    for (i:=0; i<list.size; ++i) {
      obj := list[i]
      if (contains(obj)) {
        return true
      }
    }
    return false
  }

  override V? first() {
    if (size == 0) return null
    return this[0]
  }

  override V? last() {
    if (size == 0) return null
    return this[size-1]
  }

  override This dup() {
    nlist := ArrayList(size)
    nlist.array.copyFrom(array, 0, 0, size)
    nlist.&size = size
    return nlist
  }

//////////////////////////////////////////////////////////////////////////
// Modification
//////////////////////////////////////////////////////////////////////////

  @Operator override This set(Int index, V item) {
    modify
    if (index < 0) {
      index = size + index
    }
    if (index >= size) {
      throw IndexErr("index is out of range. size:$size, index:$index")
    }
    array[index] = item
    return this
  }

  private Void grow(Int desiredSize) {
    modify
    if (desiredSize <= capacity) return
    newSize := desiredSize.max(capacity*2)
    capacity = newSize
  }

  @Operator override This add(V? item) {
    modify
    grow(size + 1)
    array[size] = item
    &size += 1
    return this
  }

  override This addAll(List alist) {
    modify
    grow(size + alist.size)
    //TODO
    ArrayList list := alist
    array.copyFrom(list.array, 0, size, list.size)
    &size = size + list.size
    return this
  }

  override This insert(Int index, V? item) {
    modify
    if (index < 0) index += size
    if (index > size) throw IndexErr("index is out of range")

    grow(size + 1)
    array.copyFrom(array, index, index+1, size-index)
    array[index] = item
    &size += 1
    return this
  }

  override This insertAll(Int index, List alist) {
    modify
    if (index < 0) index += size
    if (index > size) throw IndexErr("index is out of range")

    grow(size + alist.size)
    //TODO
    ArrayList list := alist
    array.copyFrom(array, index, index+list.size, size-index)
    array.copyFrom(list.array, 0, index, list.size)
    &size = size + list.size
    return this
  }

  override V? remove(V? item) {
    modify
    index := index(item)
    if (index == null) return null
    return removeAt(index)
  }

  override V? removeSame(V? item) {
    modify
    index := indexSame(item)
    if (index == null) return null
    return removeAt(index)
  }

  override V? removeAt(Int index) {
    modify
    obj := array[index]
    array.copyFrom(array, index+1, index, size-index-1)
    array[size-1] = null
    &size = size-1
    return obj
  }

  override This removeRange(Range r) {
    modify
    start := r.start
    if (start < 0) start += size
    if (start >= size) throw IndexErr("range illegal")
    end := r.end
    if (end < 0) end += size
    if (r.inclusive) {
      ++end
    }
    if (end > size) throw IndexErr("range illegal")
    len := end - start
    if (len < 0) throw IndexErr("range illegal")

    if (len == 0) return this

    array.copyFrom(array, end, start, size-end)
    &size = size - len
    return this
  }

  override This removeAll(List list) {
    modify
    for (i:=0; i<list.size; ++i) {
      obj := list[i]
      remove(obj)
    }
    return this
  }

  override This clear() { modify; size = 0; return this }

  override This trim() { modify; capacity = size; return this }

  override This fill(V? val, Int times) {
    modify
    grow(size + times)
    for (i:=0; i<times; ++i) {
      add(val)
    }
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Stack
//////////////////////////////////////////////////////////////////////////

  override V? pop() {
    modify
    if (size == 0) return null
    obj := last
    removeAt(size-1)
    return obj
  }

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

  override Void each(|V item, Int index| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      c(obj, i)
    }
  }

  override Void eachr(|V item, Int index| c){
    for (i:=size-1; i>=0; --i) {
      obj := this[i]
      c(obj, i)
    }
  }

  override Void eachRange(Range r, |V item, Int index| c) {
    start := r.start
    if (start < 0) start += size
    if (start >= size) throw IndexErr("range illegal")
    end := r.end
    if (end < 0) end += size
    if (r.inclusive) {
      ++end
    }
    if (end > size) throw IndexErr("range illegal")
    len := end - start
    if (len < 0) throw IndexErr("range illegal")

    if (len == 0) return

    for (i:=start; i<end; ++i) {
      obj := this[i]
      c(obj, i)
    }
  }

  override Obj? eachWhile(|V item, Int index->Obj?| c, Int offset := 0) {
    for (i:=offset; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result != null) {
        return result
      }
    }
    return null
  }

  override Obj? eachrWhile(|V? item, Int index->Obj?| c, Int offset := -1) {
    for (i:=size+offset; i>=0; --i) {
      obj := this[i]
      result := c(obj, i)
      if (result != null) {
        return result
      }
    }
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private Void insertSort(Int left, Int right, |V a, V b->Int| cmopFunc) {
    self := array
    Int j := 0
    V? swapBuffer
    for (;left < right; left++) {
      swapBuffer = self[left+1]
      j = left
      while (j>-1 && (cmopFunc(swapBuffer, self[j]) < 0)) {
        self[j+1] = self[j]
        --j
      }
      self[j+1] = swapBuffer
    }
  }

  private Void quickSort(Int low, Int high, |V a, V b->Int| cmopFunc) {
    i := low; j := high
    if(!(low < high)) throw Err("$low >= $high")

    /*if too small using insert sort*/
    if (high - low < 20) {
      insertSort(low, high, cmopFunc)
      return
    }

    self := array

    //select pivot
    pivot := (j+i)/2
    min := i
    max := j
    if (self[i] > self[j]) {
      min = j
      max = i
    }
    if (self[pivot] < self[min]) {
      pivot = min
    }
    else if (self[pivot] > self[max]) {
      pivot = max
    }

    while (i < j) {
      while (i<j && cmopFunc(pivot, self[j]) <= 0 ) --j
      //self[i] is empty
      if (i < j) {
        self[i] = self[j]
        ++i
      }

      while (i<j && cmopFunc(self[i], pivot) < 0) ++i
      //self[j] is empty
      if (i < j) {
        self[j] = self[i]
        --j
      }
    }
    self[i] = pivot
    if (low < i-1) {
      quickSort(low, i-1, cmopFunc)
    }
    if (i+1 < high) {
      quickSort(j+1, high, cmopFunc)
    }
  }

  override This sort(|V a, V b->Int|? c := null) {
    if (size <= 1) return this
    if (c == null) c = |a, b->Int| { a <=> b }
    quickSort(0, size-1, c)
    return this
  }

  //return -(insertation point) - 1
  private Int bsearch(|V b, Int i->Int| cmopFunc) {
    self := array
    n := size
    if (n == 0) return -1
    low := 0
    high := n - 1
    while (low <= high) {
      mid := (low+high) / 2
      cond := cmopFunc(self[mid], mid)
      if (cond < 0) {
        high = mid - 1
      } else if (cond > 0) {
        low = mid + 1
      } else {
        return mid
      }
    }
    return -(low+1)
  }

  override Int binarySearch(V key, |V a, V b->Int|? c := null) {
    return bsearch |b, i| {
      if (c == null) return key <=> b
      return c(key, b)
    }
  }

  override Int binaryFind(|V item, Int index->Int| c) {
    return bsearch(c)
  }

  override This reverse() {
    modify
    mid := size / 2
    for (i:=0; i<mid; ++i) {
      a := array[i]
      b := array[size-i]
      array[size-i] = a
      array[i] = b
    }
    return this
  }

  override This swap(Int indexA, Int indexB) {
    modify
    if (indexA < 0) indexA += size
    if (indexB < 0) indexB += size

    a := array[indexA]
    b := array[indexB]
    array[indexB] = a
    array[indexA] = b
    return this
  }

  override This moveTo(V? item, Int toIndex) {
    modify
    if (item == null) return this
    i := index(item)
    if (i == null) return this

    removeAt(i)
    insert(toIndex, item)
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
// Readonly
//////////////////////////////////////////////////////////////////////////

  override Bool isRO() { readOnly }

  override This ro() {
    if (isRO) return this
    nlist := dup
    nlist.readOnly = true
    return nlist
  }

  override This rw() {
    if (isRW) return this
    nlist := dup
    nlist.readOnly = false
    return nlist
  }

  override Bool isImmutable() { immutable }

  override This toImmutable() {
    if (isImmutable) return this
    nlist := ArrayList(size)
    each |v| { nlist.add(v.toImmutable) }
    nlist.readOnly = true
    nlist.immutable = true
    return nlist
  }
}