

# More Different #

### Return From Void ###
not allow return a value from Void method, except return a Void type.

### Float Literals ###
The Default Number is Float
```
  f := 0.1   //Float
  f := 0.2f  //Float
  f := 0.3d  //Decimal
```


### Extension Methods API ###
Most Convenience methods are changed to extension methods to break the dependency.

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

### DateTime ###
Added TimePoint class.
All time APIs are based on millis ticks.
The Time is renamed to TimeOfDay.

### Depend ###
The Depend class only support simple version constraint.

### Type Erasure ###
The List.fits and Func.returns are no longer available.

### Map ###
The Map.caseInsensitive and Map.ordered replaced by Orderedmap and CaseInsensitiveMap.

### Static Cotr ###
The static constructor return nonNullable type.

### Charset ###
It's more Unicode compliant.

### More Tools ###
Lock, Lazy, SoftRef,...
```
  const Lazy<Bar> lazyBar := Lazy<Bar> { Bar() }
  bar := lazyBar.get
```

### Closures with Resources ###
```
  outStream.use { it.print("Hi") }
  lock.sync { ... }
```

### Assert ###
```
  assert(a == b, "error")
```

### More Str Utils ###
Str.splitBy, Str.splitAny, Str.extract, Str.format
```
  Str.format("%s %d %f", ["Hi", 12, 0.3])
```



