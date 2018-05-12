
# Different From Fantom #

Language Diff
=======

Generics
------
```
  class Foo<T> {
    T? t
    T get() { return t }
  }

  foo := Foo<Str>()
  foo.t = "abc"
```

Extension method
------
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

Numeric Precision
------
Support Numeric Precision by Facets
```
  Point {
    @I16 Int x
    @I16 Int y
    @U8  Int z
  }
```

Struct Type
------
A struct type is a value type
```
  const struct class Point {
    const Int x
    const Int y
  }
  p := Point{ x=1; y=2 }
```

RunTime Immutable
------
```
  rtconst Buf {
    override Bool isImmutable() { ... }
    override This toImuutable() { ... }
  }
```


Little Things
======

Light-Weight 'sys' Library
------
The Fantom sys pod divided into three pod: sys, std, reflect
They written in Fantom with little native code.

Static Namespace
------
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

Return From Void
-------
FanCore not allow return a value from Void method, except return Void.

Float Literals
-------
The Default Number is Float
```
  f := 0.1   //Float
  f := 0.2f  //Float
  f := 0.3D  //Decimal
```

Native Methods
--------
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



