//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Feb 16  Brian Frank  Creation
//

**
** ConcurrentMap is a Fantom wrapper around Java's ConcurrentHashMap.
** It provides high performance concurrency and allows many operations
** to be performed without locking.  Refer to the ConcurrentHashMap Javadoc
** for the detailed semanatics on behavior and performance.
**
native const final class ConcurrentMap<K,V>
{
  private const Unsafe<Map<K,V>> store
  private const Lock lock

  ** Make with initial capacity
  new make(Int initialCapacity := 256) {
    store = Unsafe(Map<K,V>(initialCapacity))
  }

  private Map<K,V> map() { store.val }

  ** Return if size is zero (this is expensive and requires full segment traveral)
  Bool isEmpty() { size == 0 }

  ** Return size (this is expensive and requires full segment traveral)
  Int size() {
    s := 0
    lock.lock
    s = map.size
    lock.unlock
    return s
  }

  ** Get a value by its key or return null
  @Operator V? get(K key) {
    res := null
    lock.lock
    res = map.get(key)
    lock.unlock
    return res
  }

  ** Set a value by key
  @Operator Void set(K key, V val) {
    lock.lock
    map.set(key, val)
    lock.unlock
  }

  ** Add a value by key, raise exception if key was already mapped
  Void add(K key, V val) {
    lock.lock
    try {
      map.add(key, val)
    }
    catch (Err e) {
      throw e
    }
    finally {
      lock.unlock
    }
  }

  ** Get the value for the specified key, or if it doesn't exist
  ** then automatically add it with the given default value.
  V getOrAdd(K key, V defVal) {
    res := null
    lock.lock
    if (map.containsKey(key)) {
      res = map.get(key)
    }
    else {
      map.set(key, defVal)
      res = defVal
    }
    lock.unlock
    return res
  }

  ** Append the specified map to this map be setting every key/value from
  ** 'm' in this map. Keys in m not yet mapped are added and keys already
  ** mapped are overwritten. Return this.
  This setAll([K:V] m) {
    res := null
    lock.lock
    res = map.setAll(m)
    lock.unlock
    return res
  }

  ** Remove a value by key, ignore if key not mapped
  V? remove(K key) {
    res := null
    lock.lock
    res = map.remove(key)
    lock.unlock
    return res
  }

  ** Remove all the key/value pairs
  Void clear() {
    lock.lock
    map.clear
    lock.unlock
  }

  ** Iterate the map's key value pairs
  Void each(|V val, K key| f) {
    lock.lock
    map.each(f)
    lock.unlock
  }

  ** Iterate the map's key value pairs until given function
  ** returns non-null and return that as the result of this
  ** method.  Otherwise itereate every pair and return null
  Obj? eachWhile(|V val, K key->Obj?| f) {
    res := null
    lock.lock
    res = map.eachWhile(f)
    lock.unlock
    return res
  }

  ** Return true if the specified key is mapped
  Bool containsKey(K key) {
    res := false
    lock.lock
    res = map.containsKey(key)
    lock.unlock
    return res
  }

  ** Return list of keys
  K[] keys() {
    res := null
    lock.lock
    res = map.keys
    lock.unlock
    return res
  }

  ** Return list of values
  V[] vals() {
    res := null
    lock.lock
    res = map.vals
    lock.unlock
    return res
  }
}

