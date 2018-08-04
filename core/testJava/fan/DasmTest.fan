//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Dec 12  Brian Frank  Creation
//

using compilerJava

**
** DasmTest
**
class DasmTest : Test
{

  Void test()
  {
    // read our fanx.test.InteropTest class
    DasmClass? c := null
    zip := Zip.open(Env.cur.homeDir + `lib/java/sys.jar`)
    try
      c = Dasm(zip.contents[`/fanx/test/InteropTest.class`].in).read
    finally
      zip.close

    // c.dump

    verifyEq(c.flags.isPublic, true)
    verifyEq(c.thisClass.toStr, "fanx.test.InteropTest")
    verifyEq(c.superClass.toStr, "java.lang.Object")
    verifyEq(c.interfaces, DasmType[,])
    verifyField(c, "num", "J")
    verifyField(c, "ints", "[I")
    verifyField(c, "formats", "[Ljava/text/SimpleDateFormat;")
    verifyMethod(c, "numadd", "V", ["B", "S", "I", "F"])
    verifyMethod(c, "intArray", "[I", ["I", "I"])
    verifyMethod(c, "<clinit>", "V", Str[,])
  }

  Void verifyField(DasmClass c, Str name, Str sig)
  {
    f := c.fields.find |f| { f.name == name }
    if (f == null) fail(name)
    verifyEq(f.type.sig, sig)
  }

  Void verifyMethod(DasmClass c, Str name, Str ret, Str[] params)
  {
    m := c.methods.find |m| { m.name == name }
    if (m == null) fail(name)
    verifyEq(m.returns.sig, ret)
    verifyEq(m.params.size, params.size)
    m.params.each |p, i| { verifyEq(p.sig, params[i]) }
  }

}