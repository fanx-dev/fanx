using compilerx

class MiscTest : Test {

  IncCompiler compile(Str code) {
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile.fanx"
    m.updateSource(file, code)
    
    m.checkError
    return m
  }

  Void test() {
    code := 
    Str<| 
            class Main {
                new make() 

                var s :Str = ""
            }
        |>
    
    m := compile(code)

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
    
    
    m := compile(code)
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
    
    
    m := compile(code)
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
                echo(b++)//error
                echo(b = 5)
              }
            }
        |>
    
    
    m := compile(code)
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
    
    
    m := compile(code)
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
    
    
    m := compile(code)
    verify(m.context.log.errs.size == 1)
  }

  Void testSwitch() {
    code := 
    Str<| 
            class Main {
              fun main() {
                x := 0
                switch (x) {
                  case 1:
                      echo("1")
                  case 2,4,6:
                      echo("2")
                  default:
                      echo("0")
                }
              }
            }
        |>
    
    
    m := compile(code)
    verify(m.context.log.errs.size == 0)
  }

  Void testIncrement() {
    code := 
    Str<| 
            class Main {
              fun main() {
                x := 0
                ++x
                x++
              }
            }
        |>
    
    
    m := compile(code)
    verify(m.context.log.errs.size > 0)
  }

  Void testClosureReturn() {
    code := 
    Str<| 
            class Main {
              fun main() {
                10.times |x|{ return }
              }
            }
        |>
    
    
    m := compile(code)
    verify(m.context.log.errs.size > 0)
  }

  Void testCtorChain() {
    code := 
    Str<| 
            virtual class Base {
              new makeX() {}
            }
            class Main : Base {
              new make() {
                super.makeX()
              }
            }
        |>
    
    
    m := compile(code)
    verify(m.context.log.errs.size == 0)
  }

  Void testCtorChain2() {
    code := 
    Str<| 
            virtual class Base {
              new makeX() {}
            }
            class Main : Base {
              var i :Int = 10
              new make() {
                this.make0()
              }
              new make0() {
                super.makeX()
              }
            }
        |>
    
    
    m := compile(code)
    m.context.pod.dump
    verify(m.context.log.errs.size == 0)
  }
}