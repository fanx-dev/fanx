using compilerx

class SemanticTest : GoldenTest {
  
  // const static Str separator := "\n\n///!!!!!!!!!!!!!!!!!!!!!!!\n\n"
  
//  override Void setup() {
//    super.goldenDir.delete
//  }
  
  Void testParser() {
    count := 0
    pass := 0
    fails := [,]

    srcFiles := File[,]
    `res/`.toFile.walk |f|{
      if (f.isDir || f.ext != "fan") return
      //if (f.toStr.find("res/enum/testErrors2.fan") == -1) return
      echo("test:"+f.normalize)
      
      code := f.readAllStr
      ++count
      try {
        runParse(code, f.parent.basename +"/"+ f.basename)
        ++pass
      }
      catch (Err e) {
        fails.add(f)
        e.trace
      }
    }

    echo("GoldenTest:pass:$pass/$count, fails:")
    fails.each { echo("    $it") }
  }
  
  Void runParse(Str code, Str name) {
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    m.context.input.isScript = true
    
    file := name
    m.updateSource(file, code)
    
    m.checkError
    
    s := StrBuf()
//    s.add(code)
//    s.add(separator)
    m.context.log.errs.each { s.add(it).add("\n") }

    verifyGolden(s.toStr, name)
  }
}
