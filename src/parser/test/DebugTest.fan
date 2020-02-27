
class DebugTest : Test {
  Void test() {
    code := 
    Str<| 
            class Foo { Str foo(Obj v) {
              line := "foo $v."
              return line } }

            class Foo2 { Str foo(Obj v) {
                      line := "foo $v. "
                      return line } }

            class Foo3 { Str foo(Obj v) {
                      line := "foo $v.123"
                      return line } }
        |>
    
    
    pod := PodDef(Loc.makeUninit, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.resolveAll
    
    m.compiler.pod.dump
  }
}