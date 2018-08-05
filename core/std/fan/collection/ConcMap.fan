//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

**
** ConcurrentHashMap
**
native const class ConcMap<K,V> {

  new make(Int capacity)

  Int size()

  @Operator V? get(K key, V? defV := null)

  @Operator This set(K key, V val)

  This clear()
}

