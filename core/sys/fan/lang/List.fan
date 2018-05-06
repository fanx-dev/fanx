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
final rtconst class List<V>
{
  private ObjArray array
  private Type type
  private Bool readOnly
  private Bool immutable

  private Void modify() {
    if (readOnly) {
      throw ReadonlyErr()
    }
  }

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor with of type and initial capacity.
  **
  new make(Type of, Int capacity) {
    type = of
    array = ObjArray(capacity)
  }

  **
  ** Constructor for Obj?[] with initial capacity.
  **
  new makeObj(Int capacity) {
    type = Obj?#
    array = ObjArray(capacity)
  }

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
    that := other as List

    if (this.of != that.of) return false
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
    for (Int i:=0; i<size; ++i)
    {
      obj := array[i]
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
  Type of() { type }

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
  Int size {
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
        if (type.isNullable == false) {
          throw ArgErr("growing non-nullable list")
        }
        if (it > capacity) {
          capacity = it
        }
        &size = it
      }
    }
  }

  **
  ** The number of items this list can hold without allocating more memory.
  ** Capacity is always greater or equal to size.  If adding a large
  ** number of items, it may be more efficient to manually set capacity.
  ** See the `trim` method to automatically set capacity to size.  Throw
  ** ArgErr if attempting to set capacity less than size.  Getting capacity
  ** is readonly safe, setting capacity throws ReadonlyErr if readonly.
  **
  Int capacity {
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

  **
  ** Get is used to return the item at the specified the index.  A
  ** negative index may be used to access an index from the end of the
  ** list.  For example get(-1) is translated into get(size()-1).  The
  ** get method is accessed via the [] shortcut operator.  Throw
  ** IndexErr if index is out of range.  This method is readonly safe.
  **
  @Operator V? get(Int index) {
    if (index < 0) {
      index += size
    }

    if (index >= size) {
      throw IndexErr("index is out of range. size:$size, index:$index")
    }

    return array[index]
  }

  **
  ** Get the item at the specified index, but if index is out of
  ** range, then return 'def' parameter.  A negative index may be
  ** used according to the same semantics as `get`.  This method
  ** is readonly safe.
  **
  V? getSafe(Int index, Obj? def := null) {
    if (index < 0) {
      index += size
    }

    if (index >= size) {
      return def
    }

    return array[index]
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
  @Operator List getRange(Range r) {
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

    nlist := List.make(of, len)
    nlist.array.copyFrom(array, 0, start, len)
    nlist.size = len
    return nlist
  }

  **
  ** Return if this list contains the specified item.
  ** Equality is determined by `Obj.equals`.  This method is readonly safe.
  **
  Bool contains(Obj? item) {
    for (i:=0; i<size; ++i) {
      obj := array[i]
      if (item == obj) {
        return true
      }
    }
    return false
  }

  **
  ** Return if this list contains every item in the specified list.
  ** Equality is determined by `Obj.equals`.  This method is readonly safe.
  **
  Bool containsAll(List list) {
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
  Bool containsAny(List list) {
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
  ** range.  If the item is not found return null.  This method
  ** is readonly safe.
  **
  Int? index(Obj? item, Int offset := 0) {
    for (i:=offset; i<size; ++i) {
      obj := array[i]
      if (item == obj) {
        return i
      }
    }
    return null
  }

  **
  ** Reverse index lookup.  This method works just like `index`
  ** except that it searches backward from the starting offset.
  **
  Int? indexr(Obj? item, Int offset := -1) {
    if (offset < 0) offset += size

    for (i:=offset; i>=0; --i) {
      obj := array[i]
      if (item == obj) {
        return i
      }
    }
    return null
  }

  **
  ** Return integer index just like `List.index` except
  ** use '===' same operator instead of the '==' equals operator.
  **
  Int? indexSame(Obj? item, Int offset := 0) {
    for (i:=offset; i<size; ++i) {
      obj := array[i]
      if (item === obj) {
        return i
      }
    }
    return null
  }

  **
  ** Return the item at index 0, or if empty return null.
  ** This method is readonly safe.
  **
  V? first() {
    if (size == 0) return null
    return this[0]
  }

  **
  ** Return the item at index-1, or if empty return null.
  ** This method is readonly safe.
  **
  V? last() {
    if (size == 0) return null
    return this[size-1]
  }

  **
  ** Create a shallow duplicate copy of this List.  The items
  ** themselves are not duplicated.  This method is readonly safe.
  **
  List dup() {
    nlist := List.make(of, size)
    nlist.array.copyFrom(array, 0, 0, size)
    nlist.size = size
    return nlist
  }

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
  @Operator List set(Int index, Obj? item) {
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

  **
  ** Add the specified item to the end of the list.  The item will have
  ** an index of size.  Size is incremented by 1.  Return this.  Throw
  ** ReadonlyErr if readonly.
  **
  @Operator This add(V? item) {
    modify
    grow(size + 1)
    array[size] = item
    &size += 1
    return this
  }

  **
  ** Add all the items in the specified list to the end of this list.
  ** Size is incremented by list.size.  Return this.  Throw ReadonlyErr
  ** if readonly.
  **
  List addAll(List list) {
    modify
    grow(size + list.size)
    array.copyFrom(list.array, 0, size, list.size)
    size = size + list.size
    return this
  }

  **
  ** Insert the item at the specified index.  A negative index may be
  ** used to access an index from the end of the list.  Size is incremented
  ** by 1.  Return this.  Throw IndexErr if index is out of range.  Throw
  ** ReadonlyErr if readonly.
  **
  List insert(Int index, V? item) {
    modify
    if (index < 0) index += size
    if (index > size) throw IndexErr("index is out of range")

    grow(size + 1)
    array.copyFrom(array, index, index+1, size-index)
    array[index] = item
    size += 1
    return this
  }

  **
  ** Insert all the items in the specified list into this list at the
  ** specified index.  A negative index may be used to access an index
  ** from the end of the list.  Size is incremented by list.size.  Return
  ** this.  Throw IndexErr if index is out of range.  Throw ReadonlyErr
  ** if readonly.
  **
  List insertAll(Int index, List list) {
    modify
    if (index < 0) index += size
    if (index > size) throw IndexErr("index is out of range")

    grow(size + list.size)
    array.copyFrom(array, index, index+list.size, size-index)
    array.copyFrom(list.array, 0, index, list.size)
    size = size + list.size
    return this
  }

  **
  ** Remove the specified value from the list.  The value is compared
  ** using the == operator (shortcut for equals method).  Use `removeSame`
  ** to remove with the === operator.  Return the removed value and
  ** decrement size by 1.  If the value is not found, then return null.
  ** Throw ReadonlyErr if readonly.
  **
  V? remove(V? item) {
    modify
    index := index(item)
    if (index == null) return null
    return removeAt(index)
  }

  **
  ** Remove the item just like `remove` except use
  ** the === operator instead of the == equals operator.
  **
  V? removeSame(V? item) {
    modify
    index := indexSame(item)
    if (index == null) return null
    return removeAt(index)
  }

  **
  ** Remove the object at the specified index.  A negative index may be
  ** used to access an index from the end of the list.  Size is decremented
  ** by 1.  Return the item removed.  Throw IndexErr if index is out of
  ** range.  Throw ReadonlyErr if readonly.
  **
  V? removeAt(Int index) {
    modify
    obj := array[index]
    array.copyFrom(array, index+1, index, size-index-1)
    array[size-1] = null
    size = size-1
    return obj
  }

  **
  ** Remove a range of indices from this list.  Negative indexes
  ** may be used to access from the end of the list.  Throw
  ** ReadonlyErr if readonly.  Throw IndexErr if range illegal.
  ** Return this (*not* the removed items).
  **
  List removeRange(Range r) {
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
    size = size - len
    return this
  }

  **
  ** Remove every item in this list which is found in the 'toRemove' list using
  ** same semantics as `remove` (compare for equality via the == operator).
  ** If any value is not found, it is ignored.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  List removeAll(List list) {
    modify
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
  List clear() { modify; size = 0; return this }

  **
  ** Trim the capacity such that the underlying storage is optimized
  ** for the current size.  Return this.  Throw ReadonlyErr if readonly.
  **
  List trim() { modify; capacity = size; return this }

  **
  ** Append a value to the end of the list the given number of times.
  ** Return this. Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   Int[,].fill(0, 3)  =>  [0, 0, 0]
  **
  List fill(V? val, Int times) {
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
  V? pop() {
    modify
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
  List push(V item) { modify; return add(item) }

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
  Void each(|V item, Int index| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      c(obj, i)
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
  Void eachr(|V item, Int index| c){
    for (i:=size-1; i>=0; --i) {
      obj := this[i]
      c(obj, i)
    }
  }

  **
  ** Iterate the list usnig the specified range.   Negative indexes
  ** may be used to access from the end of the list.  This method is
  ** readonly safe.  Throw IndexErr if range is invalid.
  **
  Void eachRange(Range r, |V? item, Int index| c) {
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

  **
  ** Iterate every item in the list starting with index 0 up to
  ** size-1 until the function returns non-null.  If function
  ** returns non-null, then break the iteration and return the
  ** resulting object.  Return null if the function returns
  ** null for every item.  This method is readonly safe.
  **
  V? eachWhile(|V? item, Int index->Obj?| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result != null) {
        return result
      }
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
  V? eachrWhile(|V? item, Int index->Obj?| c) {
    for (i:=size-1; i>=0; --i) {
      obj := this[i]
      result := c(obj, i)
      if (result != null) {
        return result
      }
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
  V? find(|V? item, Int index->Bool| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result) {
        return obj
      }
    }
    return null
  }

  **
  ** Return the index of the first item in the list for which c returns
  ** true.  If c returns false for every item, then return null.  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [5, 6, 7]
  **   list.findIndex |Int v->Bool| { return v.toStr == "7" } => 2
  **   list.findIndex |Int v->Bool| { return v.toStr == "9" } => null
  **
  Int? findIndex(|V? item, Int index->Bool| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result) {
        return i
      }
    }
    return null
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
  List findAll(|V item, Int index->Bool| c) {
    nlist := List.make(of, 1)
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result) {
        nlist.add(obj)
      }
    }
    return nlist
  }

  **
  ** Return a new list containing all the items which are an instance
  ** of the specified type such that item.type.fits(t) is true.  Any null
  ** items are automatically excluded.  If none of the items are instance
  ** of the specified type, then an empty list is returned.  The returned
  ** list will be a list of t.  This method is readonly safe.
  **
  ** Example:
  **   list := ["a", 3, "foo", 5sec, null]
  **   list.findType(Str#) => Str["a", "foo"]
  **
  List findType(Type t) {
    nlist := List.make(of, 1)
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := obj.typeof.fits(t)
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
  List exclude(|V? item, Int index->Bool| c) {
    nlist := List.make(of, 1)
    for (i:=0; i<size; ++i) {
      obj := this[i]
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
  Bool any(|V? item, Int index->Bool| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (result) {
        return true
      }
    }
    return false
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
  Bool all(|V? item, Int index->Bool| c) {
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      if (!result) {
        return false
      }
    }
    return true
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
  Obj?[] map(|V? item, Int index->Obj?| c) {
    nlist := Obj?[,]
    for (i:=0; i<size; ++i) {
      obj := this[i]
      result := c(obj, i)
      nlist.add(result)
    }
    return nlist
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
  Obj? reduce(Obj? init, |Obj? reduction, V? item, Int index->Obj?| c) {
    Obj? reduction := init
    for (i:=0; i<size; ++i) {
      obj := this[i]
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
    for (i:=0; i<size; ++i) {
      obj := this[i]
      if (min == null) min = obj
      Int result
      if (c!=null) result = c(min, obj)
      else result = min <=> obj

      if (result < 0) {
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
    for (i:=0; i<size; ++i) {
      obj := this[i]
      if (max == null) max = obj
      Int result
      if (c!=null) result = c(max, obj)
      else result = max <=> obj

      if (result > 0) {
        max = obj
      }
    }
    return max
  }

  **
  ** Returns a new list with all duplicate items removed such that the
  ** resulting list is a proper set.  Duplicates are detected using hash()
  ** and the == operator (shortcut for equals method).  This method is
  ** readonly safe.
  **
  ** Example:
  **   ["a", "a", "b", "c", "b", "b"].unique => ["a", "b", "c"]
  **
  List unique() {
    //TODO
    throw Err()
  }

  **
  ** Return a new list which is the union of this list and the given list.
  ** The union is defined as the unique items which are in *either* list.
  ** The resulting list is ordered first by this list's order, and secondarily
  ** by that's order.  The new list is guaranteed to be unique with no duplicate
  ** values.  Equality is determined using hash() and the == operator
  ** (shortcut for equals method).  This method is readonly safe.
  **
  ** Example:
  **   [1, 2].union([3, 2]) => [1, 2, 3]
  **
  List union(List that) {
    //TODO
    throw Err()
  }

  **
  ** Return a new list which is the intersection of this list and the
  ** given list.  The intersection is defined as the unique items which
  ** are in *both* lists.  The new list will be ordered according to this
  ** list's order.  The new list is guaranteed to be unique with no duplicate
  ** values.  Equality is determined using hash() and the == operator
  ** (shortcut for equals method).  This method is readonly safe.
  **
  ** Example:
  **   [0, 1, 2, 3].intersection([5, 3, 1]) => [1, 3]
  **   [0, null, 2].intersection([null, 0, 1, 2, 3]) => [0, null, 2]
  **
  List intersection(List that) {
    //TODO
    throw Err()
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

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
  List sort(|V? a, V? b->Int|? c := null) {
    //TODO
    throw Err()
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
  List sortr(|V? a, V? b->Int|? c := null) {
    //TODO
    throw Err()
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
  Int binarySearch(V? key, |V? a, V? b->Int|? c := null) {
    //TODO
    throw Err()
  }

  **
  ** Find an element in the list using a binary search algorithm. The specified
  ** comparator function returns a negative integer, zero, or a positive integer
  ** if the desired object is less than, equal to, or greater than specified item.
  ** The list must be sorted in ascending order according to the specified
  ** comparator function. If the key is not found, then return a negative value
  ** which is '-(insertation point) - 1'.
  **
  Int binaryFind(|V? item, Int index->Int| c) {
    //TODO
    throw Err()
  }

  **
  ** Reverse the order of the items of this list in-place.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   [1, 2, 3, 4].reverse  =>  [4, 3, 2, 1]
  **
  List reverse() {
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

  **
  ** Swap the items at the two specified indexes.  Negative indexes may
  ** used to access an index from the end of the list.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  List swap(Int indexA, Int indexB) {
    modify
    if (indexA < 0) indexA += size
    if (indexB < 0) indexB += size

    a := array[indexA]
    b := array[indexB]
    array[indexB] = a
    array[indexA] = b
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
  List moveTo(V? item, Int toIndex) {
    modify
    if (item == null) return this
    i := index(item)
    if (i == null) return this

    removeAt(i)
    insert(i, item)
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
  List<Obj?> flatten() {
    nlist := List<Obj?>(Obj#,size)
    for (i:=0; i<size; ++i) {
      item := array[i]
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
    r := Range(0, size, true)
    return array[r.random]
  }

  **
  ** Shuffle this list's items into a randomized order.
  ** Return this.  Throw ReadonlyErr if readonly.
  **
  List shuffle() {
    modify
    for (i:=0; i<size; ++i) {
      swap(i, random)
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
    buf := StrBuf()
    buf.add("[")
    for (i:=0; i<size; ++i) {
      item := array[i]
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
  Str join(Str separator := "", |V? item, Int index->Str|? c := null) {
    buf := StrBuf()
    for (i:=0; i<size; ++i) {
      item := array[i]
      if (i !=0 ) buf.add(separator)

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
    buf := StrBuf()
    buf.add("[")
    for (i:=0; i<size; ++i) {
      item := array[i]
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
  Bool isRO() { readOnly }

  **
  ** Return if this List is read-write.  A read-write List is mutable
  ** and may be modified.  Use `ro` to get a readonly List from a
  ** read-write List.  This method is readonly safe.
  **
  Bool isRW() { !readOnly }

  **
  ** Get a readonly List instance with the same contents as this
  ** List (although the items may be mutable themselves).  If this
  ** List is already readonly, then return this.  Only methods
  ** documented as "readonly safe" may be used safely with a readonly
  ** List, all others will throw ReadonlyErr.  This method is readonly
  ** safe.  See `Obj.isImmutable` and `Obj.toImmutable` for deep
  ** immutability.
  **
  List ro() {
    if (isRO) return this
    nlist := dup
    nlist.readOnly = true
    return nlist
  }

  **
  ** Get a read-write, mutable List instance with the same contents
  ** as this List.  If this List is already read-write, then return this.
  ** This method is readonly safe.
  **
  List rw() {
    if (isRW) return this
    nlist := dup
    nlist.readOnly = false
    return nlist
  }

}