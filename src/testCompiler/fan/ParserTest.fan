//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//

using compiler

**
** ParserTest
**
class ParserTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

  Void testImports()
  {
    parse(
     "using compiler::Compiler         // explicit using
      using \"compiler\"::Loc as XLoc      // as from sys
      using $podName::Int as MyInt     // as from me vs sys
      using $podName::Float            // me overrides sys
      class Foo {}
      class Env {}
      class Int {}
      class Float {}")

    verifyEq(unit.usings.size, 6)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(unit.usings[1].podName, "std")
    verifyEq(unit.usings[2].podName, "compiler")
    verifyEq(unit.usings[3].podName, "compiler")
    verifyEq(unit.usings[4].podName, "$podName")
    verifyEq(unit.usings[5].podName, "$podName")

    verifyEq(unit.usings[0].resolvedPod.name, "sys")
    verifyEq(unit.usings[2].resolvedPod.name, "compiler")
    verifyEq(unit.usings[3].resolvedPod.name, "compiler")
    verifyEq(unit.usings[4].resolvedPod.name, "$podName")
    verifyEq(unit.usings[5].resolvedPod.name, "$podName")

    verifyEq(unit.usings[2].resolvedType.qname, "compiler::Compiler")
    verifyEq(unit.usings[3].resolvedType.qname, "compiler::Loc")
    verifyEq(unit.usings[4].resolvedType.qname, "$podName::Int")
    verifyEq(unit.usings[5].resolvedType.qname, "$podName::Float")

    verifyEq(unit.importedTypes["Foo"].first.qname, "$podName::Foo")
    verifyEq(unit.importedTypes["Compiler"].first.qname, "compiler::Compiler")
    verifyEq(unit.importedTypes["XLoc"].first.qname, "compiler::Loc")

    // verify both me::Sys and sys::Sys imported
    verify(unit.importedTypes["Env"].any |CType t->Bool| { return t.qname == "std::Env" })
    verify(unit.importedTypes["Env"].any |CType t->Bool| { return t.qname == "$podName::Env" })

    // verify sys::Int vs me::Int as MyInt
    verifyEq(unit.importedTypes["Int"].size, 1)
    verifyEq(unit.importedTypes["Int"].first.qname, "sys::Int")
    verifyEq(unit.importedTypes["MyInt"].size, 1)
    verifyEq(unit.importedTypes["MyInt"].first.qname, "$podName::Int")

    // verify me::Float overrides sys::Float
    verifyEq(unit.importedTypes["Float"].size, 1)
    verifyEq(unit.importedTypes["Float"].first.qname, "$podName::Float")
  }

  Void testBadImports()
  {
    verifyErrors(
     "using sys
      using compiler::Yuck
      class Foo {}",
    [1,  1, "Duplicate using 'sys'",
     2,  1, "Type not found in pod 'compiler::Yuck'"])
  }

//////////////////////////////////////////////////////////////////////////
// Simple
//////////////////////////////////////////////////////////////////////////

  Void testSimpleClass()
  {
    parse("class Foo {}")
    //verifyEq(unit.usings.size, 2)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    true)
    verifyEq(t.isEnum,     false)
    verifyEq(t.isMixin,    false)
    verifyEq(t.isAbstract, false)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Obj")
    verifyEq(t.mixins.size, 0)
  }

  Void testSimpleEnum()
  {
    parse("enum class Foo { nil }")
    //verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    false)
    verifyEq(t.isEnum,     true)
    verifyEq(t.isMixin,    false)
    verifyEq(t.isAbstract, false)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Enum")
    verifyEq(t.mixins.size, 0)
  }

  Void testSimpleMixin()
  {
    parse("mixin Foo {}")
    //verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    false)
    verifyEq(t.isEnum,     false)
    verifyEq(t.isMixin,    true)
    verifyEq(t.isAbstract, true)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Obj")
    verifyEq(t.mixins.size, 0)
  }

  Void testDuplicateClasses()
  {
    verifyErrors(
     "class A { Void f() {} }
      class A { Void f() {} }
      class Foo {}
      mixin Foo {}
      ",
       [2, 1, "Duplicate type name 'A'",
       4, 1, "Duplicate type name 'Foo'",
       ])
   }

//////////////////////////////////////////////////////////////////////////
// Extends
//////////////////////////////////////////////////////////////////////////

  Void testClassWithExtends()
  {
    parse("class Foo : Test {}")
    //verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    true)
    verifyEq(t.isEnum,     false)
    verifyEq(t.isMixin,    false)
    verifyEq(t.isAbstract, false)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "std::Test")
    verifyEq(t.mixins.size, 0)

    parse("class Foo : std::Test {}")
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "std::Test")
    verifyEq(t.mixins.size, 0)
  }

  Void testEnumWithExtends()
  {
    verifyErrors("enum class Foo : Test { nil }",
      [1, 6, "Enum 'Foo' cannot extend class 'std::Test'"])
  }

  Void testFacetWithExtends()
  {
    verifyErrors("facet class Foo : Test {}",
      [1, 7, "Facet 'Foo' cannot extend class 'std::Test'"])
  }

  Void testMixinWithExtends()
  {
    verifyErrors("mixin Foo : Obj {}",
      [1, 1, "Mixin 'Foo' cannot extend class 'sys::Obj'"])
  }

//////////////////////////////////////////////////////////////////////////
// Mixin
//////////////////////////////////////////////////////////////////////////

/* TODO - when we have a mixin in sys...
  Void testClassWithMixin()
  {
    parse("abstract class Foo : Test, OutStream {}")
    verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    true)
    verifyEq(t.isEnum,     false)
    verifyEq(t.isMixin,    false)
    verifyEq(t.isAbstract, true)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Test")
    verifyEq(t.mixins.size, 1)
    verifyEq(t.mixins[0].qname, "sys::OutStream")
  }

  Void testClassWithMixins()
  {
    parse("abstract class Foo : OutStream, Bar {} mixin Bar {}")
    verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    true)
    verifyEq(t.isEnum,     false)
    verifyEq(t.isMixin,    false)
    verifyEq(t.isAbstract, true)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Obj")
    verifyEq(t.mixins.size, 2)
    verifyEq(t.mixins[0].qname, "sys::OutStream")
    verifyEq(t.mixins[1].qname, "$podName::Bar")
  }

  Void testEnumWithMixins()
  {
    parse("enum class Foo : Bar {nil} mixin Bar {}")
    verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    false)
    verifyEq(t.isEnum,     true)
    verifyEq(t.isMixin,    false)
    verifyEq(t.isAbstract, false)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Enum")
    verifyEq(t.mixins.size, 1)
    verifyEq(t.mixins[0].qname, "$podName::Bar")
  }

  Void testMixinWithMixins()
  {
    parse("mixin Foo : Bar, InStream {} mixin Bar {}")
    verifyEq(unit.usings.size, 1)
    verifyEq(unit.usings[0].podName, "sys")
    verifyEq(t.isClass,    false)
    verifyEq(t.isEnum,     false)
    verifyEq(t.isMixin,    true)
    verifyEq(t.isAbstract, true)
    verifyEq(t.name, "Foo")
    verifyEq(t.base.qname, "sys::Obj")
    verifyEq(t.mixins.size, 2)
    verifyEq(t.mixins[0].qname, "$podName::Bar")
    verifyEq(t.mixins[1].qname, "sys::InStream")
  }
*/

