

class Main
{

  static Void main(Str[] args) {
    File file := args[0].toUri.toFile
    compiler := IncCompiler.fromProps(file)
    compiler.enableAllPipelines
    compiler.run
  }

}