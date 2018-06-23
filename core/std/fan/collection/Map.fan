//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 06  Brian Frank  Creation
//

**
** Map is a hash map of key/value pairs.
**
** See [examples]`examples::sys-maps`.
**
@Serializable
rtconst abstract class Map<K,V>
{
//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor
  **
  static new make(Int capacity := 16) {
    return HashMap<K,V>(capacity)
  }

  //on modify
  protected abstract Void modify()


  protected new privateMake() {}


  protected abstract This createEmpty()

  const static [Obj:Obj] defVal := [:]

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
  override abstract Bool equals(Obj? that)

  **
  ** Return platform dependent hashcode based on hash of the keys and values.
  **
  override abstract Int hash()

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
  abstract Int size { protected set }

  **
  ** Get the value for the specified key.  If key is not mapped,
  ** then return the value of the def parameter.  If def is omitted
  ** it defaults to the `def` field.  This method is readonly safe.
  ** Shortcut is 'a[key]'.
  **
  @Operator abstract V? get(K key, V? defV := null)

  **
  ** Get the value for the specified key or if key is not mapped
  ** then raise UnknownKeyErr.  This method is readonly safe.
  **
  V getOrThrow(Obj key) {
    getChecked(key, true)
  }

  **
  ** Get the value for the specified key.  If the key is not
  ** mapped then return null or raise UnknownKeyEr based on checked
  ** flag.  This method is readonly safe.
  **
  V? getChecked(K key, Bool checked := true) {
    l := get(key, null)
    if (l == null) {
      if (checked && !containsKey(key)) throw UnknownKeyErr(key)
    }
    return l
  }

  **
  ** Return if the specified key is mapped.
  ** This method is readonly safe.
  **
  abstract Bool containsKey(K key)

  **
  ** Get a list of all the mapped keys.  This method is readonly safe.
  **
  abstract K[] keys()

  **
  ** Get a list of all the mapped values.  This method is readonly safe.
  **
  abstract V[] vals()

  **
  ** Create a shallow duplicate copy of this Map.  The keys and
  ** values themselves are not duplicated.  This method is readonly safe.
  **
  virtual This dup() {
    nmap := createEmpty()
    each |v,k| {
      nmap.set(k, v)
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
  @Operator abstract This set(K key, V val)

  **
  ** Add the specified key/value pair to the map.  If the key is
  ** already mapped, then throw the ArgErr.  Return this.  If key
  ** does not return true for Obj.isImmutable, then throw NotImmutableErr.
  ** If key is null throw NullErr.  Throw ReadonlyErr if readonly.
  **
  abstract This add(K key, V val)

  **
  ** Get the value for the specified key, or if it doesn't exist
  ** then automatically add it.  The value function is called to
  ** get the value to add, it is only called if the key is not
  ** mapped. Throw ReadonlyErr if readonly only if add is required.
  **
  V getOrAdd(K key, |K->V| valFunc) {
    l := get(key)
    if (l != null) {
      return l
    }
    if (containsKey(key)) return null
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
  This setAll([K:V] m) {
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
  This addAll([K:V] m) {
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
  This setList(Obj?[] list, |Obj? item, Int index->Obj?|? c := null) {
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
  This addList(Obj?[] list, |Obj? item, Int index->Obj?|? c := null) {
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
  abstract V? remove(K key)

  **
  ** Remove all key/value pairs from the map.  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  abstract This clear()

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
  //abstract Bool caseInsensitive

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
  //abstract Bool ordered

  **
  ** The default value to use for `get` when a key isn't mapped.
  ** This field defaults to null.  The value of 'def' must be immutable
  ** or NotImmutableErr is thrown.  Getting this field is readonly safe.
  ** Throw ReadonlyErr if set when readonly.
  **
  //abstract V? defV

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

  **
  ** Return a string representation the Map.  This method is readonly safe.
  **
  override Str toStr() {
    if (size == 0) return "[:]"
    buf := StrBuf()
    buf.add("[")
    first := true
    this.each |v, k| {
      if (!first) {
        buf.add(", ")
      } else {
        first = false
      }
      buf.add("$k:$v")
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
  virtual Str join(Str separator, |Obj? val, Obj? key->Str|? c := null) {
    buf := StrBuf()
    first := true
    this.each |v, k| {
      if (!first) {
        buf.add(separator)
      } else {
        first = false
      }

      if (c != null) {
        buf.add(c(v, k))
      } else {
        buf.add("$k: $v")
      }
    }
    return buf.toStr
  }

  **
  ** Get this map as a Fantom expression suitable for code generation.
  ** The individual keys and values must all respond to the 'toCode' method.
  **
  Str toCode() {
    if (size == 0) return "[:]"
    buf := StrBuf()
    buf.add("[")
    first := true
    this.each |v, k| {
      if (!first) {
        buf.add(", ")
      } else {
        first = false
      }
      if (k == null) buf.add("null")
      else buf.add(k->toCode)
      buf.add(":")
      if (v == null) buf.add("null")
      else buf.add(v->toCode)
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
  abstract Void each(|V val, K key| c)

  **
  ** Iterate every key/value pair in the map until the function
  ** returns non-null.  If function returns non-null, then break
  ** the iteration and return the resulting object.  Return null
  ** if the function returns null for every key/value pair.
  ** This method is readonly safe.
  **
  abstract Obj? eachWhile(|V val, K key->Obj?| c)

  **
  ** Return the first value in the map for which c returns true.
  ** If c returns false for every pair, then return null.  This
  ** method is readonly safe.
  **
  V? find(|V val, K key->Bool| c) {
    V? found := null
    eachWhile |v,k| {
      if (c(v, k)) {
        found = v
        return 1
      }
      return null
    }
    return found
  }

  **
  ** Return a new map containing the key/value pairs for which c
  ** returns true.  If c returns false for every item, then return
  ** an empty map.  The inverse of this method is `exclude`.  If
  ** this map is `ordered` or `caseInsensitive`, then the resulting
  ** map is too.  This method is readonly safe.
  **
  This findAll(|V val, K key->Bool| c) {
    nmap := createEmpty()
    this.each |v,k| {
      if (c(v,k)) {
        nmap[k] = v
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
  This exclude(|V val, K key->Bool| c) {
    nmap := createEmpty()
    this.each |v,k| {
      if (!c(v,k)) {
        nmap[k] = v
      }
    }
    return nmap
  }

  **
  ** Return true if c returns true for any of the key/value pairs
  ** in the map.  If the map is empty, return false.  This method
  ** is readonly safe.
  **
  Bool any(|V val, K key->Bool| c) {
    found := false
    eachWhile |v,k| {
      if (c(v, k)) {
        found = true
        return 1
      }
      return null
    }
    return found
  }

  **
  ** Return true if c returns true for all of the key/value pairs
  ** in the map.  If the list is empty, return true.  This method
  ** is readonly safe.
  **
  Bool all(|V val, K key->Bool| c) {
    valid := true
    eachWhile |v,k| {
      if (!c(v, k)) {
        valid = false
        return 1
      }
      return null
    }
    return valid
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
  Obj? reduce(Obj? init, |Obj? reduction, V val, K key->Obj?| c) {
    reduction := init
    this.each |v, k| {
        reduction = c(reduction, v, k)
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
  [K:Obj?] map(|V val, K key->Obj?| c) {
    nmap := createEmpty()
    this.each |v,k| {
        nval := c(v, k)
        nmap[k] = nval
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
  abstract Bool isRO()

  **
  ** Return if this Map is read-write.  A read-write Map is mutable
  ** and may be modified.  Use r`o` to get a readonly Map from a
  ** read-write Map.  This method is readonly safe.
  **
  Bool isRW() { !isRO }

  **
  ** Get a readonly Map instance with the same contents as this
  ** Map (although its values may be mutable themselves).  If this
  ** Map is already readonly, then return this.  Only methods
  ** documented as "readonly safe" may be used safely with a readonly
  ** Map, all others will throw ReadonlyErr.  This method is
  ** readonly safe.
  **
  abstract This ro()

  **
  ** Get a read-write, mutable Map instance with the same contents
  ** as this Map.  If this Map is already read-write, then return this.
  ** This method is readonly safe.
  **
  abstract This rw()


  override abstract Bool isImmutable()

  override abstract This toImmutable()
}