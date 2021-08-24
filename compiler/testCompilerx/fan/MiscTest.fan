using compilerx

class MiscTest : Test {
  Void test() {
    code := 
    Str<| 
            class Main {
                new make() 

                Str s := ""
            }
        |>
    
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fan"
    m.updateSource(file, code)
    
    m.checkError
    
    //m.context.pod.dump

    verify(m.context.log.errs.size > 0)
    verify(m.context.pod.resolveType("Main", true).slotDef("make") != null)
  }

  Void testVirtual() {
    code := 
    Str<| 
            class B {
              virtual fun foo() {}
            }
            //class A : B {
            //}
        |>
    
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fanx"
    m.updateSource(file, code)
    
    m.checkError
    //m.context.pod.dump
    verify(m.context.log.errs.size == 1)
  }

  Void testList() {
    code := 
    Str<| 
            class Main {
              fun main() {
                list: [Int] = []
                map:[Str:Int] = [:]
              }
            }
        |>
    
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fanx"
    m.updateSource(file, code)
    
    m.checkError
    //m.context.pod.dump
    verify(m.context.log.errs.size == 0)
  }

  Void testIsAs() {
    code := 
    Str<| 
            class Main {
              fun main() {
                a := "x"
                b: Int = 0
                c: Str?

                echo(c as Str?)
                echo(c as Str)
                echo(c is Str?)//error
                echo(c is Str)

                echo(b+=1)//error
                echo(++b)//error
                echo(b = 5)
              }
            }
        |>
    
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fanx"
    m.updateSource(file, code)
    
    m.checkError
    //m.context.pod.dump
    verify(m.context.log.errs.size == 3)
  }

  Void testFits() {
    code := 
    Str<| 
            class Main {
              fun main() {
                a: [Str]?
                b: [Int] = a

                f: |Int->Obj|?
                t: |Str->Obj| = f
              }
            }
        |>
    
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fanx"
    m.updateSource(file, code)
    
    m.checkError
    //m.context.pod.dump
    verify(m.context.log.errs.size == 2)
  }

  Void testFuncArgs() {
    code := 
    Str<| 
            class Main {
              fun main(f:|Obj->Obj|) {
                f(1,2)
              }
            }
        |>
    
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fanx"
    m.updateSource(file, code)
    
    m.checkError
    //m.context.pod.dump
    verify(m.context.log.errs.size == 1)
  }
}