//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

internal class CacheItem : LinkedElem {
  Obj? key
  Int cacheCount := 0

  new make() : super() {}
}

**
** The Least Recently Used Cache
**
class Cache {
  private [Obj:CacheItem] map := [Obj:CacheItem][:]
  private LinkedList list := LinkedList()

  private Int max
  |Obj|? onRemoveItem
  |Obj->Bool|? canRemoveItem

  private Int maxCount := 4

  new make(Int size) { max = size }

  internal CacheItem? getItem(Obj key) {
    item := map[key]
    if (item != null) {
      update(item)
      return item
    }
    return null
  }

  Void each(|Obj| f) {
    item := list.first
    while (item != null) {
      if (item.val != null) {
        f(item.val)
      }
      item = item.next
    }
  }

  Obj? get(Obj key) {
    item := map[key]
    if (item != null) {
      update(item)
      return item.val
    }
    return null
  }

  internal virtual CacheItem newItem() {
    CacheItem()
  }

  private Void update(CacheItem item) {
    if (item.previous != null) {
      if (item.cacheCount < maxCount) {
        item.cacheCount++
      }
      list.remove(item)
    }

    list.insertBefore(item)
  }

  private CacheItem? clean() {
    if (map.size <= max) return null
    item := list.last
    while (item != null) {
      pre := item.previous
      CacheItem citem := item
      if (citem.cacheCount > 0) {
        citem.cacheCount = citem.cacheCount - 1
        list.remove(item)
        list.insertBefore(item)
      } else {
        canRemove := true
        if (canRemoveItem != null && item.val != null) {
          canRemove = canRemoveItem(item.val)
        }
        if (canRemove) {
          map.remove(citem.key)
          list.remove(item)
          onReomove(item)
          citem.cacheCount = 0
          return item
        }
      }
      item = pre
    }
    return null
  }

  Void clear() {
    item := list.last
    while (item != null) {
      pre := item.previous
      list.remove(item)
      onReomove(item)
      item = pre
    }
    list.clear
    map.clear
  }

  Void set(Obj key, Obj? val) {
    item := map[key]
    if (item == null) {
      item = clean()
      if (item == null) {
        item = newItem
      }
    }

    item.val = val
    item.key = key

    update(item)
    map[key] = item
  }

  Void remove(Obj key) {
    item := map.remove(key)
    if (item == null) {
      list.remove(item)
      onReomove(item)
    }
  }

  internal virtual Void onReomove(CacheItem e) {
    if (onRemoveItem != null && e.val != null) {
      onRemoveItem(e.val)
    }
  }

}