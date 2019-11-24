//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

@NoDoc
rtconst class ArrayList<V> : List<V>
{
  protected Array<Obj?> array
  //private Type type
  protected Bool readOnly
  protected Bool immutable

  private Void modify() {
    if (readOnly) {
      throw ReadonlyErr()
    }
  }

  new make(Int capacity) : super.privateMake() {
    array = Array<Obj>(capacity)
    //this.type = type
  }

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
        // if (!type.isNullable) {
        //   throw ArgErr("growing non-nullable list")
        // }
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

      array = Array.realloc(array, it)
      //&capacity = it
    }
    get {
      return array.size
    }
  }

  @Operator override V get(Int index) {
    if (index < 0) {
      index += size
      if (index < 0) throw IndexErr("index is out of range. size:$size, index:$index")
    }

    if (index >= size) {
      throw IndexErr("index is out of range. size:$size, index:$index")
    }

    return array[index]
  }

  @Operator override V[] getRange(Range r) {
    start := r.startIndex(size)
    end := r.endIndex(size)
    ++end
    //if (end > size) throw IndexErr("range illegal")
    len := end - start
    if (len < 0) throw IndexErr("range illegal")

    nlist := ArrayList<V>(len)
    Array.arraycopy(array, start, nlist.array, 0, len)
    nlist.&size = len
    return nlist
  }

  override List<V> dup() {
    nlist := ArrayList<V>(size)
    Array.arraycopy(array, 0, nlist.array, 0, size)
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

    newSize := (capacity < 256) ? (capacity*2+10) : (capacity*1.5).toInt
    newSize = desiredSize.max(newSize)

    capacity = newSize
  }

  @Operator override This add(V? item) {
    modify
    grow(size + 1)
    array[size] = item
    &size += 1
    return this
  }

  override This addAll(V[] alist) {
    modify
    grow(size + alist.size)
    //TODO
    ArrayList<V> list := alist
    Array.arraycopy(list.array, 0, array, size, list.size)
    &size = size + list.size
    return this
  }

  override This insert(Int index, V? item) {
    modify
    if (index < 0) index = index + size
    if (index > size) throw IndexErr("index is out of range $index")

    grow(size + 1)
    Array.arraycopy(array, index, array, index+1, size-index)
    array[index] = item
    &size += 1
    return this
  }

  override This insertAll(Int index, V[] alist) {
    modify
    if (index < 0) index += size
    if (index > size) throw IndexErr("index is out of range")

    grow(size + alist.size)
    //TODO
    ArrayList<V> list := alist
    Array.arraycopy(array, index, array, index+list.size, size-index)
    Array.arraycopy(list.array, 0, array, index, list.size)
    &size = size + list.size
    return this
  }

  override V? removeAt(Int index) {
    modify
    if (index < 0) index += size
    if (index >= size) throw IndexErr("index is out of range $index")

    obj := array[index]
    Array.arraycopy(array, index+1, array, index, size-index-1)
    array[size-1] = null
    &size = size-1
    return obj
  }

  override This removeRange(Range r) {
    modify
    start := r.startIndex(size)
    end := r.endIndex(size)
    ++end

    len := end - start
    if (len < 0) throw IndexErr("range illegal")
    if (len == 0) return this

    Array.arraycopy(array, end, array, start, size-end)
    &size = size - len
    return this
  }

  override This clear() {
    modify;
    for (i:=0; i<size; ++i) {
      array.set(0, null)
    }
    size = 0;
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private Void insertSortA(Int left, Int right, |V a, V b->Int| cmopFunc) {
    self := array
    for (i:=left;i < right; i++) {
      curVal := self[i+1]
      j := i
      //shift right
      while (j>=left && (cmopFunc(curVal, self[j]) < 0)) {
        self[j+1] = self[j]
        --j
      }
      self[j+1] = curVal
    }
  }

  private Void quickSortA(Int low, Int high, |V a, V b->Int| cmopFunc) {
    if (low == high) return
    if(!(low < high)) throw Err("$low >= $high")

    //if too small using insert sort
    if (high - low < 5) {
      insertSortA(low, high, cmopFunc)
      return
    }

    self := array
    i := low; j := high

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
    pivotVal := self[pivot]
    self[pivot] = self[i]

    while (i < j) {
      while (i<j && cmopFunc(pivotVal, self[j]) <= 0 ) --j
      //self[i] is empty
      if (i < j) {
        self[i] = self[j]
        ++i
      }

      while (i<j && cmopFunc(self[i], pivotVal) < 0) ++i
      //self[j] is empty
      if (i < j) {
        self[j] = self[i]
        --j
      }
    }
    self[i] = pivotVal
    if (low < i-1) {
      quickSortA(low, i-1, cmopFunc)
    }
    if (i+1 < high) {
      quickSortA(j+1, high, cmopFunc)
    }
  }

  override This sort(|V a, V b->Int|? c := null) {
    modify
    if (size <= 1) return this
    if (c == null) c = |a, b->Int| { a <=> b }
    quickSortA(0, size-1, c)
    return this
  }


  //return -(insertation point) - 1
  private Int bsearchA(|V b, Int i->Int| cmopFunc) {
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
    return bsearchA |b, i| {
      if (c == null) return key <=> b
      return c(key, b)
    }
  }

  override Int binaryFind(|V item, Int index->Int| c) {
    return bsearchA(c)
  }

  override This reverse() {
    modify
    if (size <= 1) return this
    n := size
    for (i:=0; i<n; ++i) {
      j := n-i-1
      if (i >= j) break
      a := array[i]
      b := array[j]
      array[j] = a
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

//////////////////////////////////////////////////////////////////////////
// Readonly
//////////////////////////////////////////////////////////////////////////

  override Bool isRO() { readOnly }

  override Bool isImmutable() { immutable }

}