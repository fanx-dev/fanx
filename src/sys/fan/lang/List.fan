//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

**
** List represents an liner sequence of Objects indexed by an Int.
**
** See [examples]`examples::sys-lists`.
**
@Serializable
rtconst abstract class List<V>
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor with of type and initial capacity.
  **
  static new make(Int capacity) {
    return ArrayList<V>(capacity)
  }

  @NoDoc
  static Obj?[] makeObj(Int capacity := 4) {
    return ArrayList<Obj?>(capacity)
  }

  protected new privateMake() {}

  const static Obj[] defVal := [,]

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two Lists are equal if they have the same type, the same
  ** number of items, and all the items at each index return
  ** true for 'equals'.
  **
  ** Examples:
  **   [2, 3] == [2, 3]     =>  true
  **   [2, 3] == [3, 2]     =>  false
  **   [2, 3] == Num[2, 3]  =>  false
  **   Str[,] == [,]        =>  false
  **   Str[,] == Str?[,]    =>  false
  **
  override Bool equals(Obj? other) {
    if (other == null) return false
    if (other isnot List) return false
    that := other as V[]

    //if (this.of != that.of) return false
    if (this.size != that.size) return false

    for (Int i:=0; i<size; ++i) {
      if (this[i] != that[i]) return false
    }
    return true
  }

  **
  ** Return platform dependent hashcode based a hash of the items
  ** of the list.
  **
  override Int hash() {
    Int hash := 33
    each |obj| {
      hash = (31*hash) + (obj == null ? 0 : (obj.hash))
    }
    return hash
  }

  **
  ** Get the item Type of this List.
  **
  ** Examples:
  **   ["hi"].of    =>  Str#
  **   [[2, 3]].of  =>  Int[]#
  **
  //abstract Type? of()

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if size == 0.  This method is readonly safe.
  **
  Bool isEmpty() { size == 0 }

  **
  ** The number of items in the list.  Getting size is readonly safe,
  ** setting size throws ReadonlyErr if readonly.
  **
  ** If the size is set greater than the current size then the list is
  ** automatically grown to be a sparse list with new items defaulting
  ** to null.  However if this is a non-nullable list, then growing a
  ** list will throw ArgErr.
  **
  ** If the size is set less than the current size then any items with
  ** indices past the new size are automatically removed.  Changing size
  ** automatically allocates new storage so that capacity exactly matches
  ** the new size.
  **
  abstract Int size

  @NoDoc
  Int sz() { size }

  **
  ** The number of items this list can hold without allocating more memory.
  ** Capacity is always greater or equal to size.  If adding a large
  ** number of items, it may be more efficient to manually set capacity.
  ** See the `trim` method to automatically set capacity to size.  Throw
  ** ArgErr if attempting to set capacity less than size.  Getting capacity
  ** is readonly safe, setting capacity throws ReadonlyErr if readonly.
  **
  abstract Int capacity

  **
  ** Get is used to return the item at the specified the index.  A
  ** negative index may be used to access an index from the end of the
  ** list.  The get method is accessed via the [] shortcut operator.  Throw
  ** IndexErr if index is out of range.  This method is readonly safe.
  **
  @Operator abstract V get(Int index)

  **
  ** Get the item at the specified index, but if index is out of
  ** range, then return 'def' parameter.  A negative index may be
  ** used according to the same semantics as `get`.  This method
  ** is readonly safe.
  **
  V? getSafe(Int index, V? defV := null) {
    if (index < 0) {
      index += size
      if (index < 0) return defV
    }

    if (index >= size) {
      return defV
    }

    return this[index]
  }

  **
  ** Return a sub-list based on the specified range.  Negative indexes
  ** may be used to access from the end of the list.  This method
  ** is accessed via the '[]' operator.  This method is readonly safe.
  ** Throw IndexErr if range illegal.
  **
  ** Examples:
  **   list := [0, 1, 2, 3]
  **   list[0..2]   => [0, 1, 2]
  **   list[3..3]   => [3]
  **   list[-2..-1] => [2, 3]
  **   list[0..<2]  => [0, 1]
  **   list[1..-2]  => [1, 2]
  **
  @Operator abstract V[] getRange(Range r)

  **
  ** Return a sub-list based on the specified range
  **
  virtual List<V> slice(Range r) {
    s := r.startIndex(size)
    e := r.endIndex(size)
    return ListView<V>(this, s, e+1-s)
  }

  **
  ** Return if this list contains the specified item.
  ** Equality is determined by `Obj.equals`.  This method is readonly safe.
  **
  Bool contains(V item) {
    findIndex |v,i->Bool| { v == item } != -1
  }

  **
  ** Return if this list contains the specified item.
  ** Equality is determined by '==='.  This method is readonly safe.
  **
  Bool containsSame(V item) {
    findIndex |v,i->Bool| { v === item } != -1
  }

  **
  ** Return if this list contains every item in the specified list.
  ** Equality is determined by `Obj.equals`.  This method is readonly safe.
  **
  virtual Bool containsAll(V[] list) {
    for (i:=0; i<list.size; ++i) {
      obj := list[i]
      if (!contains(obj)) {
        return false
      }
    }
    return true
  }

  **
  ** Return if this list contains any one of the items in the specified list.
  ** Equality is determined by `Obj.equals`.  This method is readonly safe.
  **
  virtual Bool containsAny(V[] list) {
    for (i:=0; i<list.size; ++i) {
      obj := list[i]
      if (contains(obj)) {
        return true
      }
    }
    return false
  }

  **
  ** Return the integer index of the specified item using
  ** the '==' operator (shortcut for equals method) to check
  ** for equality.  Use `indexSame` to find with '===' operator.
  ** The search starts at the specified offset and returns
  ** the first match.  The offset may be negative to access
  ** from end of list.  Throw IndexErr if offset is out of
  ** range.  If the item is not found return -1.  This method
  ** is readonly safe.
  **
  Int index(V item, Int offset := 0) {
    findIndex( |v,i->Bool| { v == item }, offset)
  }

  **
  ** Reverse index lookup.  This method works just like `index`
  ** except that it searches backward from the starting offset.
  **
  Int indexr(V item, Int offset := -1) {
    findrIndex( |v,i->Bool| { v == item }, offset)
  }

  **
  ** Return integer index just like `List.index` except
  ** use '===' same operator instead of the '==' equals operator.
  **
  Int indexSame(V item, Int offset := 0) {
    findIndex( |v,i->Bool| { v === item }, offset)
  }

  **
  ** Return the item at index 0, or if empty return null.
  ** This method is readonly safe.
  **
  virtual V? first() {
    if (size == 0) return null
    return this[0]
  }

  **
  ** Return the item at index-1, or if empty return null.
  ** This method is readonly safe.
  **
  virtual V? last() {
    if (size == 0) return null
    return this[size-1]
  }

  **
  ** Create a shallow duplicate copy of this List.  The items
  ** themselves are not duplicated.  This method is readonly safe.
  **
  abstract List<V> dup()