//////////////////////////////////////////////////////////////////////////
// EnumDefs
//////////////////////////////////////////////////////////////////////////

  Void testEnumDefs()
  {
    // no trailing semicolon; no args
    parse(
     "** leading comment
      enum class Foo
      {
        a,
        b,
        c
      }
      ** trailing comment
      ")

    verifyEq(t.enumDefs.size, 3)
    verifyEq(t.enumDefs[0].ordinal, 0)
    verifyEq(t.enumDefs[0].name, "a")
    verifyEq(t.enumDefs[0].ctorArgs.size, 0)
    verifyEq(t.enumDefs[1].ordinal, 1)
    verifyEq(t.enumDefs[1].name, "b")
    verifyEq(t.enumDefs[1].ctorArgs.size, 0)
    verifyEq(t.enumDefs[2].ordinal, 2)
    verifyEq(t.enumDefs[2].name, "c")
    verifyEq(t.enumDefs[2].ctorArgs.size, 0)

    // trailing semicolon; args
    parse(
     "enum class Foo
      {
        a(true),
        b(false);
      }")

    verifyEq(t.enumDefs.size, 2)
    verifyEq(t.enumDefs[0].ordinal, 0)
    verifyEq(t.enumDefs[0].name, "a")
    verifyEq(t.enumDefs[0].ctorArgs.size, 1)
    verifyEq(t.enumDefs[1].ordinal, 1)
    verifyEq(t.enumDefs[1].name, "b")
    verifyEq(t.enumDefs[1].ctorArgs.size, 1)
  }

  Void testDupEnums()
  {
    verifyErrors(
     "enum class Foo
      {
        a,
        b,
        a,
        c,
        b
      }",
    [
     5, 3, "Duplicate enum name 'a'",
     7, 3, "Duplicate enum name 'b'",
    ])
  }

//////////////////////////////////////////////////////////////////////////
// Field
//////////////////////////////////////////////////////////////////////////

  Void testField()
  {
    parse(
     "class Foo
      {
        Int a
        private Int b := 3
        static Str c { get; private set }
        Int d := 0 { get {} set {} }
        abstract Bool e
        Bool f := true
        Int g := 5 { get {} private set }
      }")

    verifyEq(t.slotDefs.size, 21)

    // Int a
    f := (FieldDef)t.fieldDefs[0]
    verifyEq(f.name, "a")
    verifyEq(f.fieldType.qname, "sys::Int")
    verifyEq(f.flags, FConst.Public.or(FConst.Storage))
    verifyEq(f.get.flags, FConst.Public.or(FConst.Synthetic).or(FConst.Getter))
    verifyEq(f.set.flags, FConst.Public.or(FConst.Synthetic).or(FConst.Setter))
    verify(f.init == null)
    verify(!f.hasGet)
    verify(!f.hasSet)

    // Int b := 3
    f = (FieldDef)t.fieldDefs[1]
    verifyEq(f.name, "b")
    verifyEq(f.fieldType.qname, "sys::Int")
    verifyEq(f.flags, FConst.Private.or(FConst.Storage))
    verifyEq(f.get.flags, FConst.Private.or(FConst.Synthetic).or(FConst.Getter))
    verifyEq(f.set.flags, FConst.Private.or(FConst.Synthetic).or(FConst.Setter))
    verify(f.init != null)
    verify(!f.hasGet)
    verify(!f.hasSet)

    // static Str c { get; private set }
    f = (FieldDef)t.fieldDefs[2]
    verifyEq(f.name, "c")
    verifyEq(f.fieldType.qname, "sys::Str")
    verifyEq(f.flags, FConst.Public.or(FConst.Static).or(FConst.Storage))
    verifyEq(f.get.flags, FConst.Public.or(FConst.Static).or(FConst.Synthetic).or(FConst.Getter))
    verifyEq(f.set.flags, FConst.Private.or(FConst.Static).or(FConst.Synthetic).or(FConst.Setter))
    verify(f.init == null)
    verify(!f.hasGet)
    verify(!f.hasSet)

    // Int d := 0 { get {} set {} }
    f = (FieldDef)t.fieldDefs[3]
    verifyEq(f.name, "d")
    verifyEq(f.fieldType.qname, "sys::Int")
    verifyEq(f.flags, FConst.Public)
    verifyEq(f.get.flags, FConst.Public.or(FConst.Getter))
    verifyEq(f.set.flags, FConst.Public.or(FConst.Setter))
    verify(f.init != null)
    verify(f.hasGet)
    verify(f.hasSet)

    // abstract Bool e
    f = (FieldDef)t.fieldDefs[4]
    verifyEq(f.name, "e")
    verifyEq(f.fieldType.qname, "sys::Bool")
    verifyEq(f.flags, FConst.Public.or(FConst.Abstract).or(FConst.Virtual))
    verifyEq(f.get.flags, FConst.Public.or(FConst.Abstract).or(FConst.Virtual).or(FConst.Synthetic).or(FConst.Getter))
    verifyEq(f.set.flags, FConst.Public.or(FConst.Abstract).or(FConst.Virtual).or(FConst.Synthetic).or(FConst.Setter))
    verify(f.init == null)
    verify(!f.hasGet)
    verify(!f.hasSet)

    // Bool f := true
    f = (FieldDef)t.fieldDefs[5]
    verifyEq(f.name, "f")
    verifyEq(f.flags, FConst.Public.or(FConst.Storage))
    verify(f.init != null)

    // readonly Int g := 5 { get {} }
    f = (FieldDef)t.fieldDefs[6]
    verifyEq(f.name, "g")
    verifyEq(f.flags, FConst.Public.or(FConst.Storage))
    verifyEq(f.get.flags, FConst.Public.or(FConst.Getter))
    verifyEq(f.set.flags, FConst.Private.or(FConst.Synthetic).or(FConst.Setter))
    verify(f.init != null)
    verify(f.hasGet)
    verify(!f.hasSet)
  }

  Void testBadFields()
  {
    verifyErrors(
     "class Foo
      {
        Int a = 3
        b = false
        Int c { Set {} }
        Int d { get private set }
      }",
    [
     //3, 9, "Must use := for field initialization",
     //4, 5, "Must use := for field initialization",
     4, 3,  "Type inference not supported for fields",
     5, 11, "Expected 'get' or 'set', not 'Set'",
     6, 15, "Expected end of statement: semicolon, newline, or end of block; not 'private'"])
  }

//////////////////////////////////////////////////////////////////////////
// Method
//////////////////////////////////////////////////////////////////////////

  Void testMethod()
  {
    parse(
     "class Foo
      {
        new make() {}
        new makeA() : this.make() {}
        new makeB() : super() {}
        new makeC() : super.makeX() {}
        Void a() {}
        static Void b(Int x) {}
        internal Bool c(Int x, Str y) {}
        static {}
      }")
    verifyEq(t.slotDefs.size, 8)

    // new make()
    n := 0
    m := (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "make")
    verifyEq(m.flags, FConst.Public.or(FConst.Ctor))
    verifyEq(m.ret.qname, "sys::Void")
    verifyEq(m.paramDefs.size, 0)
    verifyEq(m.ctorChain, null)

    // new makeA() : this.make()
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "makeA")
    verifyEq(m.ctorChain.target.id, ExprId.thisExpr)
    verifyEq(m.ctorChain.name, "make")

    // new makeB() : super()
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "makeB")
    verifyEq(m.ctorChain.target.id, ExprId.superExpr)
    verifyEq(m.ctorChain.name, "makeB")

    // new makeC() : super.makeX()
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "makeC")
    verifyEq(m.ctorChain.target.id, ExprId.superExpr)
    verifyEq(m.ctorChain.name, "makeX")

    // Void a()
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "a")
    verifyEq(m.flags, FConst.Public)
    verifyEq(m.ret.qname, "sys::Void")
    verifyEq(m.params.size, 0)

    // static Void b(Int x)
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "b")
    verifyEq(m.flags, FConst.Public.or(FConst.Static))
    verifyEq(m.ret.qname, "sys::Void")
    verifyEq(m.params.size, 1)
    verifyParam(m.paramDefs[0], "sys::Int", "x")

    // static Void c(Int x, Str y)
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "c")
    verifyEq(m.flags, FConst.Internal)
    verifyEq(m.ret.qname, "sys::Bool")
    verifyEq(m.params.size, 2)
    verifyParam(m.paramDefs[0], "sys::Int", "x")
    verifyParam(m.paramDefs[1], "sys::Str", "y")

    // static {}
    m = (MethodDef)t.slotDefs[n++]
    verifyEq(m.name, "static\$init")
    verifyEq(m.flags, FConst.Private.or(FConst.Static).or(FConst.Synthetic))
    verifyEq(m.ret.qname, "sys::Void")
    verifyEq(m.params.size, 0)
  }

  Void testBadMethods()
  {
    verifyErrors(
     "class Foo
      {
        Foo() {}
        Void a()
        abstract Int b() {}
        native Str c() {}
        Void d(Bool x = false) {}
        Void b(Int x) {}
        Int b
        Int d
        new make() : makeX() {}  // last, no recover
      }",
    [3,  3, "Invalid constructor syntax - use new keyword",
     5,  3, "Expecting method body",
     5, 20, "Abstract or native methods cannot have method body",
     6, 18, "Abstract or native methods cannot have method body",
     7, 17, "Must use := for parameter default",
     8,  3, "Duplicate slot name 'b'",
     9,  3, "Duplicate slot name 'b'",
    10,  3, "Duplicate slot name 'd'",
    11, 16, "Expecting this or super for constructor chaining"])
  }

  Void verifyParam(ParamDef p, Str typeName, Str name)
  {
    verifyEq(p.paramType.qname, typeName)
    verifyEq(p.name, name)
  }

  Void testDupParams()
  {
    verifyErrors(
     "class Foo
      {
        new make(Obj a, Obj a) {}
        Void foo(Int xxx, Str y, Str? xxx := null, Int xxx := 9) {}
      }",
    [
     3, 19, "Duplicate parameter name 'a'",
     4, 28, "Duplicate parameter name 'xxx'",
     4, 46, "Duplicate parameter name 'xxx'",
    ])
  }

