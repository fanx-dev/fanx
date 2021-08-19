
## Tutorial ##

### Class and Methods
Familiar C-like syntax
```
  class Person
  {
    var name: Str
    var age: Int

    //method with default parameter
    fun say(a:Str = "default") { echo("Hi $a") }

    //named constructor
    new make(name: Str, age: Int) {
      this.name = name
      this.age = age
    }
  }

  //Type Inference
  p := Person("B", 30)

  //named param
  p := Person(name:"B", age:30)

```

### Field Accessors
No more boiler plate getters and setters.
```
  class Person
  {
    var name: Str
    var age: Int {
      set { checkAge(val); &age = it }
    }
  }
```

### Hybrid Static and Dynamic Typed
the "->" operator to call a method dynamically.

```
  //static invoke
  p.age = 10
  p.say("A")

  //dynamic invoke
  p->age = 10
  p->say("A")
```

### Literals
```
  //List
  [0, 1, 2]

  //Map
  [1:"one", 2:"two"]

  //Range
  0..5    // 0 to 5
  0..<5   // 0 to 4

  //string interpolation
  "$x + $y = ${x+y}"

  //Duration
  100ms   //100 milliseconds
```

### Non-Nullable Types
A non-nullable type is guaranteed to never store the null value.
```
  var a: Str? = null //might stores null
  var b: Str  //never stores null

  //Nullable is a part of API
  fun foo(arg: Str?): Str
```

### Functional and Closures
Functions are first class objects
```
  // print 0 to 9
  10.times { echo(it) }

  //sort
  files = files.sort |a, b| { a.modified <=> b.modified }

  //iter
  ["one", "two", "three"].map { it.size }.each { echo(it) }
```

### Strong Immutability
First class support immutable class.
```
  //immutable class
  const class Str { ... }

  const p: Str       //deep immutable
  const p: StrBuf    //compile error
  let p: StrBuf //shallow immutable
```

### Thread Safe Concurrency
The actor-model concurrency.
The runtime make sure no shared mutable state between threads.
```
  actor := Actor |msg| { echo(msg) }
  actor.send("Hi")
```

### Declarative Programming
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

### Modularity
Pods are the unit of versioning deployment and namespace. They are combined together using clear dependencies.
The pod build script:
```
  podName = testlib
  summary = test lib
  version = 2.0
  srcDirs = test/,fan/
  depends = sys 1.0, std 1.0, reflect 1.0
```

### Mixins
The interface with implementations
```
  mixin Audio
  {
    abstract var volume: Int
    fun incrementVolume() { volume += 1 }
    fun decrementVolume() { volume -= 1 }
  }

  class Television : Audio
  {
    override var volume: Int  = 0
  }
```

### Generics
```
  class Foo<T> {
    var t: T? 
    fun get(): T { return t }
  }

  foo := Foo<Str>()
  foo.t = "abc"
```

### Extension method
To add methods out side the class
```
  class Whatever {
    extension static fun foo(str: Str) {
      ...
    }
  }

  //shortcut of Whatever.foo(str)
  str.foo
```

### Aspect Oriented Programming
```
  //same as bar.trap("foo", arg)
  bar~>foo(arg)
```

### Async/Await Coroutine
The C#/Javascript like async/await pattern.
```
  async fun foo(id: Int) {
    user := await getUser(id)
    image := await getImage(user.image)
    imageView.image = image
  }
```
