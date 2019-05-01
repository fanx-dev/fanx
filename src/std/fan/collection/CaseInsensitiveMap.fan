//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-6-18 Jed Young Creation
//

internal const class CIKey {
  const Str k
  const Obj key

  new make(Obj key) {
    this.key = key
    this.k = key.toStr.lower
  }

  override Str toStr() { key.toStr }
  override Int hash() { k.hash }
  override Bool equals(Obj? obj) {
    if (obj isnot CIKey) return false
    return k == ((CIKey)obj).k
  }
  override Int compare(Obj obj) {
    return k <=> ((CIKey)obj).k
  }
}

**
** case insensitive map
**
rtconst class CaseInsensitiveMap<K,V> : Map<K,V> {
  private readonly HashMap<CIKey,V> _map

  new make(Int capacity:=16) {
    _map = HashMap<CIKey,V>(capacity)
  }

  private new privateMake(HashMap<CIKey,V> m) {
    _map = m
  }

  protected override This createEmpty() {
    return CaseInsensitiveMap()
  }

  override Int size() {
    _map.size
  }

  @Operator override This set(K key, V val) {
    if (key isnot Str) throw UnsupportedErr("CI Map not keyed by Str: $key->typeof")
    k := CIKey(key)
    _map.set(k, val)
    return this
  }

  override This add(K key, V val) {
    if (key isnot Str) throw UnsupportedErr("CI Map not keyed by Str: $key->typeof")
    k := CIKey(key)
    _map.add(k, val)
    return this
  }

  @Operator override V? get(K key, V? defValue := super.defV) {
    if (key isnot Str) throw UnsupportedErr("CI Map not keyed by Str: $key->typeof")
    k := CIKey(key)
    return _map.get(k, defValue)
  }

  override Bool containsKey(K key) {
    k := CIKey(key)
    return _map.containsKey(k)
  }

  override V? remove(K key) {
    k := CIKey(key)
    return _map.remove(k)
  }

  override Void each(|V val, K key| c) {
    _map.each |v,k| {
      c(v,k.key)
    }
  }

  override Obj? eachWhile(|V val, K key->Obj?| c) {
    _map.eachWhile |v,k| {
      return c(v,k.key)
    }
  }

  override K[] keys() {
    _map.keys.map { it.key }
  }

  override This clear() { _map.clear; return this }

  override V[] vals() { _map.vals }

  override Bool isRO() { _map.isRO }

  protected override Void modify() { _map.modify }

  override This ro() {
    if (isRO) return this
    return privateMake(_map.ro)
  }

  override This rw() {
    if (isRW) return this
    return privateMake(_map.rw)
  }

  override Bool isImmutable() {
    return _map.isImmutable
  }

  override [K:V] toImmutable() {
    if (isImmutable) return this
    return privateMake(_map.toImmutable)
  }
}