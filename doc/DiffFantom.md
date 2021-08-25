
## Fantom Compatibility ##

### Overview ###

- Generics Type
- Extension Method
- Async/Await Coroutine
- Checked Dynamic Invoke
- Struct Type
- RunTime Immutable
- Readonly/Let keyword
- Data Class
- Initialization Assignment
- Closure Inference
- Local Return
- Static Namespace
- Primitive and Array type
- Named Param
- Virtual Class
- Unicode Identifier
- Float Literals Enhance
- Build Script Enhance
- Portable Library
- .Fanx File
- Little Things



### Generics Type ###
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

### Async/Await Coroutine ###
The C#/Javascript like async/await pattern.
```
  async Void foo(Int id) {
    user := await getUser(id)
    image := await getImage(user.image)
    imageView.image = image
  }
```

### Checked Dynamic Invoke ###
Aspect Oriented Programming by `~>` invoke
```
  //same as bar.trap("foo", arg)
  bar~>foo(arg)
```

### Struct Type ###
A struct type is a pass by value type
```
  const struct class Point {
    const Int x
    const Int y
  }
  p := Point{ x=1; y=2 }
```

### RunTime Immutable ###
To override the toImmutable methods.
```
  rtconst class Buf {
    override Bool isImmutable() { ... }
    override This toImmutable() { ... }
  }
```

### Readonly/Let keyword ###
readonly is a shallow const
```
  class Bar {
    const Str name
    readonly StrBuf buf
  }
```

### Data Class ###
Auto generate toStr, hash, make, equals, compare methods if absent.
```
  data class Point { Float x; Float y }
  p := Point(0.1, 2.0)
  echo(p)
```

### Initialization Assignment ###
```
  Str str := "Hi"
  Str str = "Hi" //both ok
  str := "Hi"
```

### Closure Inference ###
To omit the function signature if params size less than one, not only it-block.
```
  Void foo(|->| f) { f() }
  foo { echo("Hi") }
```

### Local Return ###
A new keyword 'lret' as same as 'return' but only be used in closures.
The return keyword will be deprecated in closures.
```
  list.eachWhile {
    if (it == 0) lret null
    lret it
  }
```

### Static Namespace ###
fanx allow same name static slots in inheritance.
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

### Primitive and Array type ###

More primitive type: Int8/Int16/Int32/Int64/Float32/Float64.

### Named Param ###

```
  foo(name:0, name2:1)
```

### Virtual Class ###
Class default is 'final'
```
  virtual class Base {}
```

### Unicode Identifier ###
```
  class 一个类 {
    static Void main() {
      你好 := "你好"
      echo(你好)
    }
  }
```

### Float Literals Enhance ###
The Default Number is Float
```
  f := 0.1   //Float
  f := 0.2f  //Float
  f := 0.3d  //Decimal
```


### Build Script Enhance ###
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
  fanb yourPath/pod.props
```

### Portable Library ###
The sys pod is written in Fantom with little native code.

It's more portable to write a new backend platforms.
Future targets might include C, LLVM, WebAssembly.


### .Fanx File ###
The '.fan' file is almost like Fantom. The '.fanx' file have some break changes:

#### variable declaration ####
```
  class Person {
    var age: Int
    let name: Str
    const size: Int

    new make(n: Str) {
      name = n
      size = 0
    }

    fun foo(): Person {
      p : Person = Person("pick")
      return p
    }
  }
```

#### Collection Literals  ####
not support explicit type collection literals:
```
   //old way                             new way
   Str[] names := Str[,]          --->  names: [Str] = []
   [Str:Int] map := [Str:Int][:]  --->  map: [Str:Int] = [:]
```

#### Type Cast ####
not support C-like paren cast
```
   //old way       new way
   (Str)a          a as Str / a as Str?
```

#### Compound Assignment ####
The compound assignment exper resolved type now is 'Void'.
```
    foo(a += 1)  //error
    foo(a++)     //error
    foo(a = 1)   //ok
    a++          //ok
    ++a          //not support
```

#### Final Class ####
class is final by default.
```
virtual Bar {
  virtual fun foo() {}
}
```

#### Switch Fall-through ####
```
switch (x) {
  case 1: case 2:
  ...
}

//fanx way
switch (x) {
  case 1,2:
  ...
}
```

#### Literals ####

Unsupport decimal and uri literals.


### Little Things ###

#### Return From Void ####
not allow return a value from Void method, except return a Void type.


#### More Container ####
LinkedList, Set, Tuple, ConcurrentMap, LRUCache, TreeMap and more.
```
  Tuple<Int, Str> tuple := Tuple(1, "a")
```

#### Actor Enhance ####
```
  class Bar {
    Str foo(Str str) { str+"2" }
  }

  actor := ActorProxy { Bar() }
  actor->foo("Hi")
```
```
  //ActorLocal
  static const AcotrLocal<Bar> local := ActorLocal()
```

#### New JSON Api ####
The new api support 'encoding' and 'nonstandard' options and xpath.
```
  val := JVal.readJson("""{name=["abc"]}""")
  val.xpath("name[0]")
  val->name->getAt(0)
  s := val.asStr //safe cast
  str := JVal.writeJson(val)
```

#### Extension Methods API ####
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

#### Deprecated Boxing ####
Some Fantom API return nullable Int, for example: InStrem.read(), Str.index().
To avoid int boxing, prefer -1 instead of null.

#### DateTime ####
Added TimePoint class.
All time APIs are based on millis ticks.
The Time is renamed to TimeOfDay.

#### Depend ####
The Depend class only support simple version constraint.

#### Type Erasure ####
The List.fits and Func.returns are no longer available.

#### Map ####
The Map.caseInsensitive and Map.ordered replaced by Orderedmap and CaseInsensitiveMap.

#### Static Cotr ####
The static constructor return nonNullable type.

#### Charset ####
It's more Unicode compliant.

#### More Tools ####
Lock, Lazy, SoftRef,...
```
  const Lazy<Bar> lazyBar := Lazy<Bar> { Bar() }
  bar := lazyBar.get
```

#### Closures with Resources ####
```
  outStream.use { it.print("Hi") }
  lock.sync { ... }
```

#### Assert ####
```
  assert(a == b, "error")
```

#### More Str Utils ####
Str.splitBy, Str.splitAny, Str.extract, Str.format
```
  Str.format("%s %d %f", ["Hi", 12, 0.3])
```



