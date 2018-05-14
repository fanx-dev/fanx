//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 06  Brian Frank  Creation
//

internal class MapEntry {
  Obj? key
  Obj? value

  MapEntry? next
  MapEntry? previous
}

internal class MapEntryList {
  private MapEntry head := MapEntry()
  private MapEntry tail := head
  Int size { private set }

  new make() {
    head.next = tail
    tail.previous = head
  }

  Bool isEmtpy() { head == tail }

  Void clear() {
    tail = head
    size = 0
  }

  This add(MapEntry entry) {
    entry.previous = tail.previous
    entry.next = tail
    tail.previous.next = entry
    tail.previous = entry
    ++size
    return this
  }

  Void remove(MapEntry entry) {
    entry.previous.next = entry.next
    entry.next.previous = entry.previous
    entry.next = null
    entry.previous = null
    --size
  }

  MapEntry begin() { head }
  MapEntry end() { tail }

  MapEntry? findByKey(Obj? key) {
    MapEntry entry := begin
    while (entry != end) {
      if (entry.key == key) {
        return entry
      }
      entry = entry.next
    }
    return null
  }

  Obj? removeByKey(Obj? key) {
    entry := findByKey(key)
    if (entry == null) {
      return null
    }
    old := entry.value
    remove(entry)
    return old
  }

  Obj? setByKey(Obj? key, Obj? value) {
    entry := findByKey(key)
    if (entry == null) {
      entry = MapEntry()
      entry.key = key
      entry.value = value
      this.add(entry)
      return null
    }
    old := entry.value
    entry.value = value
    return old
  }

  Void addByKey(Obj? key, Obj? value) {
    entry := findByKey(key)
    if (entry == null) {
      entry = MapEntry()
      entry.key = key
      entry.value = value
      this.add(entry)
      return
    }
    else {
      throw ArgErr("$key already exits")
    }
  }
}

