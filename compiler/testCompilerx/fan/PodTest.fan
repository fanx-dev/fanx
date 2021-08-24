using compilerx

class PodTest : Test {
  
  
  Void testFine() {
    parserPod("sys")
    parserPod("std")
    //parserPod("baseTest")
  }
  
  private Void parserPod(Str name) {
    file := `../../Library/${name}/pod.props`
    compiler := IncCompiler.fromProps(file.toFile).parseAll
    
    echo("podName: ${compiler.context.pod.name}")
    compiler.checkError
    //compiler.compiler.pod.dump
    
    verify(compiler.context.log.errs.size == 0)
  }
}
