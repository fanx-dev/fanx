//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Feb 16  Brian Frank  Creation
//

package fan.std;

import java.util.Iterator;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import fan.sys.*;
import fanx.interop.Interop;
import fanx.main.Type;

/**
 * ConcurrentMap
 */
public final class ConcurrentMap extends FanObj
{
  public static ConcurrentMap make() { return make(256); }
  public static ConcurrentMap make(long capacity) { return new ConcurrentMap((int)capacity); }

  ConcurrentMap(int capacity) { this.map = new ConcurrentHashMap(capacity); }

  public final Type typeof() { return typeof; }
  private static final Type typeof = Type.find("std::ConcurrentMap");

  public boolean isEmpty() { return map.size() == 0; }

  public long size() { return map.size(); }

  public Object get(Object key) { return map.get(key); }

  public void set(Object key, Object val) { map.put(key, checkImmutable(val)); }

  public Object getAndSet(Object key, Object val)
  {
    return map.put(key, checkImmutable(val));
  }
  
  public void add(Object key, Object val) {
    if (map.putIfAbsent(key, checkImmutable(val)) != null)
      throw Err.make("Duplicate key:  " + key);
  }

  public Object getOrAdd(Object key, Object defVal)
  {
    Object val = map.putIfAbsent(key, checkImmutable(defVal));
    return val == null ? defVal : val;
  }

  public ConcurrentMap setAll(Map m)
  {
    if (m.isImmutable()) map.putAll(Interop.toJava(m.rw()));
    else
    {
      final List vals = m.vals();
      for (int i=0; i<vals.size(); ++i) checkImmutable(vals.get(i));
      map.putAll(Interop.toJava(m));
    }
    return this;
  }

  public Object remove(Object key) { return map.remove(key); }

  public void clear() { map.clear(); }

  public void each(Func f)
  {
    Iterator it = map.entrySet().iterator();
    while (it.hasNext())
    {
      Entry e = (Entry)it.next();
      f.call(e.getValue(), e.getKey());
    }
  }

  public Object eachWhile(Func f)
  {
    Iterator it = map.entrySet().iterator();
    while (it.hasNext())
    {
      Entry e = (Entry)it.next();
      Object r = f.call(e.getValue(), e.getKey());
      if (r != null) return r;
    }
    return null;
  }

  public boolean containsKey(Object key) { return map.containsKey(key); }

  public List keys()
  {
    List list = List.make(map.size());
    Iterator it = map.keySet().iterator();
    while (it.hasNext()) list.add(it.next());
    return list;
  }

  public List vals()
  {
    List list = List.make(map.size());
    Iterator it = map.values().iterator();
    while (it.hasNext()) list.add(it.next());
    return list;
  }

  private Object checkImmutable(Object val)
  {
    if (FanObj.isImmutable(val))
      return val;
    else
      throw NotImmutableErr.make();
  }

  final ConcurrentHashMap map;
}