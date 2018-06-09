

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
LinkedList Set and more.

### DateTime ###
Add TimePoint class.
All time APIs are based on a millis ticks.
The Time rename to TimeOfDay.

### Depend ###
The Depend class only support simple version constraint.

