
class PodTest : Test {
  
  
  Void testFine() {
    parserPod("sys")
    parserPod("std")
    parserPod("compiler")
    parserPod("baseTest")
  }
  
  private Void parserPod(Str name) {
    file := `../${name}/pod.props`
    compiler := IncCompiler.fromProps(file.toFile)
    
    echo("podName: ${compiler.compiler.pod.name}")
    compiler.resolveAll
    //compiler.compiler.pod.dump
    
    verify(compiler.compiler.log.errs.size == 0)
  }
}
