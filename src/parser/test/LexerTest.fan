
class LexerTest : Test {
  
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
                  
                    Str podName()
                    {
                      curTestMethod.toStr.replace("::", "_").replace(".", "_") + "_" + podNameSuffix
                    }
                  
                    Void compile(Str src, |CompilerInput in|? f := null)
                    {
       |>
    
    doLexer(code)
  }
  
  Void testUnicode() {
    code := Str<|// 中文
                  ** 中文
                  abstract class 测试类 : Test
                  {
                  
                  //////////////////////////////////////////////////////////////////////////
                  // Methods
                  //////////////////////////////////////////////////////////////////////////
                  
                    Str 你好()
                    {
                      curTestMethod.toStr.replace("::", "_").replace(".", "_") + "_" + podNameSuffix
                    }
                  
                    Void compile(Str src, |CompilerInput in|? f := null)
                    {
       |>
    
    doLexer(code, true)
  }
                  
  private TokenVal[] doLexer(Str code, Bool err := false) {
    support := ParserSupport()
    tokenizer := Tokenizer(support, Loc.makeUninit, code, true)
    result := tokenizer.tokenize
    echo(result)
    echo(support.errs)
    
    verifyEq(support.errs.size > 0, err)
    
    return result
  }
}