//////////////////////////////////////////////////////////////////////////
// Stmt
//////////////////////////////////////////////////////////////////////////

  Void testStmt()
  {
    // local def
    Stmt stmt := verifyStmt("Int i", StmtId.localDef);
      verifyEq(stmt->ctype->signature, "sys::Int")
      verifyEq(stmt->name, "i")
    stmt = verifyStmt("Int i := 3", StmtId.localDef);
      verifyEq(stmt->ctype->signature, "sys::Int")
      verifyEq(stmt->name, "i")
      verifyEq(stmt->init->val, 3)
    stmt = verifyStmt("i := 3", StmtId.localDef);
      verifyEq(stmt->ctype, null)
      verifyEq(stmt->name, "i")
      verifyEq(stmt->init->val, 3)

    // return
    stmt = verifyStmt("return 6", StmtId.returnStmt); verifyEq(stmt->expr->id, ExprId.intLiteral)

    // if
    stmt = verifyStmt("if (x) return x", StmtId.ifStmt);
      verifyEq(stmt->trueBlock->size, 1)
      verifyEq(stmt->falseBlock, null)
    stmt = verifyStmt("if (x) { x++; return x }", StmtId.ifStmt);
      verifyEq(stmt->trueBlock->size, 2)
      verifyEq(stmt->falseBlock, null)
    stmt = verifyStmt("if (x) return x; else return x", StmtId.ifStmt);
      verifyEq(stmt->trueBlock->size, 1)
      verifyEq(stmt->falseBlock->size, 1)
    stmt = verifyStmt("if (x) { return x } else { return x }", StmtId.ifStmt);
      verifyEq(stmt->trueBlock->size, 1)
      verifyEq(stmt->falseBlock->size, 1)

    // throw
    stmt = verifyStmt("throw x", StmtId.throwStmt); verifyEq(stmt->exception->name, "x")

    // while
    stmt = verifyStmt("while (x) return x", StmtId.whileStmt);
      verifyEq(stmt->condition->name, "x")
      verifyEq(stmt->block->size, 1)
    stmt = verifyStmt("while (x) {}", StmtId.whileStmt);
      verifyEq(stmt->condition->name, "x")
      verifyEq(stmt->block->size, 0)

    // for
    stmt = verifyStmt("for (;;) {}", StmtId.forStmt);
      verifyEq(stmt->init, null)
      verifyEq(stmt->condition, null)
      verifyEq(stmt->update, null)
      verifyEq(stmt->block->size, 0)
    stmt = verifyStmt("for (Int x :=0; x===4; ++x) {}", StmtId.forStmt);
      verifyEq(stmt->init->id, StmtId.localDef)
      verifyEq(stmt->condition->id, ExprId.same)
      verifyEq(stmt->update->op, ShortcutOp.increment)
      verifyEq(stmt->block->size, 0)
    stmt = verifyStmt("for (x=0; x===4; ++x) {}", StmtId.forStmt);
      verifyEq(stmt->init->id, StmtId.expr)
      verifyEq(stmt->condition->id, ExprId.same)
      verifyEq(stmt->update->op, ShortcutOp.increment)
      verifyEq(stmt->block->size, 0)

    // break
    stmt = verifyStmt("while (x) break", StmtId.whileStmt);
      verifyEq(stmt->block->stmts->first->id, StmtId.breakStmt)

    // continue
    stmt = verifyStmt("while (x) continue", StmtId.whileStmt);
      verifyEq(stmt->block->stmts->first->id, StmtId.continueStmt)

    // try
    stmt = verifyStmt("try { } catch {}", StmtId.tryStmt);
      verifyEq(stmt->block->size, 0)
      verifyEq(stmt->catches->size, 1)
      verifyEq(stmt->catches->first->errType, null)
      verifyEq(stmt->finallyBlock, null)
    stmt = verifyStmt("try { } catch (Err x) {} catch {} finally {}", StmtId.tryStmt);
      verifyEq(stmt->block->size, 0)
      verifyEq(stmt->catches->size, 2)
      verifyEq(stmt->catches->first->errType->qname, "sys::Err")
      verifyEq(stmt->catches->first->errVariable, "x")
      verifyEq(stmt->catches->last->errType, null)
      verifyEq(stmt->finallyBlock->size, 0)

    // switch
    stmt = verifyStmt("switch (x) { }", StmtId.switchStmt);
      verifyEq(stmt->condition->name, "x")
      verifyEq(stmt->cases->size, 0)
      verifyEq(stmt->defaultBlock, null)
    stmt = verifyStmt("switch (x) { default: x++ }", StmtId.switchStmt);
      verifyEq(stmt->condition->name, "x")
      verifyEq(stmt->cases->size, 0)
      verifyEq(stmt->defaultBlock->stmts->size, 1)
    stmt = verifyStmt("switch (x) { case 0: x+=1; default: x+=2; }", StmtId.switchStmt);
      verifyEq(stmt->condition->name, "x")
      verifyEq(stmt->cases->size, 1)
      verifyEq(stmt->cases->first->cases->size, 1)
      verifyEq(stmt->cases->first->cases->first->val, 0)
      verifyEq(stmt->cases->first->block->size, 1)
      verifyEq(stmt->defaultBlock->stmts->size, 1)
    stmt = verifyStmt("switch (x) { case 0: case 1: x+=1; case 2: x+= 2; }", StmtId.switchStmt);
      verifyEq(stmt->condition->name, "x")
      verifyEq(stmt->cases->size, 2)
      verifyEq(stmt->cases->get(0)->cases->size, 2)
      verifyEq(stmt->cases->get(0)->cases->get(0)->val, 0)
      verifyEq(stmt->cases->get(0)->cases->get(1)->val, 1)
      verifyEq(stmt->cases->get(0)->block->size, 1)
      verifyEq(stmt->cases->get(1)->cases->size, 1)
      verifyEq(stmt->cases->get(1)->cases->get(0)->val, 2)
      verifyEq(stmt->defaultBlock, null)
  }

  Void testBadStmts()
  {
    verifyErrors("class Foo { Void f() { switch (3) { default: return; default: return; } } }",
    [1, 54, "Duplicate default blocks",])
  }

  Stmt verifyStmt(Str stmtStr, StmtId id)
  {
    parse("class Foo { Int m() { $stmtStr } }")
    m := (MethodDef)t.slotDefs.first
    stmt := m.code.stmts.first
    // echo("-----------"); stmt.dump
    verifyEq(stmt.id, id)
    return stmt
  }

