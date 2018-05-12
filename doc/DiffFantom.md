
# Different From Fantom #

## Language Diff ##

### Generics ###
```
  class Foo<T> {
    T? t
    T get() { return t }
  }

  foo := Foo<Str>()
  foo.t = "abc"
```

### Extension Method ###
To add methods out side the class
```
  class Whatever {
    extension static Str[] splitBy(Str str, Str sp, Int max := Int.maxVal) {
      ...
    }
  }

  //shortcut of Whatever.splitBy(str, "::", 3)
  fs := str.splitBy("::", 3)
```

### Numeric Precision ###
Support Numeric Precision by Facets
```
  Point {
    @I16 Int x
    @I16 Int y
    @U8  Int z
  }
```

### Struct Type ###
A struct type is a value type
```
  const struct class Point {
    const Int x
    const Int y
  }
  p := Point{ x=1; y=2 }
```

### RunTime Immutable ###
```
  rtconst Buf {
    override Bool isImmutable() { ... }
    override This toImuutable() { ... }
  }
```


## Little Things ##

### Light-Weight 'sys' Library ###
The Fantom sys pod divided into three pod: sys, std, reflect
They written in Fantom with little native code.

It's more portable to write a new backend platforms.
Future targets might include Objective-C for the iPhone, the LLVM, WebAssembly.

### Static Namespace ###
FanCore allow same name static slots through inheritance.
```
   class Base {
     static Void foo() {}
   }
   class Sub : Base {
     static Void foo() {}

     static Void main() {
       foo  //call Sub.foo
       Base.foo //call Base.foo
     }
   }
```
The static constructor still work for compatibility.

### Return From Void ###
FanCore not allow return a value from Void method, except return a Void type.

### Float Literals ###
The Default Number is Float
```
  f := 0.1   //Float
  f := 0.2f  //Float
  f := 0.3d  //Decimal
```

### Native Methods ###
Fantom's Way:
```
  // Fantom
  class Foo {
    native Str a(Bool x)
    static native Void b(Int x)
  }

  // Java or C#
  class FooPeer {
    public static FooPeer make(Foo self) { return new FooPeer(); }
    public String a(Foo self, boolean x) { return "a"; }
    public static void b(long x) {}
  }
```
New way:
```
  // Java or C#
  class FooPeer {
    public static String a(Foo self, boolean x) { return "a"; }
    public static void b(long x) {}
  }
```
If you want a peer field to hold data:
```
  //Fantom
  class Foo {
    internal Obj? peer
    native Str a(Bool x)
    static native Void b(Int x)
  }
```

### Build Script ###
The pod.props file:
```
  podName = testlib
  summary = test lib
  srcDirs = fan/*
  depends = sys 1.0
```
Run build:
```
  fanc yourPath/pod.props
```


### Extension Methods API ###
Most Convenience methods changed to extension methods for break depends.
For example: Str.toRegex bring to the Str class depend on Regex module.
We solve it in the following:
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

