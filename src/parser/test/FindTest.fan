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
               Void foo(Int a, Int b) {
                 x := a + b
                 echo(x)
               }
            }
        |>
    node := findAt(code, 80)
    echo(node)
    verifyType(node, LocalVarExpr#)
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
    node := findAt(code, 53)
    verifyType(node, CType#)
    node2 := findAt(code, 57)
    verifyType(node2, CallExpr#)
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
    node := findAt(code, 56)
    verifyType(node, UnknownVarExpr#)
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
    node := findAt(code, 78)
    verifyType(node, FieldExpr#)
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
    node := findAt(code, 35)
    verifyType(node, CType#)
  }
  
  Void test6() {
    code := 
    Str<| 
            class Foo {
               Void main()
               {
                  b := Foo()
                  echo(b)
               }
            }
        |>
    node := findAt(code, 58)
    verifyType(node, CType#)
  }
  
  Void test7() {
    code := 
    Str<| 
            enum class Foo {
               red, green, blue
               Void main()
               {
                  b := Foo.green
                  echo(b)
               }
            }
        |>
    node := findAt(code, 85)
    verifyType(node, CType#)
    node2 := findAt(code, 90)
    verifyType(node2, FieldExpr#)
  }
  
  Void test8() {
    code := 
    Str<| 
            class Foo {
               Void foo() {}
               Void main()
               {
                  foo()
               }
            }
        |>
    node := findAt(code, 73)
    verifyType(node, CallExpr#)
  }
  
  private CNode findAt(Str code, Int pos) {
    pod := PodDef(Loc.makeUninit, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.resolveAll
    //m.compiler.pod.dump
    
    m.compiler.pod.units.each |u| {
      u.printTree()
    }
    unit := m.compiler.pod.units.vals.first
    node := unit.findAt(Loc.make("", 0, 0, pos))
    return node
  }
}
