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
