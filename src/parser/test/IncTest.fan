
**
** IncTest
**
class IncTest : Test
{
  Void test() {
    name := "compiler"
    file := `../${name}/pod.props`
    compiler := IncCompiler.fromProps(file.toFile).parseAll
    
    echo("podName: ${compiler.context.pod.name}")
    //echo(compiler.compiler.cunits)
    compiler.resolveAll
    //compiler.compiler.pod.dump
    
    verify(compiler.context.log.errs.size == 0)
    
    compiler.updateSourceFile(`../${name}/fan/ast/TypeDef.fan`.toFile)
    echo(compiler.context.cunits)
    compiler.resolveAll
    verify(compiler.context.log.errs.size == 0)
    
    compiler.updateSourceFile(`../${name}/fan/namespace/CNamespace.fan`.toFile)
    echo(compiler.context.cunits)
    compiler.resolveAll
    verify(compiler.context.log.errs.size == 0)
  }
}
