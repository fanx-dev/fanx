//
// Copyright (c) 2017, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Jun 17  Matthew Giannini  Creation
//

@Js class MacroTest : Test
{
  Void testEmpty()
  {
    verifyEq("", apply(""))
    verifyEq("", apply("{{}}"))
  }

  Void testNoMacros()
  {
    verifyEq("a",  apply("a"))
    verifyEq("{",  apply("{"))
    verifyEq("}",  apply("}"))
    verifyEq("}}", apply("}}"))
    verifyEq("notAKey}}",  apply("notAKey}}"))
    verifyEq("{notAKey}}", apply("{notAKey}}"))
  }

  Void testResolve()
  {
    verifyEq("A",     apply("{{a}}"))
    verifyEq("FOO",   apply("{{foo}}"))
    verifyEq("_FOO",  apply("_{{foo}}"))
    verifyEq("_FOO_", apply("_{{foo}}_"))
    verifyEq("_FOO_BAR",  apply("_{{foo}}_{{bar}}"))
    verifyEq("_FOO_BAR_", apply("_{{foo}}_{{bar}}_"))

    // white space
    verifyEq(" ",     apply("{{ }}"))
    verifyEq(" FOO ", apply("{{ foo }}"))

    // start delimiter used inside macro
    verifyEq("_{{_", apply("_{{{{}}_"))
  }

  Void testUnterminated()
  {
    verifyErr(ParseErr#) { apply("{{") }
    verifyErr(ParseErr#) { apply("{{}") }
    verifyErr(ParseErr#) { apply("{{a") }
    verifyErr(ParseErr#) { apply("{{a}") }
  }

  Void testKeys()
  {
    verifyEq(Str[,],       keys("foo"))
    verifyEq(Str[""],      keys("{{}}"))
    verifyEq(Str[" foo "], keys("{{ foo }}"))
    verifyEq(Str["a","b","b","c"], keys("_{{a}}_{{b}}_{{b}}_{{c}}_"))
  }

  private Str apply(Str text)
  {
    Macro(text).apply { it.upper }
  }

  private Str[] keys(Str text)
  {
    Macro(text).keys
  }
}
