
# Tutorial #

Fields and Methods
=======
```
  class Person
  {
    Str name
    //Field Accessors
    Int age {
      set { checkAge(val); &age = it }
    }

    //method with default parameter
    Void say(Str a := "x") { echo("Hi $a") }

    //named constructor
    new make(Str name, Int age) {
      this.name = name
      this.age = age
    }
  }

  //Type Inference
  p := Person("B", 30)

```

Statically and Dynamic Typed
========
the "->" operator to call a method dynamically.

```
  //static invoke
  p.age = 10
  p.say("A")

  //dynamic invoke
  p->age = 10
  p->say("A")
```

Literals
========
```
  //List
  [0, 1, 2]
  Int[0, 1, 2]

  //Map
  [1:"one", 2:"two"]
  Int:Str[1:"one", 2:"two"]

  //Range
  0..5    // 0 to 5
  0..<5   // 0 to 4

  //string interpolation
  "$x + $y = ${x+y}"
```

Immutability
========
immutable class
```
  const class ImmutablePoint
  {
    const Int x
    const Int y
    new make(Int x, Int y) { this.x = x; this.y = y }
  }
  class MutablePoint
  {
    Int x
    Int y
    new make(Int x, Int y) { this.x = x; this.y = y }
  }

  const ImmutablePoint p
  const MutablePoint p //compile error
```

Nullable Types
========
A non-nullable type is guaranteed to never store the null value
```
  Str? a := null //might stores null
  Str b //never stores null

  //Nullable is a part of API
  Str foo(Str? arg)
```

Functional and Closures
=======
Functions are first class objects
```
  // print 0 to 9
  10.times |Int i| { echo(i) }
  10.times |i| { echo(i) }
  10.times { echo(it) }

  //sort
  files = files.sort |a, b| { a.modified <=> b.modified }
```

Declarative Programming
=======
Fantom serialization format just is a subset of Fantom source grammar.
```
  Window
  {
    title = "Demo"
    size = Size(600,600)
    GridPane
    {
      numCols = 2
      Label { text="label1" },
      EdgePane
      {
        top    = Button { text = "top" }
        left   = Button { text = "left" }
        right  = Button { text = "right" }
        bottom = Button { text = "bottom" }
        center = Button { text = "center" }
      }
    },
  }
```

Modularity
=======
Pods are the unit of versioning and deployment. They are combined together using clear dependencies.
The pod build script:
```
  podName = testlib
  summary = test lib
  version = 2.0
  srcDirs = test/,fan/
  depends = sys 1.0, std 1.0, reflect 1.0
```

Concurrency
========
The actor-model concurrency.
```
  class Bar {
    Str foo(Str str) { str+"2" }
  }

  actor := ActorProxy |->|{ Bar() }
  actor->foo("Hi")
```

Mixins
========
The interface with implementations
```
  mixin Audio
  {
    abstract Int volume
    Void incrementVolume() { volume += 1 }
    Void decrementVolume() { volume -= 1 }
  }

  class Television : Audio
  {
    override Int volume := 0
  }
```

Generics
=======
```
  class Foo<T> {
    T? t
    T get() { return t }
  }

  foo := Foo<Str>()
  foo.t = "abc"
```

Extension method
======
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

