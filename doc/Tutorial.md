
# Tutorial #

Class
========
```
  class Person {
    Str name
    Int age

    //Constructor use the new keyword
    new make(Str name, Int age) {
      this.name = name
      this.age = age
    }
  }
  //Type Inference
  p := Person.make("A", 25)
  p := Person("B", 30) //shortcut

  //A struct type is a value type
  const struct class Point {
    const Int x
    const Int y
  }
  p := Point{ x=1; y=2 }

```

Fields And Methods
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
  }

  p.age = 10
  p.say("A")
  p->say("A") //dynamic call
```


Immutability
========
Strong immutable
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


Closures
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
    extension static Str[] splitBy(Str str, Str sp, Int max := Int.maxVal) {
      ...
    }
  }

  //shortcut of Whatever.splitBy(str, "::", 3)
  fs := str.splitBy("::", 3)
```