//////////////////////////////////////////////////////////////////////////
// Expr
//////////////////////////////////////////////////////////////////////////

  Void testExpr()
  {
    // literals
    expr := verifyExpr("null", ExprId.nullLiteral)
    expr = verifyExpr("true", ExprId.trueLiteral);    verifyEq(expr->val, true)
    expr = verifyExpr("false", ExprId.falseLiteral);  verifyEq(expr->val, false)
    expr = verifyExpr("4", ExprId.intLiteral);        verifyEq(expr->val, 4)
    expr = verifyExpr("6f", ExprId.floatLiteral);      verifyEq(expr->val, 6f)
    expr = verifyExpr("9ms", ExprId.durationLiteral); verifyEq(expr->val, 9ms)
    expr = verifyExpr("\"foo\"", ExprId.strLiteral);  verifyEq(expr->val, "foo")
    expr = verifyExpr("`foo`", ExprId.uriLiteral);    verifyEq(expr->val, "foo")

    // type literals
    expr = verifyExpr("Str#", ExprId.typeLiteral);  verifyEq(expr->val->qname, "sys::Str")
    expr = verifyExpr("Foo#", ExprId.typeLiteral);  verifyEq(expr->val->qname, "$podName::Foo")
    expr = verifyExpr("sys::Str#", ExprId.typeLiteral);  verifyEq(expr->val->qname, "sys::Str")
    expr = verifyExpr("$podName::Foo#", ExprId.typeLiteral);  verifyEq(expr->val->qname, "$podName::Foo")
    expr = verifyExpr("Str[]#", ExprId.typeLiteral);  verifyEq(expr->val->signature, "sys::List<sys::Str>")
    expr = verifyExpr("sys::Int[][]#", ExprId.typeLiteral);  verifyEq(expr->val->signature, "sys::List<sys::List<sys::Int>>")
    expr = verifyExpr("Str:Foo#", ExprId.typeLiteral);  verifyEq(expr->val->signature, "std::Map<sys::Str,$podName::Foo>")
    expr = verifyExpr("[Str:$podName::Foo]#", ExprId.typeLiteral);  verifyEq(expr->val->signature, "std::Map<sys::Str,$podName::Foo>")
    expr = verifyExpr("|->|#", ExprId.typeLiteral);  verifyEq(expr->val->signature, "sys::Func<sys::Void>")

    // range literal
    expr = verifyExpr("x..y", ExprId.rangeLiteral);  verifyEq(expr->exclusive, false)
    expr = verifyExpr("x..<y", ExprId.rangeLiteral); verifyEq(expr->exclusive, true)

    // terms
    expr = verifyExpr("this", ExprId.thisExpr)
    expr = verifyExpr("x", ExprId.unknownVar); verifyEq(expr->name, "x")

    // call
    expr = verifyExpr("x()", ExprId.call); verifyEq(expr->name, "x"); verifyEq(expr->args->size, 0)
    expr = verifyExpr("x(y)", ExprId.call); verifyEq(expr->name, "x"); verifyEq(expr->args->get(0)->name, "y")
    expr = verifyExpr("x(y, z)", ExprId.call); verifyEq(expr->name, "x"); verifyEq(expr->args->get(1)->name, "z")

    // unary
    expr = verifyExpr("+x", ExprId.unknownVar);     verifyEq(expr->name, "x")  // optimized out
    expr = verifyExpr("!x", ExprId.boolNot);        verifyEq(expr->operand->name, "x")
    expr = verifyShortcut("++x", ShortcutOp.increment, Token.increment, ["x"], true, false)
    expr = verifyShortcut("--x", ShortcutOp.decrement, Token.decrement, ["x"], true, false)
    expr = verifyShortcut("x++", ShortcutOp.increment, Token.increment, ["x"], true, true)
    expr = verifyShortcut("x--", ShortcutOp.decrement, Token.decrement, ["x"], true, true)
    expr = verifyShortcut("-x", ShortcutOp.negate, Token.minus, ["x"])
    expr = verifyExpr("x == null", ExprId.cmpNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("x === null", ExprId.cmpNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("null == x", ExprId.cmpNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("null === x", ExprId.cmpNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("x != null", ExprId.cmpNotNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("x !== null", ExprId.cmpNotNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("null != x", ExprId.cmpNotNull);  verifyEq(expr->operand->name, "x")
    expr = verifyExpr("null !== x", ExprId.cmpNotNull);  verifyEq(expr->operand->name, "x")

    // binary
    expr = verifyExpr("x || y", ExprId.boolOr);   verifyEq(expr->operands->get(0)->name, "x"); verifyEq(expr->operands->get(1)->name, "y")
    expr = verifyExpr("x && y", ExprId.boolAnd);  verifyEq(expr->operands->get(0)->name, "x"); verifyEq(expr->operands->get(1)->name, "y")
    expr = verifyExpr("x && y && z", ExprId.boolAnd);  verifyEq(expr->operands->get(0)->name, "x"); verifyEq(expr->operands->get(1)->name, "y"); verifyEq(expr->operands->get(2)->name, "z")
    expr = verifyExpr("x === y", ExprId.same);    verifyEq(expr->lhs->name, "x"); verifyEq(expr->rhs->name, "y")
    expr = verifyExpr("x !== y", ExprId.notSame); verifyEq(expr->lhs->name, "x"); verifyEq(expr->rhs->name, "y")
    expr = verifyExpr("x is Int", ExprId.isExpr); verifyEq(expr->target->name, "x"); verifyEq(expr->check->qname, "sys::Int")
    expr = verifyExpr("x as Int", ExprId.asExpr); verifyEq(expr->target->name, "x"); verifyEq(expr->check->qname, "sys::Int")
    expr = verifyShortcut("x == y",  ShortcutOp.eq,      Token.eq,      ["x", "y"])
    expr = verifyShortcut("x != y",  ShortcutOp.eq,      Token.notEq,   ["x", "y"])
    expr = verifyShortcut("x < y",   ShortcutOp.cmp,     Token.lt,      ["x", "y"])
    expr = verifyShortcut("x <= y",  ShortcutOp.cmp,     Token.ltEq,    ["x", "y"])
    expr = verifyShortcut("x > y",   ShortcutOp.cmp,     Token.gt,      ["x", "y"])
    expr = verifyShortcut("x >= y",  ShortcutOp.cmp,     Token.gtEq,    ["x", "y"])
    expr = verifyShortcut("x <=> y", ShortcutOp.cmp,     Token.cmp,     ["x", "y"])
    expr = verifyShortcut("x+y",     ShortcutOp.plus,    Token.plus,    ["x", "y"])
    expr = verifyShortcut("x-y",     ShortcutOp.minus,   Token.minus,   ["x", "y"])
    expr = verifyShortcut("x*y",     ShortcutOp.mult,    Token.star,    ["x", "y"])
    expr = verifyShortcut("x/y",     ShortcutOp.div,     Token.slash,   ["x", "y"])
    expr = verifyShortcut("x%y",     ShortcutOp.mod,     Token.percent, ["x", "y"])

    // ternary
    expr = verifyExpr("x ? y : z", ExprId.ternary);
      verifyEq(expr->condition->name, "x");
      verifyEq(expr->trueExpr->name,  "y");
      verifyEq(expr->falseExpr->name, "z");

    // index
    expr = verifyShortcut("x[y]",  ShortcutOp.get,   Token.lbracket, ["x", "y"])
    expr = verifyExpr("x[y] = z",  ExprId.assign)
      verifyEq(expr->lhs->id, ExprId.shortcut);
      verifyEq(expr->lhs->op, ShortcutOp.get);

    // cast
    expr = verifyExpr("(Int)x", ExprId.coerce);
      verifyEq(expr->target->name, "x");
      verifyEq(expr->check->signature, "sys::Int")
    expr = verifyExpr("(sys::Int)x", ExprId.coerce);
      verifyEq(expr->target->name, "x");
      verifyEq(expr->check->signature, "sys::Int")
    expr = verifyExpr("(Int[])x", ExprId.coerce);
      verifyEq(expr->target->name, "x");
      verifyEq(expr->check->signature, "sys::List<sys::Int>")

    // not cast
    expr = verifyExpr("(Int#)", ExprId.typeLiteral);
      verifyEq(expr->val->signature, "sys::Int")

    // assign
    expr = verifyExpr("x = y", ExprId.assign); verifyEq(expr->lhs->name, "x"); verifyEq(expr->rhs->name, "y")
    expr = verifyShortcut("x += y",   ShortcutOp.plus,    Token.assignPlus,   ["x", "y"], true)
    expr = verifyShortcut("x -= y",   ShortcutOp.minus,   Token.assignMinus,   ["x", "y"], true)
    expr = verifyShortcut("x *= y",   ShortcutOp.mult,    Token.assignStar,    ["x", "y"], true)
    expr = verifyShortcut("x /= y",   ShortcutOp.div,     Token.assignSlash,   ["x", "y"], true)
    expr = verifyShortcut("x %= y",   ShortcutOp.mod,     Token.assignPercent, ["x", "y"], true)

    // call chains (dot, arrow)
    expr = verifyExpr("x.y", ExprId.unknownVar)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isSafe, false)
    expr = verifyExpr("x.y()", ExprId.call)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isDynamic, false)
      verifyEq(expr->isSafe, false)
    expr = verifyExpr("x->y()", ExprId.call)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isDynamic, true)
      verifyEq(expr->isSafe, false)
    expr = verifyExpr("x->y", ExprId.call)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isDynamic, true)
      verifyEq(expr->isSafe, false)
    expr = verifyExpr("x?.y", ExprId.unknownVar)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isSafe, true)
    expr = verifyExpr("x?.y()", ExprId.call)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isDynamic, false)
      verifyEq(expr->isSafe, true)
    expr = verifyExpr("x?->y()", ExprId.call)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isDynamic, true)
      verifyEq(expr->isSafe, true)
    expr = verifyExpr("x?->y", ExprId.call)
      verifyEq(expr->name, "y")
      verifyEq(expr->target->name, "x")
      verifyEq(expr->isDynamic, true)
      verifyEq(expr->isSafe, true)
    expr = verifyExpr("x?.y[z]->zz", ExprId.call)
      verifyEq(expr->name, "zz")
      verifyEq(expr->target->id, ExprId.shortcut)
      verifyEq(expr->target->name, "get")
      verifyEq(expr->target->args->first->name, "z")
      verifyEq(expr->target->target->name, "y")
      verifyEq(expr->target->target->isSafe, true)
      verifyEq(expr->target->target->target->name, "x")

    // static accessors
    expr = verifyExpr("Float.nan", ExprId.unknownVar)
      verifyEq(expr->name, "nan")
      verifyEq(expr->target->id, ExprId.staticTarget)
      verifyEq(expr->target->ctype->signature, "sys::Float")
    expr = verifyExpr("sys::Float.nan", ExprId.unknownVar)
      verifyEq(expr->name, "nan")
      verifyEq(expr->target->id, ExprId.staticTarget)
      verifyEq(expr->target->ctype->signature, "sys::Float")
    expr = verifyExpr("Float.parse(\"3\")", ExprId.call)
      verifyEq(expr->name, "parse")
      verifyEq(expr->target->id, ExprId.staticTarget)
      verifyEq(expr->target->ctype->signature, "sys::Float")

    // paren
    expr = verifyExpr("(x + y)*z", ExprId.shortcut)
      verifyEq(expr->args->first->name, "z")
      verifyEq(expr->op, ShortcutOp.mult)
      verifyEq(expr->target->op, ShortcutOp.plus)
      verifyEq(expr->target->target->name, "x")
      verifyEq(expr->target->args->first->name, "y")

  }

  Void testCollections()
  {
    expr := verifyExpr("[,]", ExprId.listLiteral)
      verifyEq(expr->explicitType, null)
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("Str[,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<sys::Str>")
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("sys::Str[,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<sys::Str>")
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("Foo[,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<$podName::Foo>")
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("$podName::Foo[,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<$podName::Foo>")
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("Str[][,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<sys::List<sys::Str>>")
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("[0]", ExprId.listLiteral)
      verifyEq(expr->explicitType, null)
      verifyEq(expr->vals->size, 1)

    expr = verifyExpr("[0, 1]", ExprId.listLiteral)
      verifyEq(expr->explicitType, null)
      verifyEq(expr->vals->size, 2)

    expr = verifyExpr("Int[0, 1, 2,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<sys::Int>")
      verifyEq(expr->vals->size, 3)

    expr = verifyExpr("$podName::Foo[][[,]]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "sys::List<sys::List<$podName::Foo>>")
      verifyEq(expr->vals->size, 1)
      verifyEq(expr->vals->first->id, ExprId.listLiteral)
      verifyEq(expr->vals->first->explicitType, null)
      verifyEq(expr->vals->first->vals->size, 0)

    expr = verifyExpr("[:]", ExprId.mapLiteral)
      verifyEq(expr->explicitType, null)
      verifyEq(expr->keys->size, 0)
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("Int:Str[:]", ExprId.mapLiteral)
      verifyEq(expr->explicitType->signature, "std::Map<sys::Int,sys::Str>")
      verifyEq(expr->keys->size, 0)
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("sys::Int:sys::Str[:]", ExprId.mapLiteral)
      verifyEq(expr->explicitType->signature, "std::Map<sys::Int,sys::Str>")
      verifyEq(expr->keys->size, 0)
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("[Int:Str][:]", ExprId.mapLiteral)
      verifyEq(expr->explicitType->signature, "std::Map<sys::Int,sys::Str>")
      verifyEq(expr->keys->size, 0)
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("[$podName::Foo:Str][:]", ExprId.mapLiteral)
      verifyEq(expr->explicitType->signature, "std::Map<$podName::Foo,sys::Str>")
      verifyEq(expr->keys->size, 0)
      verifyEq(expr->vals->size, 0)

    expr = verifyExpr("[1:10]", ExprId.mapLiteral)
      verifyEq(expr->explicitType, null)
      verifyEq(expr->keys->size, 1)
      verifyEq(expr->keys->first->val, 1)
      verifyEq(expr->vals->size, 1)
      verifyEq(expr->vals->first->val, 10)

    expr = verifyExpr("[1:10, 2:20, ]", ExprId.mapLiteral)
      verifyEq(expr->explicitType, null)
      verifyEq(expr->keys->size, 2)
      verifyEq(expr->keys->get(0)->val, 1)
      verifyEq(expr->keys->get(1)->val, 2)
      verifyEq(expr->vals->size, 2)
      verifyEq(expr->vals->get(0)->val, 10)
      verifyEq(expr->vals->get(1)->val, 20)

    expr = verifyExpr("Int:Int[1:10]", ExprId.mapLiteral)
      verifyEq(expr->explicitType->signature, "std::Map<sys::Int,sys::Int>")
      verifyEq(expr->keys->size, 1)
      verifyEq(expr->keys->first->val, 1)
      verifyEq(expr->vals->size, 1)
      verifyEq(expr->vals->first->val, 10)
/*
    expr = verifyExpr("Str:Int[][\"x\":[2,3]]", ExprId.mapLiteral)
      verifyEq(expr->explicitType->signature, "[sys::Str:sys::Int[]]")
      verifyEq(expr->keys->size, 1)
      verifyEq(expr->keys->first->val, "x")
      verifyEq(expr->vals->size, 1)
      verifyEq(expr->vals->first->vals->get(0)->val, 2)
      verifyEq(expr->vals->first->vals->get(1)->val, 3)

    // empty list of Int:Str maps
    expr = verifyExpr("Int:Str[,]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "[sys::Int:sys::Str][]")
      verifyEq(expr->vals->size, 0)

    // list of maps is tricky
    expr = verifyExpr("Int:Int[[6:10]]", ExprId.listLiteral)
      verifyEq(expr->explicitType->signature, "[sys::Int:sys::Int][]")
      verifyEq(expr->vals->size, 1)
      verifyEq(expr->vals->first->keys->first->val, 6)
      */
  }

  Void testClosures()
  {
    expr := verifyExpr("x |->| {}", ExprId.call)
      verifyEq(expr->name, "x")
      verifyEq(expr->args->size, 1)
      verifyEq(expr->args->last->id, ExprId.closure)
      verifyEq(expr->args->last->signature->signature, "sys::Func<sys::Void>")
      verifyEq(expr->args->last->enclosingType->name, "Foo")
      verifyEq(expr->args->last->enclosingSlot->name, "m")
      verifyEq(expr->args->last->name, "Foo\$m\$0")
      verifySame(closures[0], expr->args->last)

    expr = verifyExpr("x() |Str a| {}", ExprId.call)
      verifyEq(expr->name, "x")
      verifyEq(expr->args->size, 1)
      verifyEq(expr->args->last->id, ExprId.closure)
      verifyEq(expr->args->last->signature->signature, "sys::Func<sys::Void,sys::Str>")

    expr = verifyExpr("x(2) |->Bool| {}", ExprId.call)
      verifyEq(expr->name, "x")
      verifyEq(expr->args->size, 2)
      verifyEq(expr->args->last->id, ExprId.closure)
      verifyEq(expr->args->last->signature->signature, "sys::Func<sys::Bool>")

    expr = verifyExpr("|->| {}.callList(null)", ExprId.call)
      verifyEq(expr->name, "callList")
      verifyEq(expr->target->id, ExprId.closure)
      verifyEq(expr->target->signature->signature, "sys::Func<sys::Void>")

    expr = verifyExpr("|Str s->Bool| {}.callList(null)", ExprId.call)
      verifyEq(expr->name, "callList")
      verifyEq(expr->target->id, ExprId.closure)
      verifyEq(expr->target->signature->signature, "sys::Func<sys::Bool,sys::Str>")
  }

  Void testBadExpr()
  {
    verifyErrors(
     "class Foo
      {
        Obj a() { return [] }
        Obj b() { Int x = 4 }
        Obj c() { return Str[:] }
        Obj d() { return a as GooGoo }
        Obj e() { return a is Kaggle }
      }",
    [3,  20, "Invalid list literal; use '[,]' for empty Obj[] list",
     //4,  19, "Must use := for declaration assignments",
     5,  20, "Invalid map type 'sys::Str' for map literal",
     6,  25, "Unknown type 'GooGoo'",
     7,  25, "Unknown type 'Kaggle'",
     ])
  }

  Expr verifyExpr(Str exprStr, ExprId id)
  {
    parse("class Foo { Void m() { $exprStr } }")
    m := (MethodDef)t.slotDefs.first
    stmt := m.code.stmts.first
    expr := ((ExprStmt)stmt).expr
    //echo(" --> $expr")
    verifyEq(expr.id, id)
    return expr
  }

  Expr verifyShortcut(Str exprStr, ShortcutOp op, Token opToken, Str[] operands, Bool isAssign := false, Bool isPostfix := false)
  {
    expr := (ShortcutExpr)verifyExpr(exprStr, ExprId.shortcut)
    verifyEq(expr.op, op)
    verifyEq(expr.opToken, opToken)
    verifyEq(expr.isAssign, isAssign)
    verifyEq(expr.isPostfixLeave, isPostfix)
    verifyEq(expr.name, op.methodName)
    verifyEq(expr.target->name, operands[0])
    verifyEq(expr.args.size, operands.size-1)
    expr.args.each |Expr arg, Int i| { verifyEq(arg->name, operands[i+1]) }
    return expr
  }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  Void testTypes()
  {
    t := parseType("Str")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Str")
      verifyEq(t.qname,       "sys::Str")
      verifyEq(t.signature,   "sys::Str")
      verifyEq(t.base.qname,  "sys::Obj")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)
      verifyEq(t.toListOf.signature, "sys::List<sys::Str>")
      verifyEq(t.toListOf.isNullable, false)
      verifyEq(t.toNullable.signature, "sys::Str?")

    t = parseType("Str?")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Str")
      verifyEq(t.qname,       "sys::Str")
      verifyEq(t.signature,   "sys::Str?")
      verifyEq(t.base.qname,  "sys::Obj")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  true)
      verifyEq(t.toListOf.signature, "sys::List<sys::Str?>")
      verifyEq(t.toListOf.isNullable, false)
      verifyEq(t.toNullable.signature, "sys::Str?")

    t = parseType("sys::Str")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Str")
      verifyEq(t.qname,       "sys::Str")
      verifyEq(t.signature,   "sys::Str")
      verifyEq(t.base.qname,  "sys::Obj")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)
      verifyEq(t.toListOf.signature, "sys::List<sys::Str>")
      verifyEq(t.toListOf.isNullable, false)

    t = parseType("sys::Str?")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Str")
      verifyEq(t.qname,       "sys::Str")
      verifyEq(t.signature,   "sys::Str?")
      verifyEq(t.base.qname,  "sys::Obj")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  true)

    t = parseType("$podName::Foo")
      verifyEq(t.pod.name,    podName)
      verifyEq(t.name,        "Foo")
      verifyEq(t.qname,       "$podName::Foo")
      verifyEq(t.signature,   "$podName::Foo")
      verifyEq(t.base.qname,  "sys::Obj")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)
      //verifyEq(t.toListOf.signature, "$podName::Foo[]")
      verifyEq(t.toListOf.isNullable, false)

    t = parseType("$podName::Foo?")
      verifyEq(t.pod.name,    podName)
      verifyEq(t.name,        "Foo")
      verifyEq(t.qname,       "$podName::Foo")
      verifyEq(t.signature,   "$podName::Foo?")
      verifyEq(t.base.qname,  "sys::Obj")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  true)
      //verifyEq(t.toListOf.signature, "$podName::Foo?[]")
      verifyEq(t.toListOf.isNullable, false)
      verifyEq(t.toNullable.signature, "$podName::Foo?")

    t = parseType("Str[]")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "List")
      verifyEq(t.qname,       "sys::List")
      verifyEq(t.signature,   "sys::List<sys::Str>")
      //verifyEq(t.base.qname,  "sys::List")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)

    t = parseType("Str?[]")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "List")
      verifyEq(t.qname,       "sys::List")
      verifyEq(t.signature,   "sys::List<sys::Str?>")
      //verifyEq(t.base.qname,  "sys::List")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)

    t = parseType("Str[]?")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "List")
      verifyEq(t.qname,       "sys::List")
      verifyEq(t.signature,   "sys::List<sys::Str>?")
      //verifyEq(t.base.qname,  "sys::List")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  true)
      verifyEq(t.toNullable.signature, "sys::List<sys::Str>?")

    t = parseType("Int[][]")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "List")
      verifyEq(t.qname,       "sys::List")
      verifyEq(t.signature,   "sys::List<sys::List<sys::Int>>")
      //verifyEq(t.base.qname,  "sys::List")
      verifyEq(t.mixins.size, 0)

    t = parseType("Int:Str")
      verifyEq(t.pod.name,    "std")
      verifyEq(t.name,        "Map")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Int,sys::Str>")
      //verifyEq(t.base.qname,  "std::Map")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)

    t = parseType("Int:Str?")
      verifyEq(t.pod.name,    "std")
      verifyEq(t.name,        "Map")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Int,sys::Str?>")
      //verifyEq(t.base.qname,  "std::Map")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)

    verifyErrors("class Foo { Void a(Str?:Str bad) {} }",
      [1,  23, "Map type cannot have nullable key type"])

    verifyErrors("class Foo { Void a(Str? :Str bad) {} }",
      [1,  25, "Map type cannot have nullable key type"])

    t = parseType("[Int:Str]")
      verifyEq(t.pod.name,    "std")
      verifyEq(t.name,        "Map")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Int,sys::Str>")
      //verifyEq(t.base.qname,  "std::Map")
      verifyEq(t.mixins.size, 0)

    t = parseType("[Int:Str]?")
      verifyEq(t.pod.name,    "std")
      verifyEq(t.name,        "Map")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Int,sys::Str>?")
      //verifyEq(t.base.qname,  "std::Map")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  true)

    t = parseType("|->|")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Func")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Void>")
      //verifyEq(t.base.qname,  "sys::Func")
      verifyEq(t.mixins.size, 0)

    t = parseType("|Str s->Bool|")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Func")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Bool,sys::Str>")
      //verifyEq(t.base.qname,  "sys::Func")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  false)

    t = parseType("|Str s->Bool|?")
      verifyEq(t.pod.name,    "sys")
      verifyEq(t.name,        "Func")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Bool,sys::Str>?")
      //verifyEq(t.base.qname,  "sys::Func")
      verifyEq(t.mixins.size, 0)
      verifyEq(t.isNullable,  true)

    t = parseType("|Str a, Int b->Bool|")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Bool,sys::Str,sys::Int>")

    t = parseType("|Str a, Int b|")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Void,sys::Str,sys::Int>")

    t = parseType("|->Str|")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Str>")

    t = parseType("|->Str?|")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<sys::Str?>")

    t = parseType("Str:Obj[]")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Str,sys::List<sys::Obj>>")

    t = parseType("Str[]:Obj")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::List<sys::Str>,sys::Obj>")

    t = parseType("Int:[Str:Obj[]][]")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Int,sys::List<std::Map<sys::Str,sys::List<sys::Obj>>>>")

    t = parseType("sys::Int:[Str:sys::Obj[]][]")
      verifyEq(t.qname,       "std::Map")
      //verifyEq(t.signature,   "[sys::Int:[sys::Str:sys::Obj[]][]]")

    t = parseType("[Int:[Str:Obj[]]][]")
      verifyEq(t.qname,       "sys::List")
      //verifyEq(t.signature,   "[sys::Int:[sys::Str:sys::Obj[]]][]")

    t = parseType("[Int[]:[Str:Bool]]")
      verifyEq(t.qname,       "std::Map")
      //verifyEq(t.signature,   "[sys::Int[]:[sys::Str:sys::Bool]]")

    t = parseType("|->|[]")
      verifyEq(t.qname,       "sys::List")
      verifyEq(t.signature,   "sys::List<sys::Func<sys::Void>>")

    t = parseType("| |->| a->Int:Obj|")
      verifyEq(t.qname,       "sys::Func")
      verifyEq(t.signature,   "sys::Func<std::Map<sys::Int,sys::Obj>,sys::Func<sys::Void>>")

    t = parseType("Str:|->|")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Str,sys::Func<sys::Void>>")

    t = parseType("Str:| Int:Int[] a -> |->| |[]")
      verifyEq(t.qname,       "std::Map")
      verifyEq(t.signature,   "std::Map<sys::Str,sys::List<sys::Func<sys::Func<sys::Void>,std::Map<sys::Int,sys::List<sys::Int>>>>>")
      verifyEq(t.isNullable,  false)

    t = parseType("[Str:| Int:Int[] a -> |->| |[]]?")
      verifyEq(t.qname,       "std::Map")
      //verifyEq(t.signature,   "[sys::Str:|[sys::Int:sys::Int[]]->|->sys::Void||[]]?")
      verifyEq(t.isNullable,  true)
  }

  CType parseType(Str typeStr)
  {
    parse("class Foo { Void m($typeStr x) {} }")
    m := (MethodDef)t.slotDefs.first
    // echo(" --> $m.params.first.ctype")
    return m.paramDefs.first.paramType
  }

  Void testBadTypes()
  {
    verifyErrors(
     "class Foo
      {
        Void a([Str] x) {}
        Void b([Int[]] x) {}
        Void c(yuckeee::Foo x) {}
        Void d(sys::NoWay x) {}
        Void e($podName::Who x) {}
      }",
    [3,  10, "Invalid map type",
     4,  10, "Invalid map type",
     5,  10, "Pod not found 'yuckeee'",
     6,  10, "Type 'NoWay' not found in pod 'sys'",
     7,  10, "Type 'Who' not found within pod being compiled"])
  }

