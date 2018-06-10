
# Different from Fantom #

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
    extension static Void foo(Str str) {
      ...
    }
  }

  //shortcut of Whatever.foo(str)
  str.foo
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

### Portable Library ###
The sys pod is written in Fantom with little native code.

It's more portable to write a new backend platforms.
Future targets might include Objective-C for the iPhone, the LLVM, WebAssembly.

### Static Namespace ###
FanCore allow same name static slots in inheritance.
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

### Return From Void ###
FanCore not allow return a value from Void method, except return a Void type.

### Float Literals ###
The Default Number is Float
```
  f := 0.1   //Float
  f := 0.2f  //Float
  f := 0.3d  //Decimal
```

### Build Script ###
The pod.props file:
```
  podName = testlib
  summary = test lib
  version = 2.0
  srcDirs = fan/*
  depends = sys 1.0
```
Run build:
```
  fanc yourPath/pod.props
```

### Local Return (Not Implemented) ###
distinguish it from normal return

## API Different ##
See more [Api Diff](./ApiDiff.md)