**
** Map is a hash map of key/value pairs.
**
** See [examples]`examples::sys-maps`.
**
@Serializable
final rtconst class Map<K,V>
{
  private MapEntryList?[] array
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
  ** Constructor with of type (must be Map type).
  **
  new make(Type type) {
    this.type = type
    array = MapEntryList[,] { it.size = 100 }
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two Maps are equal if they have the same type and number
  ** of equal key/value pairs.
  **
  ** Examples:
  **   a := Int:Str[1:"one", 2:"two"]
  **   b := Int:Str[2:"two", 1:"one"]
  **   c := Int:Str?[2:"two", 1:"one"]
  **   a == b  =>  true
  **   a == c  =>  false
  **
  override Bool equals(Obj? that) {
    //TODO
    this == that
  }

  **
  ** Return platform dependent hashcode based on hash of the keys and values.
  **
  override Int hash() {
    //TODO
    return array.hash
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if size() == 0.  This method is readonly safe.
  **
  Bool isEmpty() { size == 0 }

  **
  ** Get the number of key/value pairs in the list.  This
  ** method is readonly safe.
  **
  Int size { private set }

  private Int getHash(Obj key) {
    hash := key.hash % array.size
    return hash.abs
  }

  **
  ** Get the value for the specified key.  If key is not mapped,
  ** then return the value of the def parameter.  If def is omitted
  ** it defaults to the `def` field.  This method is readonly safe.
  ** Shortcut is 'a[key]'.
  **
  @Operator Obj? get(Obj key, Obj? defV := this.defV) {
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      return defV
    }

    entry := l.findByKey(key)
    if (entry != null) {
      return entry.value
    } else {
      return defV
    }
  }

  **
  ** Get the value for the specified key or if key is not mapped
  ** then raise UnknownKeyErr.  This method is readonly safe.
  **
  Obj? getOrThrow(Obj key) {
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      throw UnknownKeyErr(key)
    }

    entry := l.findByKey(key)
    if (entry != null) {
      return entry.value
    } else {
      throw UnknownKeyErr(key)
    }
  }

  **
  ** Return if the specified key is mapped.
  ** This method is readonly safe.
  **
  Bool containsKey(Obj? key) {
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      return false
    }

    obj := l.findByKey(key)
    return obj != null
  }

  **
  ** Get a list of all the mapped keys.  This method is readonly safe.
  **
  Obj?[] keys() {
    list := Obj?[,]
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        list.add(itr.key)
        itr = itr.next
      }
    }
    return list
  }

  **
  ** Get a list of all the mapped values.  This method is readonly safe.
  **
  Obj?[] vals() {
    list := Obj?[,]
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        list.add(itr.value)
        itr = itr.next
      }
    }
    return list
  }

  **
  ** Create a shallow duplicate copy of this Map.  The keys and
  ** values themselves are not duplicated.  This method is readonly safe.
  **
  Map dup() {
    nmap := Map.make(type)
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        nmap[itr.key] = itr.value
        itr = itr.next
      }
    }
    return nmap
  }

  **
  ** Set the value for the specified key.  If the key is already
  ** mapped, this overwrites the old value.  If key is not yet mapped
  ** this adds the key/value pair to the map.  Return this.  If key
  ** does not return true for Obj.isImmutable, then throw NotImmutableErr.
  ** If key is null throw NullErr.  Throw ReadonlyErr if readonly.
  **
  @Operator Map set(Obj? key, Obj? val) {
    modify
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      l = MapEntryList()
      array[hash] = l
    }

    l.setByKey(key, val)
    return this
  }

  **
  ** Add the specified key/value pair to the map.  If the key is
  ** already mapped, then throw the ArgErr.  Return this.  If key
  ** does not return true for Obj.isImmutable, then throw NotImmutableErr.
  ** If key is null throw NullErr.  Throw ReadonlyErr if readonly.
  **
  Map add(Obj? key, Obj? val) {
    modify
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      l = MapEntryList()
      array[hash] = l
    }

    l.addByKey(key, val)
    return this
  }

  **
  ** Get the value for the specified key, or if it doesn't exist
  ** then automatically add it.  The value function is called to
  ** get the value to add, it is only called if the key is not
  ** mapped. Throw ReadonlyErr if readonly only if add is required.
  **
  Obj? getOrAdd(Obj? key, |Obj?->Obj?| valFunc) {
    hash := getHash(key)
    l := array[hash]
    if (l != null) {
      entry := l.findByKey(key)
      if (entry != null) {
        return entry.value
      }
    }
    modify
    val := valFunc(key)
    set(key, val)
    return val
  }

  **
  ** Append the specified map to this map by setting every key/value in
  ** m in this map.  Keys in m not yet mapped are added and keys already
  ** mapped are overwritten.  Return this.  Throw ReadonlyErr if readonly.
  ** Also see `addAll`.  This method is semanatically equivalent to:
  **   m.each |v, k| { this.set(k, v) }
  **
  Map setAll(Map m) {
    modify
    m.each |v, k| { this.set(k, v) }
    return this
  }

  **
  ** Append the specified map to this map by adding every key/value in
  ** m in this map.  If any key in m is already mapped then this method
  ** will fail (any previous keys will remain mapped potentially leaving
  ** this map in an inconsistent state).  Return this.  Throw ReadonlyErr if
  ** readonly.  Also see `setAll`. This method is semanatically equivalent to:
  **   m.each |v, k| { this.add(k, v) }
  **
  Map addAll(Map m) {
    modify
    m.each |v, k| { this.add(k, v) }
    return this
  }

  **
  ** Add the specified list to this map where the values are the list items
  ** and the keys are derived by calling the specified function on each item.
  ** If the function is null, then the items themselves are used as the keys.
  ** If any key already mapped then it is overwritten.  Return this.  Throw
  ** ReadonlyErr if readonly.  Also see `addList`.
  **
  ** Examples:
  **   m := [0:"0", 2:"old"]
  **   m.setList(["1","2"]) |Str s->Int| { return s.toInt }
  **   m  =>  [0:0, 1:1, 2:2]
  **
  Map setList(Obj?[] list, |Obj? item, Int index->Obj?|? c := null) {
    modify
    for (i:=0; i<list.size; ++i) {
      key := list[i]
      value := key
      if (c != null) {
        key = c(value, i)
      }
      this.set(key, value)
    }
    return this
  }

  **
  ** Add the specified list to this map where the values are the list items
  ** and the keys are derived by calling the specified function on each item.
  ** If the function is null, then the items themselves are used as the keys.
  ** If any key already mapped then this method will fail (any previous keys
  ** will remain mapped potentially leaving this map in an inconsistent state).
  ** Return this.  Throw ReadonlyErr if readonly.  Also see `setList`.
  **
  ** Examples:
  **   m := [0:"0"]
  **   m.addList(["1","2"]) |Str s->Int| { return s.toInt }
  **   m  =>  [0:0, 1:1, 2:2]
  **
  Map addList(Obj?[] list, |Obj? item, Int index->Obj?|? c := null) {
    modify
    for (i:=0; i<list.size; ++i) {
      key := list[i]
      value := key
      if (c != null) {
        key = c(value, i)
      }
      this.add(key, value)
    }
    return this
  }

  **
  ** Remove the key/value pair identified by the specified key
  ** from the map and return the value.   If the key was not mapped
  ** then return null.  Throw ReadonlyErr if readonly.
  **
  Obj? remove(Obj? key) {
    modify
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      return null
    }

    return l.removeByKey(key)
  }

  **
  ** Remove all key/value pairs from the map.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  Map clear() {
    modify
    size = 0
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      l.clear
    }
    return this
  }

  **
  ** This field configures case sensitivity for maps with Str keys.  When
  ** set to true, Str keys are compared without regard to case for the following
  ** methods:  get, containsKey, set, add, setAll, addAll, and remove methods.
  ** Only ASCII character case is taken into account.  The original case
  ** is preserved (keys aren't made all lower or upper case).  This field
  ** defaults to false.
  **
  ** Getting this field is readonly safe.  If you attempt to set this method
  ** on a map which is not empty or not typed to use Str keys, then throw
  ** UnsupportedOperation.  Throw ReadonlyErr if set when readonly.  This
  ** mode cannot be used concurrently with `ordered`.
  **
  Bool caseInsensitive := false { set { modify; &caseInsensitive = it } }

  **
  ** When set to true, the map maintains the order in which key/value
  ** pairs are added to the map.  The implementation is based on using
  ** a linked list in addition to the normal hashmap.  This field defaults
  ** to false.
  **
  ** Getting this field is readonly safe.  If you attempt to set this method
  ** on a map which is not empty, then throw UnsupportedOperation.  Throw
  ** ReadonlyErr if set when readonly.  This mode cannot be used concurrently
  ** with `caseInsensitive`.
  **
  Bool ordered := false { set { modify; &ordered = it } }

  **
  ** The default value to use for `get` when a key isn't mapped.
  ** This field defaults to null.  The value of 'def' must be immutable
  ** or NotImmutableErr is thrown.  Getting this field is readonly safe.
  ** Throw ReadonlyErr if set when readonly.
  **
  Obj? defV { set { modify; &defV = it } }

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

  **
  ** Return a string representation the Map.  This method is readonly safe.
  **
  override Str toStr() {
    buf := StrBuf()
    buf.add("[")
    first := true
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        if (first == false) {
          buf.add(",")
        } else {
          first = false
        }
        buf.add("$itr.key:$itr.value")
        itr = itr.next
      }
    }
    buf.add("]")
    return buf.toStr
  }

  **
  ** Return a string by concatenating each key/value pair using
  ** the specified separator string.  If c is non-null then it
  ** is used to format each pair into a string, otherwise "$k: $v"
  ** is used.  This method is readonly safe.
  **
  ** Example:
  **
  Str join(Str separator, |Obj? val, Obj? key->Str|? c := null){
    buf := StrBuf()
    buf.add("[")
    first := true
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        if (first == false) {
          buf.add(",")
        } else {
          first = false
        }

        if (c != null) {
          buf.add(c(itr.value, itr.key))
        } else {
          buf.add("$itr.key:$itr.value")
        }
        itr = itr.next
      }
    }
    buf.add("]")
    return buf.toStr
  }

  **
  ** Get this map as a Fantom expression suitable for code generation.
  ** The individual keys and values must all respond to the 'toCode' method.
  **
  Str toCode() {
    buf := StrBuf()
    buf.add("[")
    first := true
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        if (first == false) {
          buf.add(",")
        } else {
          first = false
        }
        key := itr.key
        val := itr.value
        if (key != null) key = key->toCode
        if (val != null) val = val->toCode
        buf.add("$key:$val")
        itr = itr.next
      }
    }
    buf.add("]")
    return buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

  **
  ** Call the specified function for every key/value in the list.
  ** This method is readonly safe.
  **
  Void each(|Obj? val, Obj? key| c) {
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        c(itr.value, itr.key)
        itr = itr.next
      }
    }
  }

  **
  ** Iterate every key/value pair in the map until the function
  ** returns non-null.  If function returns non-null, then break
  ** the iteration and return the resulting object.  Return null
  ** if the function returns null for every key/value pair.
  ** This method is readonly safe.
  **
  Obj? eachWhile(|Obj? val, Obj? key->Obj?| c) {
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        result := c(itr.value, itr.key)
        if (result != null) return result
        itr = itr.next
      }
    }
    return null
  }

  **
  ** Return the first value in the map for which c returns true.
  ** If c returns false for every pair, then return null.  This
  ** method is readonly safe.
  **
  Obj? find(|Obj? val, Obj? key->Bool| c) {
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        r := c(itr.value, itr.key)
        if (r) return itr.value
        itr = itr.next
      }
    }
    return null
  }

  **
  ** Return a new map containing the key/value pairs for which c
  ** returns true.  If c returns false for every item, then return
  ** an empty map.  The inverse of this method is `exclude`.  If
  ** this map is `ordered` or `caseInsensitive`, then the resulting
  ** map is too.  This method is readonly safe.
  **
  Map findAll(|Obj? val, Obj? key->Bool| c) {
    nmap := Map.make(type)
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        r := c(itr.value, itr.key)
        if (r) {
          nmap[itr.key] = itr.value
        }
        itr = itr.next
      }
    }
    return nmap
  }

  **
  ** Return a new map containing the key/value pairs for which c
  ** returns false.  If c returns true for every item, then return
  ** an empty list.  The inverse of this method is `findAll`.  If
  ** this map is `ordered` or `caseInsensitive`, then the resulting
  ** map is too.  This method is readonly safe.
  **
  ** Example:
  **   map := ["off":0, "slow":50, "fast":100]
  **   map.exclude |Int v->Bool| { return v == 0 } => ["slow":50, "fast":100]
  **
  Map exclude(|Obj? val, Obj? key->Bool| c) {
    nmap := Map.make(type)
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        r := c(itr.value, itr.key)
        if (!r) {
          nmap[itr.key] = itr.value
        }
        itr = itr.next
      }
    }
    return nmap
  }

  **
  ** Return true if c returns true for any of the key/value pairs
  ** in the map.  If the map is empty, return false.  This method
  ** is readonly safe.
  **
  Bool any(|Obj? val, Obj? key->Bool| c) {
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        r := c(itr.value, itr.key)
        if (r) return true
        itr = itr.next
      }
    }
    return false
  }

  **
  ** Return true if c returns true for all of the key/value pairs
  ** in the map.  If the list is empty, return true.  This method
  ** is readonly safe.
  **
  Bool all(|Obj? val, Obj? key->Bool| c) {
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        r := c(itr.value, itr.key)
        if (!r) return false
        itr = itr.next
      }
    }
    return true
  }

  **
  ** Reduce is used to iterate through every value in the map
  ** to reduce the map into a single value called the reduction.
  ** The initial value of the reduction is passed in as the init
  ** parameter, then passed back to the closure along with each
  ** item.  This method is readonly safe.
  **
  ** Example:
  **   m := ["2":2, "3":3, "4":4]
  **   m.reduce(100) |Obj r, Int v->Obj| { return (Int)r + v } => 109
  **
  Obj? reduce(Obj? init, |Obj? reduction, Obj? val, Obj? key->Obj?| c) {
    reduction := init
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        reduction = c(reduction, itr.value, itr.key)
        itr = itr.next
      }
    }
    return reduction
  }

  **
  ** Create a new map with the same keys, but apply the specified
  ** closure to generate new values.  The new mapped is typed based
  ** on the return type of c.  If this map is `ordered` or
  ** `caseInsensitive`, then the resulting map is too.  This method
  ** is readonly safe.
  **
  ** Example:
  **   m := [2:2, 3:3, 4:4]
  **   x := m.map |Int v->Int| { return v*2 }
  **   x => [2:4, 3:6, 4:8]
  **
  Obj:Obj? map(|Obj? val, Obj? key->Obj?| c) {
    nmap := Obj:Obj[:]
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        nval := c(itr.value, itr.key)
        nmap[itr.key] = nval
        itr = itr.next
      }
    }
    return nmap
  }

