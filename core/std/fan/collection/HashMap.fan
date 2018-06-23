//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

internal class MapEntry : LinkedElem {
  Obj? key
  Obj? value { get{super.val} set{super.val=it} }

  new make(Obj? v:=null) : super.make(v) {}
}

internal class MapEntryList : LinkedList {

  new make() {
    head = MapEntry("MapEntryList.head")
    head.previous = head
    head.next = head
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

  MapEntry? removeByKey(Obj? key) {
    entry := findByKey(key)
    if (entry == null) {
      return null
    }
    remove(entry)
    return entry
  }

  MapEntry? setByKey(Obj? key, Obj? value) {
    entry := findByKey(key)
    if (entry == null) {
      entry = MapEntry()
      entry.key = key
      entry.value = value
      this.add(entry)
      return null
    }
    entry.value = value
    return entry
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

rtconst class HashMap<K,V> : Map
{
  private MapEntryList?[] array
  //private Type type
  private Bool readOnly
  private Bool immutable
  private Float loadFactor
  protected Bool keySafe := true

  protected override Void modify() {
    if (readOnly) {
      throw ReadonlyErr()
    }
  }

  new make(Int capacity:=16, Float loadFactor:=0.75) : super.privateMake() {
    //this.type = type
    if (capacity <= 0) capacity = 1
    array = MapEntryList?[,] { it->size = capacity }
    this.loadFactor = loadFactor
  }

  override Bool equals(Obj? that) {
    if (this === that) return true
    if (that isnot Map) return false
    o := that as [K:V]
    if (this.size != o.size) return false
    return all |v,k| {
      if (v == null) {
        return (o.get(k) == null && o.containsKey(k))
      }
      return o.get(k) == v
    }
  }

  override Int hash() {
    Int h := 0
    //The HashMap is unordered
    each |v,k| {
      if (v != null) h += v.hash
      if (k != null) h += k.hash
    }
    return h
  }

  override Int size { private set }

  private Int getHash(K? key) {
    if (key == null) return 0
    hash := key.hash % array.size
    return hash.abs
  }

  protected V? rawGet(K key, V? defV := null) {
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

  @Operator override V? get(K key, V? defV := null) {
    rawGet(key, defV)
  }

  override Bool containsKey(K key) {
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      return false
    }

    entry := l.findByKey(key)
    return entry != null
  }

  override K[] keys() {
    list := List.make(size)
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
    list := List.make(size)
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

  protected override This createEmpty() {
    return HashMap()
  }

  protected Void rehash() {
    if (size < (array.size * loadFactor).toInt) {
      return
    }
    modify

    newSize := size < 256 ? size * 2 + 8 : (size * 1.5).toInt
    oldArray := this.array
    array = MapEntryList?[,] { it->size = newSize }
    size = 0

    for (i:=0; i<oldArray.size; ++i) {
      l := oldArray[i]
      if (l == null) continue

      itr := l.begin
      while (itr != l.end) {
        rawSet(itr.key, itr.value)
        itr = itr.next
      }
    }
  }

  protected Void rawSet(K key, V val) {
    rehash
    hash := getHash(key)
    l := array[hash]
    if (l == null) {
      l = MapEntryList()
      array[hash] = l
    }

    old := l.setByKey(key, val)
    if (old == null) ++size
  }

  @Operator override This set(K key, V val) {
    modify
    if (keySafe && !key.isImmutable)
      throw NotImmutableErr("key is not immutable: ${key->typeof}")
    rawSet(key, val)
    return this
  }

  override This add(K key, V val) {
    modify
    if (keySafe && !key.isImmutable)
      throw NotImmutableErr("key is not immutable: ${key->typeof}")
    rehash
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
    return old.value
  }

  override This clear() {
    modify
    size = 0
    for (i:=0; i<array.size; ++i) {
      l := array[i]
      l?.clear
    }
    size = 0
    return this
  }

  //override Bool caseInsensitive := false { set { modify; &caseInsensitive = it } }

  //override Bool ordered := false { set { modify; &ordered = it } }

  //override V? defV { set { modify; &defV = it } }

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
    HashMap<K,V> nmap := dup
    nmap.readOnly = true
    return nmap
  }

  override This rw() {
    if (isRW) return this
    HashMap<K,V> nmap := dup
    nmap.readOnly = false
    return nmap
  }

  override Bool isImmutable() {
    return immutable
  }

  override This toImmutable() {
    if (immutable) return this
    nmap := createEmpty()
    each |v,k| {
      nmap.set(k?.toImmutable, v?.toImmutable)
    }
    nmap.readOnly = true
    nmap.immutable = true
    return nmap
  }
}