
class SemanticTest : Test {
  
  
  Void testFine() {
    file := `../std/pod.props`
    compiler := IncCompiler.fromProps(file.toFile)
    
    echo("podName: ${compiler.compiler.pod.name}")
//    compiler.compiler.pod.units.each |u| {
//      echo("file: $u.file")
//    }
    
    compiler.resolveAll
    //compiler.compiler.pod.dump
    
    verify(compiler.compiler.log.errs.size == 0)
  }
}
