

class Main
{

  static Void main(Str[] args) {
    File file := args[0].toUri.toFile
    compiler := IncCompiler.fromProps(file)
    compiler.run
  }

//////////////////////////////////////////////////////////////////////////

  **
  ** Compile the script file into a transient pod.
  ** See `sys::Env.compileScript` for option definitions.
  **
  static Pod compileScript(Str podName, File file, [Str:Obj]? options := null)
  {
    loc := Loc.makeFile(file)
    pod := PodDef(loc, podName)
    pod.summary = "script"
    pod.version        = Version("0")

    input := CompilerInput.make
    input.includeDoc     = true
    input.isScript       = true
    input.srcStr         = file.readAllStr
    input.srcStrLoc      = file.toStr

    if (options != null)
    {
      fcodeDump := options["fcodeDump"]
      if (fcodeDump == true) input.fcodeDump = true
    }

    compiler := IncCompiler(pod, input).run

    return compiler.context.transientPod
  }
}