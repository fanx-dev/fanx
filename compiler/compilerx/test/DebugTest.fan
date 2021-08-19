
class DebugTest : Test {
  Void test() {
    code := 
    Str<| 
            class Main {
                new make()

                Str s := ""
            }
        |>
    
    
    pod := PodDef(Loc.makeUninit, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.resolveAll
    
    m.context.pod.dump
  }
}