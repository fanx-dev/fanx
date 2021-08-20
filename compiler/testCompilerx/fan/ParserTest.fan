using compilerx

class ParserTest : Test {
  Void testFine() {
    srcFiles := File[,]
    `../std/`.toFile.walk |f|{
      if (f.isDir || f.ext != "fan") return
      echo("test:"+f.normalize)
      
      code := f.readAllStr
      runParse(code, f.parent.basename +"/"+ f.basename)
    }
  }
  
  Void runParse(Str code, Str name) {
    parser := Parser.makeSimple(code, "testPod")
    parser.parse
    
    verify(parser.log.errs.size == 0)
  }
}
