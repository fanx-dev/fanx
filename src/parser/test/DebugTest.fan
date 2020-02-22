
class DebugTest : Test {
  Void test() {
    code := 
    """ 
        class Foo
        {
          Obj a() { return [] }
          Obj b() { Int x = 4 }
          Obj c() { return Str[:] }
          Obj d() { return a as GooGoo }
          Obj e() { return a is Kaggle }
        }
        """
    
    
    pod := PodDef(Loc.makeUninit, "testPod")
    m := IncCompiler(pod)
    
    file := "testFile"
    m.updateSource(file, code)
    
    m.resolveAll
    
    m.compiler.pod.dump
  }
}