//////////////////////////////////////////////////////////////////////////
// EofErrors
//////////////////////////////////////////////////////////////////////////

 Void testEofErrors()
 {
   verifyErrors("class Foo { Str f := \"",      [1, 23, "Unexpected end of Str literal"])
   verifyErrors("class Foo { Str f := \"\$x",   [1, 25, "Unexpected end of Str literal"])
   verifyErrors("class Foo { Str f := \"\${",   [1, 25, "Unexpected end of Str literal, missing }"])
   verifyErrors("class Foo { Str f := \"\${x",  [1, 26, "Unexpected end of Str literal, missing }"])
   verifyErrors("class Foo { Str f := \"\${x}", [1, 27, "Unexpected end of Str literal"])
   verifyErrors("class Foo { Str f := Str<|",   [1, 27, "Unexpected end of DSL"])
   verifyErrors("class Foo { Uri f := `",       [1, 23, "Unexpected end of Uri literal"])
   verifyErrors("class Foo { Uri f := `\$x",    [1, 25, "Unexpected end of Uri literal"])
   verifyErrors("class Foo { Uri f := `\${",    [1, 25, "Unexpected end of Uri literal, missing }"])
   verifyErrors("class Foo { Uri f := `\${x",   [1, 26, "Unexpected end of Uri literal, missing }"])
   verifyErrors("class Foo { Int f := '",       [1, 24, "Expecting ' close of char literal"])
 }