//////////////////////////////////////////////////////////////////////////
// Modification
//////////////////////////////////////////////////////////////////////////

  **
  ** Set is used to overwrite the item at the specified the index.  A
  ** negative index may be used to access an index from the end of the
  ** list.  The set method is accessed via the []= shortcut operator.
  ** If you wish to use List as a sparse array and set values greater
  ** then size, then manually set size larger.  Return this.  Throw
  ** IndexErr if index is out of range.  Throw ReadonlyErr if readonly.
  **
  @Operator abstract This set(Int index, V item)

  **
  ** Add the specified item to the end of the list.  The item will have
  ** an index of size.  Size is incremented by 1.  Return this.  Throw
  ** ReadonlyErr if readonly.
  **
  @Operator abstract This add(V item)

  **
  ** Call `add` if item is non-null otherwise do nothing.  Return this.
  **
  This addIfNotNull(V? item) {
    if (item == null) return this
    return add(item)
  }

  **
  ** Add all the items in the specified list to the end of this list.
  ** Size is incremented by list.size.  Return this.  Throw ReadonlyErr
  ** if readonly.
  **
  abstract This addAll(V[] list)

  **
  ** Insert the item at the specified index.  A negative index may be
  ** used to access an index from the end of the list.  Size is incremented
  ** by 1.  Return this.  Throw IndexErr if index is out of range.  Throw
  ** ReadonlyErr if readonly.
  **
  abstract This insert(Int index, V item)

  **
  ** Insert all the items in the specified list into this list at the
  ** specified index.  A negative index may be used to access an index
  ** from the end of the list.  Size is incremented by list.size.  Return
  ** this.  Throw IndexErr if index is out of range.  Throw ReadonlyErr
  ** if readonly.
  **
  abstract This insertAll(Int index, V[] list)

  **
  ** Remove the specified value from the list.  The value is compared
  ** using the == operator (shortcut for equals method).  Use `removeSame`
  ** to remove with the === operator.  Return the removed value and
  ** decrement size by 1.  If the value is not found, then return null.
  ** Throw ReadonlyErr if readonly.
  **
  virtual V? remove(V item) {
    index := index(item)
    if (index == -1) return null
    return removeAt(index)
  }

  **
  ** Remove the item just like `remove` except use
  ** the === operator instead of the == equals operator.
  **
  virtual V? removeSame(V item) {
    index := indexSame(item)
    if (index == -1) return null
    return removeAt(index)
  }

  **
  ** Remove the object at the specified index.  A negative index may be
  ** used to access an index from the end of the list.  Size is decremented
  ** by 1.  Return the item removed.  Throw IndexErr if index is out of
  ** range.  Throw ReadonlyErr if readonly.
  **
  abstract V? removeAt(Int index)

  **
  ** Remove a range of indices from this list.  Negative indexes
  ** may be used to access from the end of the list.  Throw
  ** ReadonlyErr if readonly.  Throw IndexErr if range illegal.
  ** Return this (*not* the removed items).
  **
  abstract This removeRange(Range r)

  **
  ** Remove every item in this list which is found in the 'toRemove' list using
  ** same semantics as `remove` (compare for equality via the == operator).
  ** If any value is not found, it is ignored.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  virtual This removeAll(V[] list) {
    //modify
    for (i:=0; i<list.size; ++i) {
      obj := list[i]
      remove(obj)
    }
    return this
  }

  **
  ** Remove all items from the list and set size to 0.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  abstract This clear()

  **
  ** Trim the capacity such that the underlying storage is optimized
  ** for the current size.  Return this.  Throw ReadonlyErr if readonly.
  **
  virtual This trim() {
    capacity = size; return this
  }

  **
  ** Append a value to the end of the list the given number of times.
  ** Return this. Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   Int[,].fill(0, 3)  =>  [0, 0, 0]
  **
  virtual This fill(V val, Int times) {
    esize := size + times
    if (esize > capacity) capacity = esize

    for (i:=0; i<times; ++i) {
      add(val)
    }
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Stack
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the item at index-1, or if empty return null.
  ** This method has the same semantics as last().  This method
  ** is readonly safe.
  **
  V? peek() { last }

  **
  ** Remove the last item and return it, or return null if the list
  ** is empty.  This method as the same semantics as remove(-1), with
  ** the exception of has an empty list is handled.  Throw ReadonlyErr
  ** if readonly.
  **
  virtual V? pop() {
    if (size == 0) return null
    obj := last
    removeAt(size-1)
    return obj
  }

  **
  ** Add the specified item to the end of the list.  Return this.
  ** This method has the same semantics as add(item).  Throw ReadonlyErr
  ** if readonly.
  **
  This push(V item) { return add(item) }

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

  **
  ** Call the specified function for every item in the list starting
  ** with index 0 and incrementing up to size-1.  This method is
  ** readonly safe.
  **
  ** Example:
  **   ["a", "b", "c"].each |Str s| { echo(s) }
  **
  virtual Void each(|V item, Int index| c) {
    for (i:=0; i<size; ++i) {
      c(get(i), i)
    }
  }

  **
  ** Reverse each - call the specified function for every item in
  ** the list starting with index size-1 and decrementing down
  ** to 0.  This method is readonly safe.
  **
  ** Example:
  **   ["a", "b", "c"].eachr |Str s| { echo(s) }
  **
  virtual Void eachr(|V item, Int index| c) {
    for (i:=size-1; i>=0; --i) {
      c(get(i), i)
    }
  }

  **
  ** Iterate the list usnig the specified range.   Negative indexes
  ** may be used to access from the end of the list.  This method is
  ** readonly safe.  Throw IndexErr if range is invalid.
  **
  virtual Void eachRange(Range r, |V item, Int index| c) {
    s := r.startIndex(size)
    e := r.endIndex(size)
    for (i:=s; i<=e; ++i) {
      c(get(i), i)
    }
  }

  **
  ** Iterate every item in the list starting with index 0 up to
  ** size-1 until the function returns non-null.  If function
  ** returns non-null, then break the iteration and return the
  ** resulting object.  Return null if the function returns
  ** null for every item.  This method is readonly safe.
  **
  virtual Obj? eachWhile(|V item, Int index->Obj?| c, Int offset := 0) {
    if (offset < 0) offset += size
    for (i:=offset; i<size; ++i) {
      res := c(get(i), i)
      if (res != null) return res
    }
    return null
  }

  **
  ** Reverse `eachWhile`.  Iterate every item in the list starting
  ** with size-1 down to 0.  If the function returns non-null, then
  ** break the iteration and return the resulting object.  Return
  ** null if the function returns null for every item.  This method
  ** is readonly safe.
  **
  virtual Obj? eachrWhile(|V item, Int index->Obj?| c, Int offset := -1) {
    if (offset < 0) offset += size
    for (i:=offset; i>=0; --i) {
      res := c(get(i), i)
      if (res != null) return res
    }
    return null
  }

  **
  ** Return the first item in the list for which c returns true.
  ** If c returns false for every item, then return null.  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [0, 1, 2, 3, 4]
  **   list.find |Int v->Bool| { return v.toStr == "3" } => 3
  **   list.find |Int v->Bool| { return v.toStr == "7" } => null
  **
  V? find(|V item, Int index->Bool| c) {
    i := findIndex |v,i->Bool| { c(v,i) }
    return i == -1 ? null : get(i)
  }

  **
  ** Return the index of the first item in the list for which c returns
  ** true.  If c returns false for every item, then return -1.  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [5, 6, 7]
  **   list.findIndex |Int v->Bool| { return v.toStr == "7" } => 2
  **   list.findIndex |Int v->Bool| { return v.toStr == "9" } => -1
  **
  virtual Int findIndex(|V item, Int index->Bool| c, Int offset := 0) {
    if (offset < 0) offset += size
    for (i:=offset; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result) {
        return i
      }
    }
    return -1
  }

  virtual Int findrIndex(|V item, Int index->Bool| c, Int offset := -1) {
    if (offset < 0) offset += size
    for (i:=offset; i>=0; --i) {
      obj := this[i]
      result := c(obj, i)
      if (result) {
        return i
      }
    }
    return -1
  }

  **
  ** Return a new list containing the items for which c returns
  ** true.  If c returns false for every item, then return an
  ** empty list.  The inverse of this method is exclude().  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [0, 1, 2, 3, 4]
  **   list.findAll |Int v->Bool| { return v%2==0 } => [0, 2, 4]
  **
  V[] findAll(|V item, Int index->Bool| c) {
    nlist := List.make(1)
    each |obj, i| {
      result := c(obj, i)
      if (result) {
        nlist.add(obj)
      }
    }
    return nlist
  }

  **
  ** Return a new list containing the items for which c returns
  ** false.  If c returns true for every item, then return an
  ** empty list.  The inverse of this method is findAll().  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [0, 1, 2, 3, 4]
  **   list.exclude |Int v->Bool| { return v%2==0 } => [1, 3]
  **
  V[] exclude(|V item, Int index->Bool| c) {
    nlist := List.make(1)
    each |obj, i| {
      result := c(obj, i)
      if (!result) {
        nlist.add(obj)
      }
    }
    return nlist
  }

  **
  ** Return true if c returns true for any of the items in
  ** the list.  If the list is empty, return false.  This method
  ** is readonly safe.
  **
  ** Example:
  **   list := ["ant", "bear"]
  **   list.any |Str v->Bool| { return v.size >= 4 } => true
  **   list.any |Str v->Bool| { return v.size >= 5 } => false
  **
  Bool any(|V item, Int index->Bool| c) {
    findIndex |v,i->Bool| { c(v,i) } != -1
  }

  **
  ** Return true if c returns true for all of the items in
  ** the list.  If the list is empty, return true.  This method
  ** is readonly safe.
  **
  ** Example:
  **   list := ["ant", "bear"]
  **   list.all |Str v->Bool| { return v.size >= 3 } => true
  **   list.all |Str v->Bool| { return v.size >= 4 } => false
  **
  Bool all(|V item, Int index->Bool| c) {
    findIndex |v,i->Bool| { !c(v,i) } == -1
  }

  **
  ** Create a new list which is the result of calling c for
  ** every item in this list.  The new list is typed based on
  ** the return type of c.  This method is readonly safe.
  **
  ** Example:
  **   list := [3, 4, 5]
  **   list.map |Int v->Int| { return v*2 } => [6, 8, 10]
  **
  Obj?[] map(|V item, Int index->Obj?| c) {
    nlist := List.make(size)
    each |obj, i| {
      result := c(obj, i)
      nlist.add(result)
    }
    return nlist
  }

  **
  ** This is a combination of `map` and `flatten`.  Each item in
  ** this list is mapped to zero or more new items by the given function
  ** and the results are returned in a single flattened list.  Note
  ** unlike `flatten` only one level of flattening is performed.
  ** The new list is typed based on the return type of c.  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := ["a", "b"]
  **   list.flatMap |v->Str[]| { [v, v.upper] } => ["a", "A", "b", "B"]
  **
  Obj?[] flatMap(|V item, Int index->Obj?[]| c) {
    nlist := List.make(size)
    each |obj, i| {
      result := c(obj, i)
      nlist.addAll(result)
    }
    return nlist
  }

  **
  ** Group items into buckets keyed by the given function.
  ** The result is a map of lists where the map keys are generated by
  ** the given function.  The map values are the items which share the
  ** same key.  The resulting map key type is determined by the
  ** return type of c.
  **
  ** Example:
  **   // group by string size
  **   list := ["ape", "bear", "cat", "deer"]
  **   list.groupBy |s->Int| { s.size }  =>  [3:[ape, cat], 4:[bear, deer]]
  **
  [Obj:V[]] groupBy(|V item, Int index->Obj| c) {
    acc:= [:]
    return groupByInto(acc, c)
  }

  **
  ** Group by into an existing map.  This method shares the same
  ** semantics as `groupBy` except it adds into the given map.
  **
  [Obj:V[]] groupByInto([Obj:V[]] map, |V item, Int index->Obj| c) {
    this.each |obj, i| {
      group := c(obj, i)
      v := map.get(group)
      if (v == null) {
        v = [,]
        map[group] = v
      }
      v.add(obj)
    }
    return map
  }

  **
  ** Reduce is used to iterate through every item in the list
  ** to reduce the list into a single value called the reduction.
  ** The initial value of the reduction is passed in as the init
  ** parameter, then passed back to the closure along with each
  ** item.  This method is readonly safe.
  **
  ** Example:
  **   list := [1, 2, 3]
  **   list.reduce(0) |Obj r, Int v->Obj| { return (Int)r + v } => 6
  **
  Obj? reduce(Obj? init, |Obj? reduction, V item, Int index->Obj?| c) {
    Obj? reduction := init
    each |obj, i| {
      reduction = c(reduction, obj, i)
    }
    return reduction
  }

  **
  ** Return the minimum value of the list.  If c is provided, then it
  ** implements the comparator returning -1, 0, or 1.  If c is null
  ** then the <=> operator is used (shortcut for compare method).  If
  ** the list is empty, return null.  This method is readonly safe.
  **
  ** Example:
  **   list := ["albatross", "dog", "horse"]
  **   list.min => "albatross"
  **   list.min |Str a, Str b->Int| { return a.size <=> b.size } => "dog"
  **
  V? min(|V a, V b->Int|? c := null) {
    Obj? min
    each |obj, i| {
      if (i == 0) {
        min = obj
        return
      }
      Int result
      if (c!=null) result = c(min, obj)
      else result = min <=> obj

      if (result > 0) {
        min = obj
      }
    }
    return min
  }

  **
  ** Return the maximum value of the list.  If c is provided, then it
  ** implements the comparator returning -1, 0, or 1.  If c is null
  ** then the <=> operator is used (shortcut for compare method).  If
  ** the list is empty, return null.  This method is readonly safe.
  **
  ** Example:
  **   list := ["albatross", "dog", "horse"]
  **   list.max => "horse"
  **   list.max |Str a, Str b->Int| { return a.size <=> b.size } => "albatross"
  **
  V? max(|V a, V b->Int|? c := null) {
    Obj? max
    each |obj, i| {
      if (i == 0)  {
        max = obj
        return
      }
      Int result
      if (c!=null) result = c(max, obj)
      else result = max <=> obj

      if (result < 0) {
        max = obj
      }
    }
    return max
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private Void insertSort(Int left, Int right, |V a, V b->Int| cmopFunc) {
    self := this
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

  private Void quickSort(Int low, Int high, |V a, V b->Int| cmopFunc) {
    if (low == high) return
    if(!(low < high)) throw Err("$low >= $high")

    //if too small using insert sort
    if (high - low < 5) {
      insertSort(low, high, cmopFunc)
      return
    }

    self := this
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
      quickSort(low, i-1, cmopFunc)
    }
    if (i+1 < high) {
      quickSort(j+1, high, cmopFunc)
    }
  }

  **
  ** Perform an in-place sort on this list.  If a method is provided
  ** it implements the comparator returning -1, 0, or 1.  If the
  ** comparator method is null then sorting is based on the
  ** value's <=> operator (shortcut for 'compare' method).  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   s := ["candy", "ate", "he"]
  **
  **   s.sort
  **   // s now evaluates to [ate, candy, he]
  **
  **   s.sort |Str a, Str b->Int| { return a.size <=> b.size }
  **   // s now evaluates to ["he", "ate", "candy"]
  **
  virtual This sort(|V a, V b->Int|? c := null) {
    //modify
    if (size <= 1) return this
    if (c == null) c = |a, b->Int| { a <=> b }
    quickSort(0, size-1, c)
    return this
  }

  **
  ** Reverse sort - perform an in-place reverse sort on this list.  If
  ** a method is provided it implements the comparator returning -1,
  ** 0, or 1.  If the comparator method is null then sorting is based
  ** on the items <=> operator (shortcut for 'compare' method).  Return
  ** this.  Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   [3, 2, 4, 1].sortr =>  [4, 3, 2, 1]
  **
  This sortr(|V a, V b->Int|? c := null) {
    sort |a, b| {
      if (c == null) return -(a <=> b)
      return -c(a, b)
    }
  }

  //return -(insertation point) - 1
  private Int bsearch(|V b, Int i->Int| cmopFunc) {
    self := this
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

  **
  ** Search the list for the index of the specified key using a binary
  ** search algorithm.  The list must be sorted in ascending order according
  ** to the specified comparator function.  If the list contains multiple
  ** matches for key, no guarantee is made to which one is returned.  If
  ** the comparator is null then then it is assumed to be the '<=>'
  ** operator (shortcut for the 'compare' method).  If the key is not found,
  ** then return a negative value which is '-(insertation point) - 1'.
  **
  virtual Int binarySearch(V key, |V a, V b->Int|? c := null) {
    return bsearch |b, i| {
      if (c == null) return key <=> b
      return c(key, b)
    }
  }

  **
  ** Find an element in the list using a binary search algorithm. The specified
  ** comparator function returns a negative integer, zero, or a positive integer
  ** if the desired object is less than, equal to, or greater than specified item.
  ** The list must be sorted in ascending order according to the specified
  ** comparator function. If the key is not found, then return a negative value
  ** which is '-(insertation point) - 1'.
  **
  virtual Int binaryFind(|V item, Int index->Int| c) {
    return bsearch(c)
  }

  **
  ** Reverse the order of the items of this list in-place.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   [1, 2, 3, 4].reverse  =>  [4, 3, 2, 1]
  **
  virtual This reverse() {
    if (size <= 1) return this
    n := size
    for (i:=0; i<n; ++i) {
      j := n-i-1
      if (i >= j) break
      a := this[i]
      b := this[j]
      this[j] = a
      this[i] = b
    }
    return this
  }

  **
  ** Swap the items at the two specified indexes.  Negative indexes may
  ** used to access an index from the end of the list.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  virtual This swap(Int indexA, Int indexB) {
    if (indexA < 0) indexA += size
    if (indexB < 0) indexB += size

    a := this[indexA]
    b := this[indexB]
    this[indexB] = a
    this[indexA] = b
    return this
  }

  **
  ** Find the given item, and move it to the given index.  All the
  ** other items are shifted accordingly.  Negative indexes may
  ** used to access an index from the end of the list.  If the item is
  ** null or not found then this is a no op.  Return this.  Throw
  ** ReadonlyErr if readonly.
  **
  ** Examples:
  **   [10, 11, 12].moveTo(11, 0)  =>  [11, 10, 12]
  **   [10, 11, 12].moveTo(11, -1) =>  [10, 12, 11]
  **
  virtual This moveTo(V? item, Int toIndex) {
    if (item == null) return this
    i := index(item)
    if (i == -1) return this

    //must deal with before removeAt
    if (toIndex < 0) toIndex += size

    removeAt(i)
    insert(toIndex, item)
    return this
  }

  **
  ** Return a new list which recursively flattens any list items into
  ** a one-dimensional result.  This method is readonly safe.
  **
  ** Examples:
  **   [1,2,3].flatten        =>  [1,2,3]
  **   [[1,2],[3]].flatten    =>  [1,2,3]
  **   [1,[2,[3]],4].flatten  =>  [1,2,3,4]
  **
  Obj?[] flatten() {
    nlist := List.make(size)
    each |item| {
      if (item is List) {
        f := (item as List)?.flatten
        if (f != null) {
          nlist.addAll(f)
        }
      } else {
        nlist.add(item)
      }
    }
    return nlist
  }

  **
  ** Return a random item from the list.  If the list is empty
  ** return null.  This method is readonly safe.  Also see
  ** `Int.random`, `Float.random`, `Range.random`, and `util::Random`.
  **
  V? random() {
    if (size == 0) return null
    r := 0..<size
    return this[r.random]
  }

  **
  ** Shuffle this list's items into a randomized order.
  ** Return this.  Throw ReadonlyErr if readonly.
  **
  This shuffle() {
    //modify
    r := 0..<size
    each |v, i| {
      swap(i, r.random)
    }
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Return a string representation the list.  This method is readonly safe.
  **
  override Str toStr() {
    if (size == 0) return "[,]"
    buf := StrBuf()
    buf.add("[")
    each |item, i| {
      if (i != 0) buf.add(", ")
      buf.add(item)
    }
    buf.add("]")
    return buf.toStr
  }

  **
  ** Return a string by concatenating each item's toStr result
  ** using the specified separator string.  If c is non-null
  ** then it is used to format each item into a string, otherwise
  ** Obj.toStr is used.  This method is readonly safe.
  **
  ** Example:
  **   ["a", "b", "c"].join => "abc"
  **   ["a", "b", "c"].join("-") => "a-b-c"
  **   ["a", "b", "c"].join("-") |Str s->Str| { return "($s)" } => "(a)-(b)-(c)"
  **
  Str join(Str separator := "", |V item, Int index->Str|? c := null) {
    buf := StrBuf()
    each |item, i| {
      if (i != 0) buf.add(separator)
      if (c != null) {
        buf.add(c(item, i))
      } else {
        buf.add(item)
      }
    }
    return buf.toStr
  }

  **
  ** Get this list as a Fantom expression suitable for code generation.
  ** The individual items must all respond to the 'toCode' method.
  **
  Str toCode() {
    if (size == 0) return "[,]"
    buf := StrBuf()
    buf.add("[")
    each |item, i| {
      if (i != 0) buf.add(", ")
      buf.add(item->toCode)
    }
    buf.add("]")
    return buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Readonly
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this List is readonly.  A readonly List is guaranteed to
  ** be immutable (although its items may be mutable themselves).  Any
  ** attempt to  modify a readonly List will result in ReadonlyErr.  Use
  ** `rw` to get a read-write List from a readonly List.  Methods
  ** documented as "readonly safe" may be used safely with a readonly List.
  ** This method is readonly safe.
  **
  abstract Bool isRO()

  **
  ** Return if this List is read-write.  A read-write List is mutable
  ** and may be modified.  Use `ro` to get a readonly List from a
  ** read-write List.  This method is readonly safe.
  **
  Bool isRW() { !isRO }

  **
  ** Get a readonly List instance with the same contents as this
  ** List (although the items may be mutable themselves).  If this
  ** List is already readonly, then return this.  Only methods
  ** documented as "readonly safe" may be used safely with a readonly
  ** List, all others will throw ReadonlyErr.  This method is readonly
  ** safe.  See `Obj.isImmutable` and `Obj.toImmutable` for deep
  ** immutability.
  **
  virtual This ro() {
    if (isRO) return this
    ArrayList<V> nlist := dup
    nlist.readOnly = true
    return nlist
  }

  **
  ** Get a read-write, mutable List instance with the same contents
  ** as this List.  If this List is already read-write, then return this.
  ** This method is readonly safe.
  **
  virtual This rw() {
    if (isRW) return this
    ArrayList<V> nlist := dup
    nlist.readOnly = false
    return nlist
  }

  override abstract Bool isImmutable()

  override V[] toImmutable() {
    if (isImmutable) return this
    nlist := ArrayList<V>(size)
    each |v| { nlist.add(v?.toImmutable) }
    nlist.readOnly = true
    nlist.immutable = true
    return nlist
  }

}