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
  ** Make with initial capacity
  new make(Int initialCapacity := 256)

  ** Return if size is zero (this is expensive and requires full segment traveral)
  Bool isEmpty()

  ** Return size (this is expensive and requires full segment traveral)
  Int size()

  ** Get a value by its key or return null
  @Operator V? get(K key)

  ** Set a value by key
  @Operator Void set(K key, V val)

  ** Add a value by key, raise exception if key was already mapped
  Void add(K key, V val)

  ** Get the value for the specified key, or if it doesn't exist
  ** then automatically add it with the given default value.
  V getOrAdd(K key, V defVal)

  ** Append the specified map to this map be setting every key/value from
  ** 'm' in this map. Keys in m not yet mapped are added and keys already
  ** mapped are overwritten. Return this.
  This setAll([K:V] m)

  ** Remove a value by key, ignore if key not mapped
  V? remove(K key)

  ** Remove all the key/value pairs
  Void clear()

  ** Iterate the map's key value pairs
  Void each(|V val, K key| f)

  ** Iterate the map's key value pairs until given function
  ** returns non-null and return that as the result of this
  ** method.  Otherwise itereate every pair and return null
  Obj? eachWhile(|V val, K key->Obj?| f)

  ** Return true if the specified key is mapped
  Bool containsKey(K key)

  ** Return list of keys
  K[] keys()

  ** Return list of values
  V[] vals()
}

