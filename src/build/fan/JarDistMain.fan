
class JarDistMain
{
  **
  ** mini build for boost
  **
  virtual Int main(Str[] args)
  {
    if (args.size < 1) {
      echo("Usage:  padName1,podName2 manMethod")
      return -1
    }

    build := BuildPod()
    // scriptFile = args.last.toUri.toFile.normalize
    // props := scriptFile.in.readProps
    // parse(props)
    //echo(build.scriptFile)
    
    dist := JarDist(build)
    dist.podNames = args[0].split(',')
    podName := dist.podNames[0]
    dist.outFile = `./${podName}.jar`.toFile.normalize

    dist.mainMethod = args.size > 1 ? args[1]  : "${podName}::Main.main"
    dist.run
    return 0
  }
}