// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2020-2-25 yangjiandong Creation
//

**
** FindTest
**
class FindTest : Test
{
  Void test1()
  {
    code := 
    Str<| 
            class Foo {
               Int? age
               Str? name

               Void foo(Int a, Int b) {
                 x := a + b
                 echo(x)
                 p := Foo()
                 Foo.make
               }

               Void main()
               {
                  echo(age)
                  Foo.foo(1, 2)
               }
            }
        |>
    run(code)
  }
  
  Void test2() {
    code := 
    Str<| 
            class Foo {
               Void main()
               {
                  Foo.main()
               }
            }
        |>
    run(code)
  }
  
  Void test3() {
    code := 
    Str<| 
            class Foo {
               Void main()
               {
                  "x".
               }
            }
        |>
    run(code)
  }
  
  Void test4() {
    code := 
    Str<| 
            class Foo {
               Int abc := 0
               Int main()
               {
                  return abc + 1
               }
            }
        |>
    run(code)
  }
  
  Void test5() {
    code := 
    Str<| 
            class Foo {
               Void main(Foo b)
               {
                  echo(b)
               }
            }
        |>
    run(code)
  }
  
  private Void run(Str code) {
    pod := PodDef(Loc.makeUninit, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.resolveAll
    m.compiler.pod.dump
    
    m.compiler.pod.units.each |u| {
      u.printTree()
      
      (code.size+5).times |i| {
        node := u.findAt(Loc.make("", 0, 0, i, 0))
        echo(i.toStr +"\t"+
            node.typeof + "\t" + 
            node + "\t" + 
            node.loc.offset + "," + 
            node.loc.end)
      }
    }
  }
}
