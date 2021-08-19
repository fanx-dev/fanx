
class SemanticTest : GoldenTest {
  
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
    
    pod := PodDef(Loc.makeUnknow, "testPod")
    m := IncCompiler(pod)
    
    file := name
    m.updateSource(file, code)
    
    m.resolveAll
    
    s := StrBuf()
//    s.add(code)
//    s.add(separator)
    s.add(m.context.log.toStr)
    
    s.add(separator)
    m.context.cunits[0].print(AstWriter(s.out))
    
    
    verifyGolden(s.toStr, name)
  }
}
