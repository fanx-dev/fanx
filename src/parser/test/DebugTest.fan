
class DebugTest : Test {
  Void test() {
    code := 
    """ using std
    
        virtual class Base<V> {
          virtual This pos() { this }
        }
    
        internal class Main<X> : Base<X>
        {
          override This pos() { this }
          Void bar() {
            x := pos
            echo(x)
          }
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