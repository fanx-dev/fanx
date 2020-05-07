

## Quick Start

### Installing

* [Download](https://github.com/chunquedong/fanx/releases) the latest build
* [IDE](https://github.com/fanx-dev/fanIDE)

### Setup
1. Ensure "{home}/bin" is in your path
2. Fantom launcher:
   - Unix: "bin/fan" bash script
   - Windows: "bin/fan.exe" executable
3. Verify setup "fan -version"

For further information see [Setup](Setup.md)

### Hello World
The hello.fan file:
```
  class Hello {
  	Void main() { echo("Hello World") }
  }
```

Run:
```
  fan hello.fan
```

### Hello World GUI
```
using vaseGui

class HelloTest
{
  static Void main() {
    root := Frame {
      Button {
        text = "Press Me"
        onClick {
          Toast("Hello World").show(it)
        }
      },
    }
    root.show
  }
}
```

### Hello World Web
File './public/hello.fan':
```

using slanWeb

class Hello : SlanWeblet
{
  Void hi()
  {
    setContentType("html")
    res.out.print("<h2>Hello World!</h2>")
  }
}
```
run server:
```
fan slanWeb -resPath public/
```
You should be able to hit http://localhost:8080/ with your browser!



### API Docs ###
generate the HTML docs
```
  fan compilerDoc -all
```

This will generate the HTML docs for all the pods found in your local working environment.



### Learning Fanx

* [Index](Index.md)
* [Tutorial](Tour.md)
