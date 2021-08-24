using compilerx

class DebugTest : Test {
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
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.checkError
    
    m.context.pod.dump

  }
}