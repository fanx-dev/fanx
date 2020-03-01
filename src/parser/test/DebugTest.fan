
class DebugTest : Test {
  Void test() {
    code := 
    Str<| 
            class Main {
                Void main() {
                  x := 1 + 2
                  echo(x)
                }
            }
        |>
    
    
    pod := PodDef(Loc.makeUninit, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.resolveAll
    
    m.compiler.pod.dump
  }
}