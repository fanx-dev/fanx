using compilerx
**
** IncTest
**
class IncTest : Test
{
  Void test() {
    name := "compilerx"
    file := `../${name}/pod.props`
    compiler := IncCompiler.fromProps(file.toFile).parseAll
    
    verify(compiler.context.log.errs.size == 0)

    echo("podName: ${compiler.context.pod.name}")
    //echo(compiler.compiler.cunits)
    compiler.checkError
    //compiler.compiler.pod.dump

    echo("================================================")
    
    verify(compiler.context.log.errs.size == 0)
    
    compiler.updateSourceFile(`../${name}/fan/ast/TypeDef.fan`.toFile.normalize)
    echo(compiler.context.cunits)
    compiler.checkError
    verify(compiler.context.log.errs.size == 0)
    
    compiler.updateSourceFile(`../${name}/fan/namespace/CNamespace.fan`.toFile.normalize)
    echo(compiler.context.cunits)
    compiler.checkError
    verify(compiler.context.log.errs.size == 0)
  }
}
