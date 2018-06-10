//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

internal class MapEntry : LinkedElem {
  //key never be null
  Obj? key
  Obj? value { get{super.val} set{super.val=it} }
}

internal class MapEntryList : LinkedList {

  new make() {
    head = MapEntry()
    head.previous = head
    head.next = head
  }

  Void remove(MapEntry entry) {
    if (entry == end) throw ArgErr("remove end")
    entry.remove
  }

  MapEntry begin() { first }

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

//////////////////////////////////////////////////////////////////////////
// HashMap
//////////////////////////////////////////////////////////////////////////

internal rtconst class HashMap<K,V> : Map
{
  private MapEntryList?[] array
  //private Type type
  private Bool readOnly
  private Bool immutable
  private Float loadFactor

  protected override Void modify() {
    if (readOnly) {
      throw ReadonlyErr()
    }
  }

  new make(Int capacity:=16, Float loadFactor:=0.75) : super.privateMake() {
    //this.type = type
    if (capacity <= 0) capacity = 1
    array = MapEntryList?[,] { it.size = capacity }
    this.loadFactor = loadFactor
  }

  override Bool equals(Obj? that) {
    if (this === that) return true
    if (that isnot Map) return false
    o := that as Map
    return all |v,k| {
      o[k] == v
    }
  }

  override Int hash() {
    return array.hash
  }

  override Int size { private set }

  private Int getHash(K key) {
    hash := key.hash % array.size
    return hash.abs
  }

  @Operator override V? get(K key, V? defV := this.defV) {
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

  override K[] keys() {
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

  override V[] vals() {
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

  override This dup() {
    nmap := HashMap()
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

  @Operator override This set(K key, V val) {
    modify
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      l = MapEntryList()
      array[hash] = l
    }

    old := l.setByKey(key, val)
    if (old == null) ++size
    return this
  }

  override This add(K key, V val) {
    modify
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      l = MapEntryList()
      array[hash] = l
    }

    l.addByKey(key, val)
    ++size
    return this
  }

  override V? remove(K key) {
    modify
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      return null
    }

    old := l.removeByKey(key)
    if (old != null) --size
    return old
  }

  override This clear() {
    modify
    size = 0
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      l.clear
    }
    size = 0
    return this
  }

  override Bool caseInsensitive := false { set { modify; &caseInsensitive = it } }

  override Bool ordered := false { set { modify; &ordered = it } }

  override V? defV { set { modify; &defV = it } }

  override Void each(|V val, K key| c) {
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

  override Obj? eachWhile(|V val, K key->Obj?| c) {
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

  override Bool isRO() { readOnly }

  override This ro() {
    if (isRO) return this
    HashMap nmap := dup
    nmap.readOnly = true
    return nmap
  }

  override This rw() {
    if (isRW) return this
    HashMap nmap := dup
    nmap.readOnly = false
    return nmap
  }

  override Bool isImmutable() {
    return immutable
  }

  override This toImmutable() {
    if (immutable) return this
    nmap := HashMap()
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        nmap[itr.key?.toImmutable] = itr.value?.toImmutable
        itr = itr.next
      }
    }
    nmap.immutable = true
    return nmap
  }
}