//////////////////////////////////////////////////////////////////////////
// Readonly
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this Map is readonly.  A readonly Map is guaranteed
  ** to be immutable (although its values may be mutable themselves).
  ** Any attempt to modify a readonly Map will result in ReadonlyErr.
  ** Use `rw` to get a read-write Map from a readonly Map.  Methods
  ** documented as "readonly safe" may be used safely with a readonly Map.
  ** This method is readonly safe.
  **
  Bool isRO() { readOnly }

  **
  ** Return if this Map is read-write.  A read-write Map is mutable
  ** and may be modified.  Use r`o` to get a readonly Map from a
  ** read-write Map.  This method is readonly safe.
  **
  Bool isRW() { !readOnly }

  **
  ** Get a readonly Map instance with the same contents as this
  ** Map (although its values may be mutable themselves).  If this
  ** Map is already readonly, then return this.  Only methods
  ** documented as "readonly safe" may be used safely with a readonly
  ** Map, all others will throw ReadonlyErr.  This method is
  ** readonly safe.
  **
  Map ro() {
    if (isRO) return this
    nmap := dup
    nmap.readOnly = true
    return nmap
  }

  **
  ** Get a read-write, mutable Map instance with the same contents
  ** as this Map.  If this Map is already read-write, then return this.
  ** This method is readonly safe.
  **
  Map rw() {
    if (isRW) return this
    nmap := dup
    nmap.readOnly = false
    return nmap
  }
}