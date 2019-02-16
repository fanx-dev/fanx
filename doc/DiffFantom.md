
# Differences from Fantom #

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

### Readonly keyword ###
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
  fanb yourPath/pod.props
```

### Portable Library ###
The sys pod is written in Fantom with little native code.

It's more portable to write a new backend platforms.
Future targets might include C, LLVM, WebAssembly.

### More Container ###
LinkedList, Set, Tuple, ConcurrentMap, LRUCache, TreeMap and more.
```
  Tuple<Int, Str> tuple := Tuple(1, "a")
```

### New JSON Api ###
The new api support 'encoding' and 'nonstandard' options and xpath.
```
  val := JVal.readJson("""{name=["abc"]}""")
  val.xpath("name[0]")
  val->name->getAt(0)
  s := val.asStr //safe cast
  str := JVal.writeJson(val)
```

### Actor Enhance ###
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

### Primitive type ###

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

[MoreDiff](https://github.com/chunquedong/fanx/blob/master/doc/MoreDiff.md)


