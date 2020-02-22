
class ParserGoldenTest : GoldenTest {
  
  const static Str separator := "\n\n///!!!!!!!!!!!!!!!!!!!!!!!\n\n"
  
//  override Void setup() {
//    super.goldenDir.delete
//  }
  
  Void testParser() {
    srcFiles := File[,]
    `res/`.toFile.walk |f|{
      if (f.isDir || f.ext != "fan") return
      echo("test:"+f.normalize)
      
      code := f.readAllStr
      runParse(code, f.parent.basename +"/"+ f.basename)
    }
  }
  
  Void runParse(Str code, Str name) {
    parser := Parser.makeSimple(code, "testPod")
    parser.parse
    
    s := StrBuf()
//    s.add(code)
    
//    s.add(separator)
    s.add(parser.log.toStr)
    
    s.add(separator)
    parser.unit.print(AstWriter(s.out))
    
    
    verifyGolden(s.toStr, name)
    
    //parser.unit
  }
}
