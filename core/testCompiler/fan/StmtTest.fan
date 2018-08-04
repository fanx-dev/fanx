//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Sep 06  Brian Frank  Creation
//

**
** StmtTest
**
class StmtTest : CompilerTest
{

/////////////////////////////////////////////////////////////////////////
// Return
//////////////////////////////////////////////////////////////////////////

  Void testReturn()
  {
    compile(
     "class Foo
      {
        Int a() { 7 }
        Int b(Bool b) { b ? 2 : 3 }
        Str[] c(Str[] x) { x.sort |Str a,Str b->Int| { a.size <=> b.size } }
        Void v0() { return vi0 }
        Void v1() { return vi1 }
        Void vi0() { n++ }
        Int vi1() { n++; return n }
        Int n := 0
      }")

     o := pod.types.first.make
     verifyEq(o->a, 7)
     verifyEq(o->b(true), 2)
     verifyEq(o->b(false), 3)
     verifyEq(o->c(["c", "aaa", "bb"]), ["c", "bb", "aaa"])
     o->v0; verifyEq(o->n, 1)
     o->v1; verifyEq(o->n, 2)

    verifyErrors(
      "class Foo
       {
         Int a() { echo(3.toStr); 3 }
         Void b() { 999 }
         Void c(Obj[] x) { x.sort |Obj a, Obj b->Int| { echo(3.toStr); 0 } }
       }
       ",
       [3, 28, "Not a statement",
        3, 11, "Must return a value from non-Void method",
        4, 14, "Not a statement",
        5, 65, "Not a statement",
        5, 48, "Must return a value from non-Void method",
       ])
  }

/////////////////////////////////////////////////////////////////////////
// If
//////////////////////////////////////////////////////////////////////////

  Void testIf()
  {
    code := "if (a == 0) return 1; return 2"
    verifyStmt(code, 1, 0)
    verifyStmt(code, 2, 33)

    code = "if (a == 0) { x = 1; y = 1; } return [x,y]"
    verifyStmt(code, Int?[1,1], 0)
    verifyStmt(code, Int?[null,null], 99)

    code = "if (a == 0) return 1; else return 2"
    verifyStmt(code, 1, 0)
    verifyStmt(code, 2, 33)

    code = "if (a == 0) { x = 1; y = 1; } else { x = 2; y = 2; } return [x,y]"
    verifyStmt(code, Int?[1,1], 0)
    verifyStmt(code, Int?[2,2], 9)

    code = "if (a == 0)
            {
              x = 10
              if (b == 0) y = 10
              else y = 99
            }
            else if (a == 1)
            {
              x = 11
              if (b == 1) y = 11
            }
            else
            {
              x = 99
            }
            return [x, y]"
    verifyStmt(code, Int?[10, 10],   0, 0)
    verifyStmt(code, Int?[10, 99],   0, 1)
    verifyStmt(code, Int?[11, null], 1, 0)
    verifyStmt(code, Int?[11, 11],   1, 1)
    verifyStmt(code, Int?[99, null], 2, 0)

    code = "if (a == 2 || b == 3)
              return 77
            else
              return 88"
    verifyStmt(code, 88, 0, 0)
    verifyStmt(code, 77, 2, 0)
    verifyStmt(code, 77, 0, 3)
    verifyStmt(code, 77, 2, 3)

    code = "if (a == 2 || b == 3 || c == 4)
              return 77
            else
              return 88"
    verifyStmt(code, 88, 0, 0, 0)
    verifyStmt(code, 77, 2, 0, 0)
    verifyStmt(code, 77, 0, 3, 0)
    verifyStmt(code, 77, 0, 0, 4)
    verifyStmt(code, 77, 2, 0, 4)
    verifyStmt(code, 77, 2, 3, 0)
    verifyStmt(code, 77, 2, 3, 4)

    code = "if (a == 2 && b == 3)
              return 77
            else
              return 88"
    verifyStmt(code, 88, 0, 0)
    verifyStmt(code, 88, 2, 0)
    verifyStmt(code, 88, 0, 3)
    verifyStmt(code, 77, 2, 3)

    code = "if (a == 2 && b == 3 && c == 4)
              return 77
            else
              return 88"
    verifyStmt(code, 88, 0, 0, 0)
    verifyStmt(code, 88, 2, 0, 0)
    verifyStmt(code, 88, 0, 3, 0)
    verifyStmt(code, 88, 0, 0, 4)
    verifyStmt(code, 88, 2, 0, 4)
    verifyStmt(code, 88, 0, 3, 4)
    verifyStmt(code, 88, 2, 3, 0)
    verifyStmt(code, 77, 2, 3, 4)

    code = "if (a == 2 || b == 3 && c == 4)
              return 77
            else
              return 88"
    verifyStmt(code, 88, 0, 0, 0)
    verifyStmt(code, 77, 2, 0, 0)
    verifyStmt(code, 88, 0, 3, 0)
    verifyStmt(code, 88, 0, 0, 4)
    verifyStmt(code, 77, 2, 0, 4)
    verifyStmt(code, 77, 0, 3, 4)
    verifyStmt(code, 77, 2, 3, 0)
    verifyStmt(code, 77, 2, 3, 4)

    code = "x := 88
            if (a == 2 || b == 3 && c == 4)
              x = 77
            return x"
    verifyStmt(code, 88, 0, 0, 0)
    verifyStmt(code, 77, 2, 0, 0)
    verifyStmt(code, 88, 0, 3, 0)
    verifyStmt(code, 88, 0, 0, 4)
    verifyStmt(code, 77, 2, 0, 4)
    verifyStmt(code, 77, 0, 3, 4)
    verifyStmt(code, 77, 2, 3, 0)
    verifyStmt(code, 77, 2, 3, 4)

  }

  Void testIfStmtBoolLiterals()
  {
    // if(true) and if(false) optimized away
    compile(
       "class Foo
        {
          static Int a()
          {
            x := 3
            if (true) x = 4
            return x
          }

          static Int b()
          {
            x := 2
            if (true) x = 6
            else x = 8
            return x
          }

          static Int c()
          {
            x := 10
            if (false) x = 5
            return x
          }

          static Int d()
          {
            x := 99
            if (false) x = 15
            else x = 76
            return x
          }
        }")

    // compiler.fpod.dump
    t := pod.types[0]
    verifyEq(t.method("a").call, 4)
    verifyEq(t.method("b").call, 6)
    verifyEq(t.method("c").call, 10)
    verifyEq(t.method("d").call, 76)
  }

//////////////////////////////////////////////////////////////////////////
// Throw
//////////////////////////////////////////////////////////////////////////

  Void testThrow()
  {
    verifyErr(IOErr#) { verifyStmt("throw IOErr.make", null) }
  }

//////////////////////////////////////////////////////////////////////////
// For
//////////////////////////////////////////////////////////////////////////

  Void testFor()
  {
    code :=
     "r := Int[,]
      for (i:=0; i<3; ++i)
        r.add(i)
       return r"
    verifyStmt(code, [0, 1, 2])

    code =
     "r := Int[,]
      for (i:=0; i<3; )
        r.add(++i)
      return r"
    verifyStmt(code, [1, 2, 3])

    code =
     "r := Int[,]
      i := 0
      for (; i<3;)
        r.add(i++)
      return r"
    verifyStmt(code, [0, 1, 2])

    code =
     "r := Int[,]
      i := 0
      for (;;)
      {
        r.add(i++)
        if (i > 3) break
      }
      return r"
    verifyStmt(code, [0, 1, 2, 3])

    code =
     "r := Int[,]
      for (i:=0; i<5; ++i)
      {
        if (i % 2 == 1) continue
        r.add(i)
      }
      return r"
    verifyStmt(code, [0, 2, 4])

    code =
     "r := \"\"
      for (i:=0; i<6; ++i)
      {
        r += \"{\"
        for (j:=0; j<i; ++j)
        {
          if (j == 1) continue
          if (i == 4) break
          r += j.toStr
        }
        r += \"}\"
        if (i < 5) continue
        r += \"x\"
      }
      return r"
    verifyStmt(code, "{}{0}{0}{02}{}{0234}x")
  }

//////////////////////////////////////////////////////////////////////////
// While
//////////////////////////////////////////////////////////////////////////

  Void testWhile()
  {
    code :=
     "r := Int[,]
      i := 0
      while (i<4)
       r.add(i++)
      return r"
    verifyStmt(code, [0, 1, 2, 3])

    code =
     "r := Int[,]
      i := 0
      while (true)
      {
        r.add(i++)
        if (i >= 2) break
      }
      return r"
    verifyStmt(code, [0, 1])

    code =
     "r := Int[,]
      i := 0
      while (i<4)
      {
        i++
        if (i == 2) continue
        r.add(i)
      }
      return r"
    verifyStmt(code, [1, 3, 4])

    code =
     "r := Int[][,]
      i := 0
      while (true)
      {
        i++
        if (i == 2) continue
        j := 0
        x := Int[,]
        while (j < i)
        {
          if (j == 2) { j++; continue }
          x.add(j++)
        }
        r.add(x)
        if (i == 4) break
      }
      return r"
    verifyStmt(code, [[0], [0,1], [0,1,3]])
  }

//////////////////////////////////////////////////////////////////////////
// Switch
//////////////////////////////////////////////////////////////////////////

  Void testTableSwitch()
  {
    code :=
     "switch (a)
      {
        case 0: return 100
        case 1: return 101
        case 2: return 102
      }
      return -1"
    verifyStmt(code, -1,  -1)
    verifyStmt(code, 100, 0)
    verifyStmt(code, 101, 1)
    verifyStmt(code, 102, 2)
    verifyStmt(code, -1,  3)
    verifyEq(compiler.types[0].methodDef("func").code.stmts[1]->isTableswitch, true)

    code =
     "switch (a)
      {
        case 10:
        case 11: return 101
        case 12:
        case 13: return 103
        case 15: return 105
        case 16:
        default: return 99
      }"
    verifyStmt(code, 99,  0)
    verifyStmt(code, 101, 10)
    verifyStmt(code, 101, 11)
    verifyStmt(code, 103, 12)
    verifyStmt(code, 103, 13)
    verifyStmt(code, 99,  14)
    verifyStmt(code, 105, 15)
    verifyStmt(code, 99,  16)
    verifyStmt(code, 99,  17)
    verifyEq(compiler.types[0].methodDef("func").code.stmts[1]->isTableswitch, true)

    code =
     "weekday := (Weekday)Weekday.vals[a]
      switch (weekday)
      {
        case Weekday.sun:
        case Weekday.sat: return 2
        case Weekday.fri: return 1
      }
      return 0"
    verifyStmt(code, 2, 0)
    verifyStmt(code, 0, 1)
    verifyStmt(code, 0, 4)
    verifyStmt(code, 1, 5)
    verifyStmt(code, 2, 6)
    verifyEq(compiler.types[0].methodDef("func").code.stmts[2]->isTableswitch, true)
  }

  Void testSwitchInternalEnum()
  {
   compile(
     "enum class Foo { a, b, c }
      class Bar
      {
        static Int f(Foo foo)
        {
          switch (foo)
          {
            case Foo.a: return 10
            case Foo.c: return 12
            default:    return 99
          }
        }
      }")

    foo := pod.types[0]
    bar := pod.types[1]
    verifyEq(bar.method("f").call(foo.field("a").get), 10)
    verifyEq(bar.method("f").call(foo.field("b").get), 99)
    verifyEq(bar.method("f").call(foo.field("c").get), 12)
    verifyEq(compiler.types[1].methodDef("f").code.stmts[0]->isTableswitch, true)
  }

  Void testEqualsSwitch()
  {
    // empty switch
    compile(
     "class Foo
      {
        static Int f(Str s)
        {
          switch (s)
          {
          }
          return '?'
        }
      }")

    f := pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[0]->isTableswitch, false)
    verifyEq(f.call("a"), '?')
    verifyEq(f.call(null), '?')

    // return exit, no default
    compile(
     "class Foo
      {
        static Int f(Str? s)
        {
          switch (s)
          {
            case \"a\": return 'a'
            case \"b\": return 'b'
          }
          return '?'
        }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[0]->isTableswitch, false)
    verifyEq(f.call("a"), 'a')
    verifyEq(f.call("b"), 'b')
    verifyEq(f.call("c"), '?')
    verifyEq(f.call(null), '?')

    // return exit, with default, multiple cases
    compile(
     "class Foo
      {
        static Int f(Str? s)
        {
          switch (s)
          {
            case \"a\":
            case \"A\": return 'a'
            case \"b\":
            case \"B\": return 'b'
            case \"c\":
            case \"C\":
            default: return '?'
          }
        }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[0]->isTableswitch, false)
    verifyEq(f.call("a"), 'a')
    verifyEq(f.call("A"), 'a')
    verifyEq(f.call("b"), 'b')
    verifyEq(f.call("B"), 'b')
    verifyEq(f.call("c"), '?')
    verifyEq(f.call("C"), '?')
    verifyEq(f.call(null), '?')

    // no exit, no default
    compile(
     "class Foo
      {
        static Int f(Str s)
        {
          x := '?'
          switch (s)
          {
            case \"a\": x = 'a'
            case \"b\": x = 'b'
          }
          return x
        }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[1]->isTableswitch, false)
    verifyEq(f.call("a"), 'a')
    verifyEq(f.call("b"), 'b')
    verifyEq(f.call("c"), '?')
    //verifyEq(f.call(null), '?')

    // no exit, with default
    compile(
     "class Foo
      {
        static Int? f(Str? s)
        {
          Int? x := null
          switch (s)
          {
            case \"a\": x = 'a'
            case \"b\": x = 'b'
            default: x = '?'
          }
          return x
        }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[1]->isTableswitch, false)
    verifyEq(f.call("a"), 'a')
    verifyEq(f.call("b"), 'b')
    verifyEq(f.call("c"), '?')
    verifyEq(f.call(null), '?')

    // int no-table
    compile(
     "class Foo
      {
        static Int f(Int x)
        {
          switch (x)
          {
            case zero(): return 100
            case one():  return 101
          }
          return -1
        }

        static Int zero() { return 0 }
        static Int one()  { return 1 }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[0]->isTableswitch, false)
    verifyEq(f.call(0), 100)
    verifyEq(f.call(1), 101)
    verifyEq(f.call(2), -1)

    // int? no-table
    compile(
     "class Foo
      {
        static Int f(Int? x)
        {
          switch (x)
          {
            case zero(): return 100
            case one():  return 101
          }
          return -1
        }

        static Int zero() { return 0 }
        static Int? one()  { return 1 }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[0]->isTableswitch, false)
    verifyEq(f.call(0), 100)
    verifyEq(f.call(1), 101)
    verifyEq(f.call(2), -1)
    verifyEq(f.call(null), -1)

    // torture test
    compile(
     "class Foo
      {
        static Obj? f(Obj? obj)
        {
          Obj? x := null
          switch (obj)
          {
            case \"a\":
            case \"A\":
              return 'a'
            case Str#:
              return \"Str type!\"
            case zero():
              x = 0
          }
          return x
        }

        static Int zero() { return 0 }
      }")

    f = pod.types[0].method("f")
    verifyEq(compiler.types[0].methodDef("f").code.stmts[1]->isTableswitch, false)
    verifyEq(f.call("a"), 'a')
    verifyEq(f.call("A"), 'a')
    verifyEq(f.call(Str#), "Str type!")
    verifyEq(f.call(Int#), null)
    verifyEq(f.call(0), 0)
    verifyEq(f.call(null), null)
  }

//////////////////////////////////////////////////////////////////////////
// Try/Catch
//////////////////////////////////////////////////////////////////////////

  Void testTryCatch()
  {
    code :=
     "try
      {
        x = 1
        throw IOErr.make
        x = 2
      }
      catch
      {
        y = 1
      }
      return [x,y]"
    verifyStmt(code, Int?[1,1])

    code =
     "try
      {
        if (a == 1) throw IOErr.make
        if (a == 2) throw ArgErr.make
        if (a == 3) throw ReadonlyErr.make
        return 0
      }
      catch (IOErr e) { return 10 }
      catch (ArgErr e) { return 11 }
      catch { return 12 }"
    verifyStmt(code, 0, 99)
    verifyStmt(code, 10, 1)
    verifyStmt(code, 11, 2)
    verifyStmt(code, 12, 3)
  }

//////////////////////////////////////////////////////////////////////////
// Try/Finally
//////////////////////////////////////////////////////////////////////////

  Void testTryFinally1()
  {
    compile(
     "class Foo
      {
        static Int[] f(Int[] r, Int? a)
        {
          r.add(0)
          try
          {
            r.add(a+1)
          }
          finally
          {
            r.add(99)
          }
          return r
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifySame(t.method("f").call(r, 2), r)
    verifyEq(r, [0, 3, 99])

    r = Int[,]
    verifyErr(NullErr#) { t.method("f").call(r, null) }
    verifyEq(r, [0, 99])
  }

  Void testTryFinally2()
  {
    compile(
     "class Foo
      {
        static Int[] f(Int[] r, Bool b)
        {
          r.add(0)
          try
          {
            r.add(1)
            if (b) throw ArgErr.make
            r.add(2)
          }
          finally
          {
            r.add(3)
          }
          r.add(4)
          return r
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifySame(t.method("f").call(r, false), r)
    verifyEq(r, [0, 1, 2, 3, 4])

    r = Int[,]
    verifyErr(ArgErr#) { t.method("f").call(r, true) }
    verifyEq(r, [0, 1, 3])
  }

  Void testTryFinally3()
  {
    compile(
     "class Foo
      {
        static Int[] f(Int[] r)
        {
          r.add(0)
          try
          {
            r.add(1)
            return r
          }
          finally
          {
            r.add(2)
          }
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifySame(t.method("f").call(r), r)
    verifyEq(r, [0, 1, 2])
  }

  Void testTryFinally4()
  {
    compile(
     "class Foo
      {
        static Int[] f(Int[] r)
        {
          r.add(0)
          try
          {
            r.add(1)
            try
            {
              return r.add(2)
            }
            finally
            {
              r.add(3)
            }
            return r.add(4)
          }
          finally
          {
            r.add(5)
          }
          return r.add(6)
        }
      }")
    t := pod.types.first

    // verify one $return temp was generated
    verifyEq(compiler.types.first.methodDef("f").vars.size, 2)
    verifyEq(compiler.types.first.methodDef("f").vars[1].name, "\$return")

    r := Int[,]
    verifySame(t.method("f").call(r), r)
    verifyEq(r, [0, 1, 2, 3, 5])
  }

  Void testTryFinally5()  // same as testTryFinally4 but Void
  {
    compile(
     "class Foo
      {
        static Void f(Int[] r)
        {
          r.add(0)
          try
          {
            r.add(1)
            try
            {
              r.add(2)
              return
            }
            finally
            {
              r.add(3)
            }
            r.add(4)
            return
          }
          finally
          {
            r.add(5)
          }
          return
        }
      }")
    t := pod.types.first

    // verify no $return temp was generated
    verifyEq(compiler.types.first.methodDef("f").vars.size, 1)

    r := Int[,]
    verifySame(t.method("f").call(r), null)
    verifyEq(r, [0, 1, 2, 3, 5])
  }

  Void testTryFinally6()
  {
    compile(
     "class Foo
      {
        static Int[] f(Int[] r)
        {
          r.add(0)
          for (i:=1; i<=3; ++i)
          {
            try
            {
              if (i == 3) throw ArgErr.make
              r.add(10+i)
            }
            finally
            {
              r.add(100+i)
            }
          }
          return r.add(1)
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifyErr(ArgErr#) { t.method("f").call(r) }
    verifyEq(r, [0, 11, 101, 12, 102, 103])
  }

  Void testTryFinally7()
  {
    compile(
     "class Foo
      {
        static Int[] f(Int[] r)
        {
          r.add(0)
          for (i:=1; true; ++i)
          {
            try
            {
              if (i % 2 == 0) continue
              if (i == 5) break
              r.add(i)
            }
            finally
            {
              r.add(100+i)
            }
          }
          return r.add(99)
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifySame(t.method("f").call(r), r)
    verifyEq(r, [0, 1, 101, 102, 3, 103, 104, 105, 99])
  }

  Void testTryFinally8()
  {
    compile(
     "class Foo
      {
        static Void f(Int[] r)
        {
          try
          {
            try
            {
              r.add(0)
              for (i:=1; true; ++i)
              {
                try
                {
                  try
                  {
                    if (i % 2 == 0) continue
                    if (i == 5) break
                    r.add(i)
                  }
                  finally
                  {
                    r.add(100+i)
                  }
                }
                finally
                {
                  r.add(99)
                }
              }
              r.add(999)
            }
            finally
            {
              r.add(9999)
            }
          }
          finally
          {
            r.add(99999)
          }
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifySame(t.method("f").call(r), null)
    verifyEq(r, [0, 1, 101, 99, 102, 99, 3, 103, 99, 104, 99, 105, 99, 999, 9999, 99999])
  }

//////////////////////////////////////////////////////////////////////////
// Try/Catch/Finally
//////////////////////////////////////////////////////////////////////////

  Void testTryCatchFinally1()
  {
    compile(
     "class Foo
      {
        static Int f(Int[] r, Bool raise)
        {
          r.add(0)
          try
          {
            r.add(1)
            if (raise) throw ArgErr.make
            r.add(2)
            return 2
          }
          catch
          {
            r.add(3)
            return 3
          }
          finally
          {
            r.add(4)
          }
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifyEq(t.method("f").call(r, false), 2)
    verifyEq(r, [0, 1, 2, 4])

    r = Int[,]
    verifyEq(t.method("f").call(r, true), 3)
    verifyEq(r, [0, 1, 3, 4])
  }

  Void testTryCatchFinally2() // same as testTryCatchFinally2 but Void
  {
    compile(
     "class Foo
      {
        static Void f(Int[] r, Bool raise)
        {
          r.add(0)
          try
          {
            r.add(1)
            if (raise) throw ArgErr.make
            r.add(2)
          }
          catch
          {
            r.add(3)
          }
          finally
          {
            r.add(4)
          }
        }
      }")
    t := pod.types.first

    r := Int[,]
    verifySame(t.method("f").call(r, false), null)
    verifyEq(r, [0, 1, 2, 4])

    r = Int[,]
    verifySame(t.method("f").call(r, true), null)
    verifyEq(r, [0, 1, 3, 4])
  }

  Void testTryCatchFinally3()
  {
    compile(
     "class Foo
      {
        static Void f(Int[] r, Err? err)
        {
          r.add(0)
          try
          {
            r.add(1)
            if (err != null) throw err
            r.add(2)
          }
          catch
          {
            r.add(3)
            throw err
            r.add(4)
          }
          finally
          {
            r.add(99)
          }
        }
      }")
    t := pod.types.first

    r := Int[,]
    t.method("f").call(r, null)
    verifyEq(r, [0, 1, 2, 99])

    r = Int[,]
    verifyErr(IndexErr#) { t.method("f").call(r, IndexErr.make) }
    verifyEq(r, [0, 1, 3, 99])

    r = Int[,]
    verifyErr(IOErr#) { t.method("f").call(r, IOErr.make) }
    verifyEq(r, [0, 1, 3, 99])
  }

  Void testTryCatchFinally4()
  {
    compile(
     "class Foo
      {
        static Void f(Int[] r, Err? err)
        {
          r.add(0)
          try
          {
            r.add(1)
            if (err != null) throw err
            r.add(2)
          }
          catch (IOErr e)
          {
            r.add(3)
            throw e
            r.add(4)
          }
          catch
          {
            r.add(5)
            throw err
            r.add(6)
          }
          finally
          {
            r.add(99)
          }
        }
      }")
    t := pod.types.first

    r := Int[,]
    t.method("f").call(r, null)
    verifyEq(r, [0, 1, 2, 99])

    r = Int[,]
    verifyErr(IOErr#) { t.method("f").call(r, IOErr.make) }
    verifyEq(r, [0, 1, 3, 99])

    r = Int[,]
    verifyErr(IndexErr#) { t.method("f").call(r, IndexErr.make) }
    verifyEq(r, [0, 1, 5, 99])
  }

  Void testTryCatchFinally5() // torture test
  {
    compile(
     "class Foo
      {
        static Void f(Int[] r)
        {
          r.add(0)
          try
          {
            for (i:=0; i<5; ++i)
            {
              r.add(10+i)
              try
              {
                try
                {
                  if (i == 2) throw IOErr.make
                  r.add(20+i)
                }
                finally
                {
                  r.add(30+i)
                }

                try
                {
                  xxx := 555
                }
                finally
                {
                  r.add(300+i)
                }
              }
              catch
              {
                try
                {
                  r.add(900+i)
                  throw IOErr.make
                  r.add(910+i)
                }
                catch (IOErr e)
                {
                  r.add(920+i)
                }
                finally
                {
                  r.add(930+i)
                }
                break
              }
              r.add(50+i)
            }
          }
          finally
          {
            r.add(99)
          }
          r.add(999)
        }
      }")
    t := pod.types.first

    r := Int[,]
    t.method("f").call(r)
    verifyEq(r, [0, 10, 20, 30, 300, 50, 11, 21, 31, 301, 51, 12, 32, 902, 922, 932, 99, 999])
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void verifyStmt(Str code, Obj? result, Obj? a := null, Obj? b := null, Obj? c := null)
  {
    compile(
     "class Foo
      {
        new make() { return }

        Obj? func(Int? a, Int? b, Int? c)
        {
          x = y = z = null
          $code
        }

        Int? x
        Int? y
        Int? z
      }")

     t := pod.types.first
     instance := t.method("make").call
     actual := t.method("func").callList([instance, a, b, c])
     verifyEq(actual, result)
   }

}