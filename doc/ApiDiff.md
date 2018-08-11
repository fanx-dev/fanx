

# API Different #

### Extension Methods API ###
Most Convenience methods are changed to extension methods to break the dependency.
```
  mixin StrUil {
    extensiosn static Regex toRegex(Str self) { Regex(self) }
  }
```

Math Methods:
```
  mixin Math {
    extensiosn static Float cos(Float self) { ... }
    extensiosn static Float sin(Float self) { ... }
  }

  class Main : Math {
    Void main() {
      f := 0.1

      //Fantom compatible style
      r := f.cos * f.sin

      //mathematics familiar style
      r := cos(f) * sin(f)
    }
  }
```

### Deprecated Boxing ###
Some Fantom API return nullable Int, for example: InStrem.read(), Str.index().
To avoid int boxing, prefer -1 instead of null.

### More Container ###
LinkedList, Set, Tuple, ConcMap, LRUCache, TreeMap and more.
```
  Tuple<Int, Str> tuple := Tuple(1, "a")
```

### DateTime ###
Added TimePoint class.
All time APIs are based on millis ticks.
The Time is renamed to TimeOfDay.

### Depend ###
The Depend class only support simple version constraint.

### Type Erasure ###
The List.fits and Func.returns are no longer available.

### Map ###
The Map.caseInsensitive and Map.ordered replaced by Orderedmap and CIMap.

### Static Cotr ###
The static constructor return nonNullable type.

### Charset ###
It's more Unicode compliant.

### More Tools ###
Lock, Lazy, SoftRef, TheadLocal,...
```
  const Lazy<Bar> lazyBar := Lazy<Bar> |->Bar|{ Bar() }
  bar := lazyBar.get
```

### Closures with Resources ###
```
  outStream.use { it.print("Hi") }
  lock.sync { ... }
```

### Map Iterator ###
```
  itr := map.iterator
  while (tir.hasMore) {
    pair := itr.next
  }
```

### Assert ###
```
  assert(a == b, "error")
```

### Static Logger ###
```
  Log.debug("pod", "msg")
```

### String Format ###
```
  String.fromat("%s %d %f", ["Hi", 12, 0.3])
```

### JSON ###
```
  obj := Json.read("""{abc="abc"}""")
  str := Json.write(obj)
```

### Actor ###
```
  class Bar {
    Str foo(Str str) {
      echo(str)
      return "OK"
    }
  }

  actor := ActorProxy { return Bar() }
  actor->foo("Hi")

  //ActorLocal
  static const AcotrLocal<Bar> local := ActorLocal<Bar>()
```


