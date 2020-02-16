
class LexerTest : GoldenTest {
  
  Void testLexer() {
    srcFiles := File[,]
    `res/parser/`.toFile.walk |f|{
      if (f.isDir || f.ext != "fan") return
      echo("test:"+f.normalize)
      
      code := f.readAllStr
      runLexer(code, f.parent.basename +"/"+ f.basename)
    }
  }
  
  Void runLexer(Str code, Str name) {
    support := CompilerLog()
    tokenizer := Tokenizer(support, Loc.makeUninit, code, true)
    result := tokenizer.tokenize
    
    s := StrBuf()
    s.add(result.join("\n")|t|{ t.loc.toStr + "\t\t" + t.toStr })
    s.add(ParserGoldenTest.separator)
    s.add(support.toStr)
    
    verifyGolden(s.toStr, name)
  }
}
