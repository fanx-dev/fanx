

class ParserTest : Test {
  
  Void test() {
    code := Str<|//
                  using compiler
                  
                  **
                  ** Abstract base with useful utilities common to compiler tests.
                  **
                  abstract class CompilerTest : Test
                  {
                  
                  //////////////////////////////////////////////////////////////////////////
                  // Methods
                  //////////////////////////////////////////////////////////////////////////
                  
                  
                    Void compile(Str[] src, |CompilerInput in|? f := null)
                    {
                    }
                   }
       |>
    
    doParse(code)
  }
  
  private CompilationUnit doParse(Str code, Bool err := false) {
    parser := Parser.makeSimple(code, "test")
    parser.parse
    
    echo(parser.unit.types)
    echo(parser.parserSupport.errs)
    verifyEq(parser.parserSupport.errs.size > 0, err)
    
    parser.unit.dump
    
    return parser.unit
  }
}

