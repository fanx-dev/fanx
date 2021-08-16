
**
** IncTest
**
class IncTest : Test
{
  Void test() {
    name := "compiler"
    file := `../${name}/pod.props`
    compiler := IncCompiler.fromProps(file.toFile).parseAll
    
    echo("podName: ${compiler.compiler.pod.name}")
    //echo(compiler.compiler.cunits)
    compiler.resolveAll
    //compiler.compiler.pod.dump
    
    verify(compiler.compiler.log.errs.size == 0)
    
    compiler.updateSourceFile(`../${name}/fan/ast/TypeDef.fan`.toFile)
    echo(compiler.compiler.cunits)
    compiler.resolveAll
    verify(compiler.compiler.log.errs.size == 0)
    
    compiler.updateSourceFile(`../${name}/fan/namespace/CNamespace.fan`.toFile)
    echo(compiler.compiler.cunits)
    compiler.resolveAll
    verify(compiler.compiler.log.errs.size == 0)
  }
}