//////////////////////////////////////////////////////////////////////////
// Multi-line Strs
//////////////////////////////////////////////////////////////////////////

 Void testMultiLineStrs()
 {
    // NOTE: matching checks for Str <| |> in MiscTest.testStrDslErrors
    verifyErrors(
    //12345678901
     "class Foo {
       Str a := \"
        foo\"
       Str baa := \"

                    bar
                  x\"
        Void f00()
        {
      \t\tg := \"
                                   x\"

      \t\th := \"
      \t\t      x\" // ok

      \t\ti :=
      \t\t\"
      \t     x\"
        }

       Str c := \"\"\"
                  bad\"\"\"
      }",
       [
         3,  3, "Leading space in multi-line Str must be 11 spaces",
         7, 13, "Leading space in multi-line Str must be 13 spaces",
        11,  1, "Leading space in multi-line Str must be 2 tabs and 6 spaces",
        18,  2, "Leading space in multi-line Str must be 2 tabs and 1 spaces",
        22, 13, "Leading space in multi-line Str must be 13 spaces",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Misc Err Messages
//////////////////////////////////////////////////////////////////////////

  ** Nicer parse time error messages (#1407)
  Void testBetterErrMsgs()
  {
    verifyErrors("class Foo { Void f() { a := BadType[,] } }",
      [1, 29, "Unknown type 'BadType' for list literal"])

    verifyErrors("class Foo { Void f() { BadType a := null } }",
      [1, 24, "Unknown type 'BadType' for local declaration"])

    verifyErrors("class Foo { Void f() { BadType? a := null } }",
      [1, 24, "Unknown type 'BadType' for local declaration"])

    verifyErrors("class Foo { Void f() { this.a := null } }",
      [1, 24, "Left hand side of ':=' must be identifier"])

    verifyErrors("class Foo { Void f() { x := BadType#.qname } }",
      [1, 29, "Unknown type 'BadType' for type literal"])
  }

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

  Void parse(Str src)
  {
    input := CompilerInput.make
    input.podName   = "unused"
    input.log.level = LogLevel.silent
    input.isScript  = true
    input.mode      = CompilerInputMode.str
    input.srcStr    = src

    compiler = Compiler(input)
    //compiler.ns = ReflectNamespace()
    compiler.ns = FPodNamespace(null)
    compiler.ns->c = compiler
    compiler.depends = [Depend("sys 2"), Depend("std 1")].map |d->CDepend| { CDepend(d, null) }

    // use custom pipeline only to parse phase
    loc := Loc("Test")
    compiler.pod = PodDef(compiler.ns, loc, podName)
    ResolveDepends(compiler).run
    Tokenize(compiler).tokenize(loc, src)
    ScanForUsingsAndTypes(compiler).run
    ResolveImports(compiler).run
    Parse(compiler).run

    unit     = compiler.pod.units.first
    types    = compiler.types
    t        = compiler.types.first
    closures = compiler.closures
  }

//////////////////////////////////////////////////////////////////////////
// Field
//////////////////////////////////////////////////////////////////////////

  CompilationUnit? unit    // compiler.unit.first
  TypeDef[]? types         // compiler.types
  TypeDef?   t             // compiler.types.first
  ClosureExpr[]? closures  // compiler.closures

}