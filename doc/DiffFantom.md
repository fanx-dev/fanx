
## Differences from Fantom ##

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
- Modern Style
- Static Namespace
- Primitive and Array type
- Named Param
- Virtual Class
- Unicode Identifier
- Float Literals Enhance
- Build Script Enhance
- Portable Library


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

### Modern Style
Written type after name
```
  class Person {
    var age: Int
    let name: Str

    new make(n: Str) {
      name = n
    }

    fun foo() : Str {
      return name
    }

    static fun main() {
      p : Person = Person("pick")
      s := p.foo
      echo(s)
    }
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

[MoreDiff](https://github.com/chunquedong/fanx/blob/master/doc/MoreDiff.md)


