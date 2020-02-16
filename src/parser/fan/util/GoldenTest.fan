
abstract class GoldenTest : Test {
  
  virtual File goldenDir() { `./goldenFile/`.toFile }
  
  virtual File goldenFile(Str? name) {
    fileName := this.typeof.name + "/" + curTestMethod.name
    if (name != null) {
      fileName += "/" + name
    }
   
    file := goldenDir + (fileName+".golden").toUri
    file.parent.create
    return file
  }
  
  Void verifyGolden(Str data, Str? name := null) {
    
    file := goldenFile(name)
    if (!file.exists) {
      file.open { it.writeChars(data) }.close
      echo("please run again")
      return
    }
    
    content := file.readAllStr
    
    verify(data == content, file.toStr)
  }
}
