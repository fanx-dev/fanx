//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-6-18 Jed Young Creation
//

**
** the map maintains the order in which key/value pairs are added to the map.
** The implementation is based on using a linked list in addition to the normal hashmap.
**
rtconst class OrderedMap<K,V> : HashMap<K,V> {
  private LinkedList list := LinkedList()

  new make(Int capacity:=16) : super.make(capacity) {
  }

  protected override This createEmpty() {
    return OrderedMap()
  }

  @Operator override This set(K key, V val) {
    modify
    MapEntry? entry := super.rawGet(key)
    if (entry != null) {
      entry.val = val
      return this
    }
    entry = MapEntry()
    entry.val = val
    entry.key = key
    super.set(key, entry)
    list.add(entry)
    return this
  }

  override This add(K key, V val) {
    entry := MapEntry()
    entry.val = val
    entry.key = key
    super.add(key, entry)
    list.add(entry)
    return this
  }

  @Operator override V? get(K key, V? defValue := super.defV) {
    MapEntry? entry := super.get(key, null)
    if (entry == null) return defValue
    return entry.val
  }

  override Void each(|V val, K key| c) {
    itr := list.first
    end := null
    while (itr !== end) {
      MapEntry entry := itr
      c(entry.val, entry.key)
      itr = itr.next
    }
  }

  override Obj? eachWhile(|V val, K key->Obj?| c) {
    itr := list.first
    end := null
    while (itr !== end) {
      MapEntry entry := itr
      result := c(entry.val, entry.key)
      if (result != null) return result
      itr = itr.next
    }
    return null
  }

  override K[] keys() {
    list := List.make(size)
    itr := this.list.first
    end := null

    while (itr !== end) {
      MapEntry entry := itr
      list.add(entry.key)
      itr = itr.next
    }
    return list
  }

  override V[] vals() {
    list := List.make(size)
    itr := this.list.first
    end := null

    while (itr !== end) {
      MapEntry entry := itr
      list.add(entry.val)
      itr = itr.next
    }
    return list
  }

  override V? remove(K key) {
    MapEntry? entry := super.remove(key)
    if (entry != null) {
      list.remove(entry)
      return entry.val
    }
    return null
  }

  override This clear() {
    super.clear
    list.clear
    return this
  }
}

