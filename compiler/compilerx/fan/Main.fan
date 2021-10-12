

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

      |Str->Str|? translate := options["translate"]
      if (translate != null) {
        input.srcStr = translate(input.srcStr)
      }
    }

    compiler := IncCompiler(pod, input).run

    return compiler.context.transientPod
  }

  **
  ** Compile the script file into JS source code.
  ** See `sys::Env.compileScript` for option definitions.
  **
  static Str compileScriptToJs(Str podName, File file, [Str:Obj]? options := null)
  {
    loc := Loc.makeFile(file)
    pod := PodDef(loc, podName)
    pod.summary = "script"
    pod.version        = Version("0")

    input := CompilerInput.make
    input.includeDoc     = true
    input.isScript       = true
    input.compileJs      = true
    input.onlyJs         = true
    input.srcStr         = file.readAllStr
    input.srcStrLoc      = file.toStr

    if (options != null)
    {
      fcodeDump := options["fcodeDump"]
      if (fcodeDump == true) input.fcodeDump = true

      |Str->Str|? translate := options["translate"]
      if (translate != null) {
        input.srcStr = translate(input.srcStr)
      }
    }

    compiler := IncCompiler(pod, input).run

    if (options != null) {
      options["pod_name"] = podName
      options["pod_main"] = pod.types[0].qname
      options["pod_depends"] = pod.resolvedDepends.keys
    }

    return compiler.context.js
  }
}