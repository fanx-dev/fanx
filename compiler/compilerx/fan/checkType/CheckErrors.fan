//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    2 Dec 05  Brian Frank  Creation
//   17 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** CheckErrors walks the tree of statements and expressions looking
** for errors the compiler can detect such as invalid type usage.  We
** attempt to leave all the error reporting to this step, so that we
** can batch report as many errors as possible.
**
** Since CheckErrors already performs a full tree walk down to each leaf
** expression, we also do a couple of other AST decorations in this step:
**   1) add temp local for field assignments like return ++x
**   2) add temp local for returns inside protected region
**   3) check for field accessor optimization
**   4) check for field storage requirements
**   5) add implicit coersions: auto-casts, boxing, to non-nullable
**   6) implicit call to toImmutable when assigning to const field
**   7) mark ClosureExpr.setsConst
**
class CheckErrors : CompilerStep, Coerce
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
    //this.isSys = compiler.isSys
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    //debug("CheckErrors")
    //checkPodDef(pod)
    walkUnits(VisitDepth.expr)
  }

//////////////////////////////////////////////////////////////////////////
// PodDef
//////////////////////////////////////////////////////////////////////////

//  Void checkPodDef(PodDef pod)
//  {
//  }

//////////////////////////////////////////////////////////////////////////
// TypeDef
//////////////////////////////////////////////////////////////////////////

  override Void visitTypeDef(TypeDef t)
  {
    // check type flags
    checkTypeFlags(t)

    // facets
    checkFacets(t.facets)

    // check for abstract slots in concrete class
    checkAbstractSlots(t)
    checkVirtualSlots(t)

    // check for const slots in const class
    checkConstType(t)

    // verify we don't use a restricted name
    if (isRestrictedName(t.name))
      err("Type name '$t.name' is restricted", t.loc)

    // verify type name doesn't conflict with resource name
    checkResConflicts(t)

    // if type extends from any FFI types then give bridge a hook
    foreign := foreignInheritance(t)//.foreignInheritance
    if (foreign != null) foreign.typeDef.bridge.checkType(t)

    // check some knuckle head doesn't override type
    if (t.slotDef("typeof") != null && t.qname != "sys::Obj" && t.qname != "std::Type" /*&& !isSys*/)
      err("Cannot override Obj.typeof()", t.slotDef("typeof").loc)

    // check inheritance
    if (t.base != null) checkBase(t, t.base)
    t.mixins.each |CType m| { checkMixin(t, m) }

    // check definite assignment of static fields
    checkDefiniteAssign(t.staticInit)
  }
  
  **
  ** If this TypeDef extends from a FFI class or implements any
  ** FFI mixins, then return the FFI type otherwise return null.
  **
  private static CType? foreignInheritance(CTypeDef self)
  {
    if (self.base == null) return null
    if (self.base.typeDef.isForeign) return self.base
    m := self.mixins.find |CType t->Bool| { t.typeDef.isForeign }
    if (m != null) return m
    if (self == self.base.typeDef) {
      return null
    }
    return foreignInheritance(self.base.typeDef)
  }

  static Bool isRestrictedName(Str name)
  {
    // disallow types to conflict with docs URI
    return name == "pod" || name == "index"
  }

  private Void checkResConflicts(TypeDef t)
  {
    compiler.input.resFiles?.each |uri|
    {
      if (uri.path.first == t.name)
        err("Resource `$uri` conflicts with type name '$t.name'", t.loc)
    }
  }

  private Void checkTypeFlags(TypeDef t)
  {
    flags := t.flags
    loc := t.loc

    // these modifiers are never allowed on a type
    if (flags.and(FConst.Ctor) != 0)      err("Cannot use 'new' modifier on type", loc)
    if (flags.and(FConst.Once) != 0)      err("Cannot use 'once' modifier on type", loc)
    if (flags.and(FConst.Override) != 0)  err("Cannot use 'override' modifier on type", loc)
    if (flags.and(FConst.Private) != 0)   err("Cannot use 'private' modifier on type", loc)
    if (flags.and(FConst.Protected) != 0) err("Cannot use 'protected' modifier on type", loc)
    if (flags.and(FConst.Static) != 0)    err("Cannot use 'static' modifier on type", loc)

    // check invalid protection combinations
    checkProtectionFlags(flags, loc)

    // check abstract and final
    if (flags.and(FConst.Abstract) != 0 && flags.and(FConst.Final) != 0)
      err("Invalid combination of 'abstract' and 'final' modifiers", loc)
    if (flags.and(FConst.Virtual) != 0 && flags.and(FConst.Final) != 0)
      err("Invalid combination of 'virtual' and 'final' modifiers", loc)
  }

  private Void checkAbstractSlots(TypeDef t)
  {
    // if already abstract, nothing to check
    if (t.isAbstract) return

    errForDef := false
    closure := |CSlot slot|
    {
      if (!slot.isAbstract) return
      if (slot.parent === t)
      {
        if (!errForDef)
        {
          err("Class '$t.name' must be abstract since it contains abstract slots", t.loc)
          errForDef = true
        }
      }
      else
      {
        err("Class '$t.name' must be abstract since it inherits but doesn't override '$slot.qname'", t.loc)
      }
    }

    if (compiler.input.isTest)
      t.slots.vals.sort.each(closure)
    else
      t.slots.each(closure)
  }
  
  private Void checkVirtualSlots(TypeDef t)
  {
    if (!t.isFinal || t.isMixin) return

    errForDef := false
    closure := |CSlot slot|
    {
      if (slot.isVirtual && !slot.isOverride && !slot.isAbstract)
      {
        if (!errForDef)
        {
          err("Class '$t.name' must be virtual since it contains virtual slot: $slot.qname", t.loc)
          errForDef = true
        }
      }
    }

    t.slotDefs.each(closure)
  }

  private Void checkConstType(TypeDef t)
  {
    if ((t.flags.and(FConst.Struct)) != 0) {
      t.fieldDefs.each |FieldDef f| {
        if (!f.isConst && !f.isStatic && f.isStorage && !f.isReadonly)
          err("Struct type '$t.name' cannot contain non-readonly field '$f.name'", f.loc)
      }
    }

    // if not const then nothing to check
    if (!t.isConst) return

    // const class cannot inherit from non-const class
    if (t.base != null && !t.base.isObj && !t.base.isConst)
      err("Const type '$t.name' cannot subclass non-const class '$t.base.name'", t.loc)

    // check that each field is const or has no storage; don't
    // worry about statics because they are forced to be const
    // in another check
    t.fieldDefs.each |FieldDef f|
    {
      if (!f.isConst && !f.isStatic && f.isStorage /* && !isSys*/ && !f.isOnce) {
        if (t.isNative && t.pod.name == "sys") {
          //pass
        }
        else
          err("Const type '$t.name' cannot contain non-const field '$f.name'", f.loc)
      }
    }
  }

  private Void checkBase(TypeDef t, CType base)
  {
    // check that a public class doesn't subclass from internal classes
    if (t.isPublic && !base.isPublic)
      err("Public type '$t.name' cannot extend from internal class '$base.name'", t.loc)

    // if base is const, then t must be const
    if (!t.isConst && base.isConst)
      err("Non-const type '$t.name' cannot subclass const class '$base.name'", t.loc)
  }

  private Void checkMixin(TypeDef t, CType m)
  {
    // check that a public class doesn't implement from internal mixin
    if (t.isPublic && !m.isPublic)
      err("Public type '$t.name' cannot implement internal mixin '$m.name'", t.loc)

    // if mixin is const, then t must be const
    if (!t.isConst && m.isConst)
      err("Non-const type '$t.name' cannot implement const mixin '$m.name'", t.loc)
  }

//////////////////////////////////////////////////////////////////////////
// FieldDef
//////////////////////////////////////////////////////////////////////////

  override Void visitFieldDef(FieldDef f)
  {
    // if this field overrides a concrete field,
    // then it never gets its own storage
    if (f.concreteBase != null)
      f.flags = f.flags.and(FConst.Storage.not)

    // check for invalid flags
    checkFieldFlags(f)

    // facets
    checkFacets(f.facets)

    // mixins cannot have non-abstract fields
    if (curType.isMixin && !f.isAbstract && !f.isStatic)
      err("Mixin field '$f.name' must be abstract", f.loc)

    // abstract field cannot have initialization
    if (f.isAbstract && f.init != null)
      err("Abstract field '$f.name' cannot have initializer", f.init.loc)

    // abstract field cannot have getter/setter
    if (f.isAbstract && (f.hasGet || f.hasSet))
      err("Abstract field '$f.name' cannot have getter or setter", f.loc)

    // check internal type
    checkTypeProtection(f.fieldType, f.loc)

    // check that public field isn't using internal type
    if (curType.isPublic && (f.isPublic || f.isProtected) && !f.fieldType.isPublic)
      err("Public field '${curType.name}.${f.name}' cannot use internal type '$f.fieldType'", f.loc)

    checkParameterizedType(f.loc, f.fieldType)
  }

  private Void checkFieldFlags(FieldDef f)
  {
    flags := f.flags
    loc   := f.loc

    // these modifiers are never allowed on a field
    if (flags.and(FConst.Ctor) != 0)    err("Cannot use 'new' modifier on field", loc)
    if (flags.and(FConst.Final) != 0)   err("Cannot use 'final' modifier on field", loc)
    if (flags.and(FConst.Once) != 0 && flags.and(FConst.Synthetic) == 0) err("Cannot use 'once' modifier on field", loc)

    // check invalid protection combinations
    checkProtectionFlags(flags, loc)

    // if native
    if (flags.and(FConst.Native) != 0)
    {
      if (flags.and(FConst.Const) != 0) err("Invalid combination of 'native' and 'const' modifiers", loc)
      if (flags.and(FConst.Abstract) != 0) err("Invalid combination of 'native' and 'abstract' modifiers", loc)
      if (flags.and(FConst.Static) != 0) err("Invalid combination of 'native' and 'static' modifiers", loc)
    }

    // if const
    if (flags.and(FConst.Const) != 0)
    {
      // invalid const flag combo
      if (flags.and(FConst.Abstract) != 0) err("Invalid combination of 'const' and 'abstract' modifiers", loc)
      else if (flags.and(FConst.Virtual) != 0 && flags.and(FConst.Override) == 0) err("Invalid combination of 'const' and 'virtual' modifiers", loc)
      // invalid type
      if (!f.fieldType.isConstFieldType)
        err("Const field '$f.name' has non-const type '$f.fieldType'", loc)
    }
    else
    {
      // static fields must be const
      if (flags.and(FConst.Static) != 0) err("Static field '$f.name' must be const", loc)
    }

    if (flags.and(FConst.Readonly) != 0) {
      if (flags.and(FConst.Abstract) != 0) err("Invalid combination of 'readonly' and 'abstract' modifiers", loc)
      if (flags.and(FConst.Const) != 0) err("Invalid combination of 'const' and 'readonly' modifiers", loc)
    }

    // check invalid protection combinations on setter (getter
    // can no modifiers which is checked in the parser)
    if (f.setter != null)
    {
      fieldProtection  := flags.and(FConst.ProtectionMask.not)
      setterProtection := f.set.flags.and(FConst.ProtectionMask.not)
      if (fieldProtection != setterProtection)
      {
        // verify protection flag combinations
        checkProtectionFlags(f.set.flags, loc)

        // verify that setter has narrowed protection
        if (fieldProtection.and(FConst.Private) != 0)
        {
          if (setterProtection.and(FConst.Public) != 0)    err("Setter cannot have wider visibility than the field", loc)
          if (setterProtection.and(FConst.Protected) != 0) err("Setter cannot have wider visibility than the field", loc)
          if (setterProtection.and(FConst.Internal) != 0)  err("Setter cannot have wider visibility than the field", loc)
        }
        else if (fieldProtection.and(FConst.Internal) != 0)
        {
          if (setterProtection.and(FConst.Public) != 0)    err("Setter cannot have wider visibility than the field", loc)
          if (setterProtection.and(FConst.Protected) != 0) err("Setter cannot have wider visibility than the field", loc)
        }
        else if (fieldProtection.and(FConst.Protected) != 0)
        {
          if (setterProtection.and(FConst.Public) != 0)    err("Setter cannot have wider visibility than the field", loc)
        }
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// MethodDef
//////////////////////////////////////////////////////////////////////////

  override Void visitMethodDef(MethodDef m)
  {
    // check invalid use of flags
    checkMethodFlags(m)

    // facets
    checkFacets(m.facets)

    // check parameters
    checkParams(m)

    // check return
    checkMethodReturn(m)

    // check ctors call super (or another this) ctor
    if (m.isInstanceCtor) checkInstanceCtor(m)

    // if method has operator facet, check it
    if (m.hasFacet("sys::Operator")) checkOperatorMethod(m)

    // check types used in signature
    if (!m.isAccessor)
    {
      checkTypeProtection(m.returnType, m.loc)
      m.paramDefs.each |ParamDef p| { checkTypeProtection(p.paramType, p.loc) }
    }

    // check that public method isn't using internal types in its signature
    if (!m.isAccessor && curType.isPublic && (m.isPublic || m.isProtected))
    {
      if (!m.returnType.isPublic) err("Public method '${curType.name}.${m.name}' cannot use internal type '$m.returnType'", m.loc);
      m.paramDefs.each |ParamDef p|
      {
        if (!p.paramType.isPublic) err("Public method '${curType.name}.${m.name}' cannot use internal type '$p.paramType'", m.loc);
      }
    }
  }

  private Void checkMethodFlags(MethodDef m)
  {
    // check field accessors in checkFieldFlags
    if (m.isFieldAccessor) return

    flags := m.flags
    loc := m.loc

    // these modifiers are never allowed on a method
    if (flags.and(FConst.Final) != 0)     err("Cannot use 'final' modifier on method", loc)
    if (flags.and(FConst.Const) != 0)     err("Cannot use 'const' modifier on method", loc)
    if (flags.and(FConst.Readonly) != 0)  err("Cannot use 'readonly' modifier on method", loc)

    // check invalid protection combinations
    checkProtectionFlags(flags, loc)

    // check invalid constructor flags
    if (flags.and(FConst.Ctor) != 0)
    {
      if (flags.and(FConst.Abstract) != 0) err("Invalid combination of 'new' and 'abstract' modifiers", loc)
      else if (flags.and(FConst.Override) != 0) err("Invalid combination of 'new' and 'override' modifiers", loc)
      else if (flags.and(FConst.Virtual) != 0) err("Invalid combination of 'new' and 'virtual' modifiers", loc)
      if (flags.and(FConst.Once) != 0)     err("Invalid combination of 'new' and 'once' modifiers", loc)
      if (flags.and(FConst.Native) != 0 && flags.and(FConst.Static) == 0) err("Invalid combination of 'new' and 'native' modifiers", loc)
    }

    // check invalid static flags
    if (flags.and(FConst.Static) != 0)
    {
      if (flags.and(FConst.Abstract) != 0) err("Invalid combination of 'static' and 'abstract' modifiers", loc)
      else if (flags.and(FConst.Override) != 0) err("Invalid combination of 'static' and 'override' modifiers", loc)
      else if (flags.and(FConst.Virtual) != 0) err("Invalid combination of 'static' and 'virtual' modifiers", loc)
      if (flags.and(FConst.Once) != 0) err("Invalid combination of 'static' and 'once' modifiers", loc)
    }

    // check invalid abstract flags
    if (flags.and(FConst.Abstract) != 0)
    {
      if (flags.and(FConst.Native) != 0) err("Invalid combination of 'abstract' and 'native' modifiers", loc)
      if (flags.and(FConst.Once) != 0) err("Invalid combination of 'abstract' and 'once' modifiers", loc)
    }

    // mixins cannot have once methods
    if (flags.and(FConst.Once) != 0)
    {
      if (curType.isMixin)
        err("Mixins cannot have once methods", m.loc)
    }

    // mixins cannot have native methods
    if (flags.and(FConst.Native) != 0)
    {
      //TODO native mixin
      if (curType.isMixin)
        err("Mixins cannot have native methods", m.loc)
    }

    // normalize method flags after checking
    if (m.flags.and(FConst.Static) != 0)
      m.flags = flags.or(FConst.Const);
  }

  private Void checkParams(MethodDef m)
  {
    // check that defs are contiguous after first one
    seenDef := false
    m.paramDefs.each |ParamDef p|
    {
      checkParam(p)
      if (seenDef)
      {
        if (p.def == null)
          err("Parameter '$p.name' must have default", p.loc)
      }
      else
      {
        seenDef = p.def != null
      }
    }
  }

  private Void checkParam(ParamDef p)
  {
    // check type
    t := p.paramType
    if (t.isVoid) { err("Cannot use Void as parameter type", p.loc); return }
    if (t.isThis)  { err("Cannot use This as parameter type", p.loc); return }
    if (t.toNonNullable.signature != "sys::Func<sys::Void,sys::This>") {
      checkValidType(p.loc, t)
    }
    // check parameter default type
    if (p.def != null)// && !p.paramType.isGenericParameter)
    {
      p.def = coerce(p.def, p.paramType.raw) |->|
      {
        err("'$p.def.toTypeStr' is not assignable to '$p.paramType'", p.def.loc)
      }
    }
  }

  private Void checkMethodReturn(MethodDef m)
  {
    if (m.ret.isThis)
    {
      if (m.isStatic)
        err("Cannot return This from static method", m.loc)

      if (m.ret.isNullable)
        err("This type cannot be nullable", m.loc)
    }

    if (!m.ret.isThis && !m.ret.isVoid)
      checkValidType(m.loc, m.ret)
  }

  private Void checkInstanceCtor(MethodDef m)
  {
    // mixins cannot have constructors
    if (curType.isMixin)
      err("Mixins cannot have instance constructors", m.loc)

    // ensure super/this constructor is called
    if (m.ctorChain == null && /*!compiler.isSys &&*/ curType.base != null 
      && !curType.base.isObj && !curType.isSynthetic && !curType.isNative)
      err("Must call super class constructor in '$m.name'", m.loc)

    // if this constructor doesn't call a this
    // constructor, then check for definite assignment
    if (m.ctorChain?.target?.id !== ExprId.thisExpr)
      checkDefiniteAssign(m)
  }

  private Void checkDefiniteAssign(MethodDef? m)
  {
    //if (isSys) return
    if (curType != null && curType.isNative) return

    // get fields which:
    //   - instance or static fields based on ctor or static {}
    //   - aren't abstract or native
    //   - override of abstract (no concrete base)
    //   - not a calculated field (has storage)
    //   - have a non-nullable, non-value type
    //   - don't have have an init expression
    isStaticInit  := m == null || m.isStatic
    fields := curType.fieldDefs.findAll |FieldDef f->Bool|
    {
      f.isStatic == isStaticInit &&
      !f.isAbstract && !f.isNative && f.isStorage &&
      (!f.isOverride || f.concreteBase == null) &&
      !f.fieldType.isNullable && !f.fieldType.isJavaVal && f.init == null
    }
    if (fields.isEmpty) return

    // check that each one is definitely assigned
    fields.each |FieldDef f|
    {
      definite := m != null && m.code != null && m.code.isDefiniteAssign |Expr lhs->Bool|
      {
        // can't be assignment if if lhs is not a field
        if (lhs.id !== ExprId.field) return false

        // check that field assignment to the correct slot
        fe := (FieldExpr)lhs
        if (fe.field.qname != f.qname) return false

        // if no target assume static init
        ft := fe.target
        if (isStaticInit || ft == null) return true

        // check if we are assigning the field inside an
        // closure, in which case move check to runtime
        if (ft.id === ExprId.field && ((FieldExpr)ft).field.name == "\$this")
        {
          f.requiresNullCheck = true;
          return true
        }

        // otherwise must be assignment to this instance
        return ft.id === ExprId.thisExpr
      }
      if (definite) return

      // if we didn't have a definite assignment on an it-block
      // constructor that is ok, we just mark the field as requiring
      // a runtime check in ConstChecks step
      if (m != null && m.isItBlockCtor) { f.requiresNullCheck = true; return }

      // report error
      if (isStaticInit)
        err("Non-nullable field '$f.name' must be assigned in static initializer", f.loc)
      else
        err("Non-nullable field '$f.name' must be assigned in constructor '$m.name'", m.loc)
    }
  }

  private Void checkOperatorMethod(MethodDef m)
  {
    prefix := COperators.toPrefix(m.name)
    if (prefix == null) { err("Operator method '$m.name' has invalid name", m.loc); return }
    op := ShortcutOp.fromPrefix(prefix)

    if (m.name == "add" && !m.returnType.isThis /*&& !isSys*/)
      err("Operator method '$m.name' must return This", m.loc)

    if (m.returnType.isVoid && op !== ShortcutOp.set)
      err("Operator method '$m.name' cannot return Void", m.loc)

    if (m.params.size+1 != op.degree && !(m.params.getSafe(op.degree-1)?.hasDefault ?: false))
      err("Operator method '$m.name' has wrong number of parameters", m.loc)
  }

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  Void checkFacets(FacetDef[]? facets)
  {
    if (facets == null) return

    // check each facet (and for dups)
    for (i := 0; i < facets.size; ++i)
    {
      f := facets[i]
      checkFacet(f)
      for (j := i+1; j < facets.size; ++j)
        if (f.type.qname == facets[j].type.qname)
          err("Duplicate facet '$f.type'", f.loc)
    }
  }

  Void checkFacet(FacetDef f)
  {
    // check that facet type is actually a facet
    if (!f.type.fits(ns.facetType))
      err("Not a facet type '$f.type'", f.loc)

    // check facet field assignments
    f.names.each |name, i|
    {
      val := f.vals[i]

      // check that field exists
      field := f.type.field(name)
      if (field == null)
      {
        err("Unknown facet field '${f.type}.$name'", val.loc)
        return
      }

      // check if facet field is deprecated
      checkDeprecated(field, val.loc)

      // if null literal
      if (val.id == ExprId.nullLiteral)
      {
        if (!field.fieldType.isNullable)
          err("Cannot assign null to non-nullable facet field '$name': '$field.fieldType'", val.loc)
      }

      // otherwise check field type (no coersion allowed)
      else
      {
        if (!val.ctype.fits(field.fieldType))
          err("Invalid type for facet field '$name': expected '$field.fieldType' not '$val.ctype'", val.loc)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Statements
//////////////////////////////////////////////////////////////////////////

  override Void enterStmt(Stmt stmt)
  {
    if (stmt.id == StmtId.tryStmt) protectedRegionDepth++
  }

  override Void exitStmt(Stmt stmt)
  {
    if (stmt.id == StmtId.tryStmt) protectedRegionDepth--
  }

  override Void enterFinally(TryStmt stmt)
  {
    finallyDepth++
  }

  override Void exitFinally(TryStmt stmt)
  {
    finallyDepth--
  }

  override Stmt[]? visitStmt(Stmt stmt)
  {
    switch (stmt.id)
    {
      case StmtId.expr:          checkExprStmt((ExprStmt)stmt)
      case StmtId.localDef:      checkLocalDef((LocalDefStmt)stmt)
      case StmtId.ifStmt:        checkIf((IfStmt)stmt)
      case StmtId.returnStmt:    checkReturn((ReturnStmt)stmt)
      case StmtId.throwStmt:     checkThrow((ThrowStmt)stmt)
      case StmtId.forStmt:       checkFor((ForStmt)stmt)
      case StmtId.whileStmt:     checkWhile((WhileStmt)stmt)
      case StmtId.breakStmt:     checkBreak((BreakStmt)stmt)
      case StmtId.continueStmt:  checkContinue((ContinueStmt)stmt)
      case StmtId.tryStmt:       checkTry((TryStmt)stmt)
      case StmtId.switchStmt:    checkSwitch((SwitchStmt)stmt)
    }
    return null
  }

  private Void checkExprStmt(ExprStmt stmt)
  {
    if (!stmt.expr.isStmt)
      err("Not a statement", stmt.expr.loc)
  }

  private Void checkLocalDef(LocalDefStmt stmt)
  {
    // check not Void
    t := stmt.ctype
    if (t.isVoid) { err("Cannot use Void as local variable type", stmt.loc); return }
    if (t.isThis) { err("Cannot use This as local variable type", stmt.loc); return }
    
    conflict := curUnit.importedTypes[stmt.var_v.name]
    if (conflict != null && conflict.size > 0)
      err("Variable name conflicts with imported type '$conflict.first'", stmt.loc)
    
    checkValidType(stmt.loc, t)
  }

  private Void checkIf(IfStmt stmt)
  {
    stmt.condition = coerce(stmt.condition, ns.boolType) |->|
    {
      err("If condition must be Bool, not '$stmt.condition.ctype'", stmt.condition.loc)
    }
  }

  private Void checkThrow(ThrowStmt stmt)
  {
    stmt.exception = coerce(stmt.exception, ns.errType) |->|
    {
      err("Must throw Err, not '$stmt.exception.ctype'", stmt.exception.loc)
    }
  }

  private Void checkThrowExpr(ThrowExpr expr)
  {
    expr.exception = coerce(expr.exception, ns.errType) |->|
    {
      err("Must throw Err, not '$expr.exception.ctype'", expr.exception.loc)
    }
  }

  private Void checkFor(ForStmt stmt)
  {
    if (stmt.condition != null)
    {
      stmt.condition = coerce(stmt.condition, ns.boolType) |->|
      {
        err("For condition must be Bool, not '$stmt.condition.ctype'", stmt.condition.loc)
      }
    }
  }

  private Void checkWhile(WhileStmt stmt)
  {
    stmt.condition = coerce(stmt.condition, ns.boolType) |->|
    {
      err("While condition must be Bool, not '$stmt.condition.ctype'", stmt.condition.loc)
    }
  }

  private Void checkBreak(BreakStmt stmt)
  {
    if (stmt.loop == null)
      err("Break outside of loop (break is implicit in switch)", stmt.loc)

    // can't leave control of a finally block
    if (finallyDepth > 0)
      err("Cannot leave finally block", stmt.loc)
  }

  private Void checkContinue(ContinueStmt stmt)
  {
    if (stmt.loop == null)
      err("Continue outside of loop", stmt.loc)

    // can't leave control of a finally block
    if (finallyDepth > 0)
      err("Cannot leave finally block", stmt.loc)
  }

  private Void checkReturn(ReturnStmt stmt)
  {
    ret := curMethod.ret
    if (stmt.expr == null)
    {
      // this is just a sanity check - it should be caught in parser
      if (!ret.isVoid)
        err("Must return a value from non-Void method", stmt.loc)
    }
    else if (ret.isVoid)
    {
      // Void allows returning of anything
      if (!stmt.expr.ctype.isVoid) {
        err("Cannot return a value from Void method", stmt.loc)
      }
    }
    else if (ret.isThis)
    {
      stmt.expr = coerce(stmt.expr, curType.asRef) |->|
      {
        err("Cannot return '$stmt.expr.toTypeStr' as $curType This", stmt.expr.loc)
      }
    }
    else
    {
      stmt.expr = coerce(stmt.expr, ret) |->|
      {
        err("Cannot return '$stmt.expr.toTypeStr' as '$ret'", stmt.expr.loc)
      }
    }

    // can't use return inside an it-block (might be confusing)
    if (!stmt.isSynthetic && curType.isClosure && curType.closure.isItBlock && !stmt.isLocal)
      warn("Cannot use return inside it-block", stmt.loc)

    // can't leave control of a finally block
    if (finallyDepth > 0)
      err("Cannot leave finally block", stmt.loc)

    // add temp local var if returning from a protected region,
    // we always call this variable "$return" and reuse it if
    // already declared by a previous return
    if (stmt.expr != null && protectedRegionDepth > 0 && !stmt.expr.ctype.isVoid)
    {
      v := curMethod.code.vars.find |MethodVar v->Bool| { v.name == "\$return" }
      if (v == null) v = curMethod.addLocalVar(stmt.loc, stmt.expr.ctype, "\$return", null)
      stmt.leaveVar = v
    }
  }

  private Void checkTry(TryStmt stmt)
  {
    // check that try block not empty
    if (stmt.block.isEmpty)
      err("Try block cannot be empty", stmt.loc)

    // check each catch
    caught := CType[,]
    stmt.catches.each |Catch c|
    {
      CType? errType := c.errType
      if (errType == null) errType = ns.errType
      checkTypeProtection(errType, c.loc)
      if (!errType.fits(ns.errType))
        err("Must catch Err, not '$c.errType'", c.errType.loc)
      else if (errType.fitsAny(caught))
        err("Already caught '$errType'", c.loc)
      caught.add(errType)
    }
  }

  private Void checkSwitch(SwitchStmt stmt)
  {
    dups := [Int:Int][:]

    stmt.cases.each |Case c|
    {
      for (i:=0; i<c.cases.size; ++i)
      {
        expr := c.cases[i]

        // check comparability of condition and each case
        checkCompare(expr, stmt.condition)

        // check for dups
        literal := expr.asTableSwitchCase
        if (literal != null)
        {
          if (dups[literal] == null)
            dups[literal] = literal
          else
            err("Duplicate case label", expr.loc)
        }
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Expr
//////////////////////////////////////////////////////////////////////////

  override Expr visitExpr(Expr expr)
  {
    switch (expr.id)
    {
      case ExprId.typeLiteral:    checkTypeLiteral(expr)
      case ExprId.slotLiteral:    checkSlotLiteral(expr)
      case ExprId.listLiteral:    checkListLiteral(expr)
      case ExprId.mapLiteral:     checkMapLiteral(expr)
      case ExprId.rangeLiteral:   checkRangeLiteral(expr)
      case ExprId.boolNot:        checkBool(expr)
      case ExprId.cmpNull:
      case ExprId.cmpNotNull:     checkCompareNull(expr)
      case ExprId.assign:         checkAssign(expr)
      case ExprId.elvis:          checkElvis(expr)
      case ExprId.boolOr:
      case ExprId.boolAnd:        checkBools(expr)
      case ExprId.same:
      case ExprId.notSame:        checkSame(expr)
      case ExprId.shortcut:       checkShortcut(expr)
      case ExprId.call:           checkCall(expr)
      case ExprId.construction:   checkConstruction(expr)
      case ExprId.field:          checkField(expr)
      case ExprId.thisExpr:       checkThis(expr)
      case ExprId.superExpr:      checkSuper(expr)
      case ExprId.isExpr:
      case ExprId.isnotExpr:
      case ExprId.asExpr:
      case ExprId.coerce:         checkTypeCheck(expr)
      case ExprId.ternary:        checkTernary(expr)
      case ExprId.throwExpr:      checkThrowExpr(expr)
      case ExprId.addressOfExpr:  checkAddressOf(expr)
    }
    return expr
  }

  private Void checkAddressOf(AddressOfExpr expr) {
    if (!expr.var_v.isAssignable)
      err("addressof is not lvalue", expr.var_v.loc)
  }

  private Void checkTypeLiteral(LiteralExpr expr)
  {
    checkTypeProtection((CType)expr.val, expr.loc)
  }

  private Void checkSlotLiteral(SlotLiteralExpr expr)
  {
    checkSlotProtection(expr.slot, expr.loc)
  }

  private Void checkListLiteral(ListLiteralExpr expr)
  {
    // check the types and ensure that everything gets boxed
    listType := expr.ctype
    valType := listType.genericArgs.first
    expr.vals.each |Expr val, Int i|
    {
      expr.vals[i] = coerceBoxed(val, valType) |->|
      {
        err("Invalid value type '$val.toTypeStr' for list of '$valType'", val.loc)
      }
    }
  }

  private Void checkMapLiteral(MapLiteralExpr expr)
  {
    // check the types and ensure that everything gets boxed
    mapType := expr.ctype
    keyType := mapType.genericArgs[0]
    valType := mapType.genericArgs[1]
    expr.keys.each |Expr key, Int i|
    {
      expr.keys[i] = coerceBoxed(key, keyType) |->|
      {
        err("Invalid key type '$key.toTypeStr' for map type '$mapType'", key.loc)
      }

      val := expr.vals[i]
      expr.vals[i] = coerceBoxed(val, valType) |->|
      {
        err("Invalid value type '$val.toTypeStr' for map type '$mapType'", val.loc)
      }
    }
  }

  private Void checkRangeLiteral(RangeLiteralExpr range)
  {
    range.start = coerce(range.start, ns.intType) |->|
    {
      err("Range must be Int..Int, not '${range.start.ctype}..${range.end.ctype}'", range.loc)
    }
    range.end = coerce(range.end, ns.intType) |->|
    {
      err("Range must be Int..Int, not '${range.start.ctype}..${range.end.ctype}'", range.loc)
    }
  }

  private Void checkBool(UnaryExpr expr)
  {
    expr.operand = coerce(expr.operand, ns.boolType) |->|
    {
      err("Cannot apply '$expr.opToken.symbol' operator to '$expr.operand.ctype'", expr.loc)
    }
  }

  private Void checkCompareNull(UnaryExpr expr)
  {
    // check if operand is nullable, if so its ok
    t := expr.operand.ctype
    if (t.isNullable) return

    // check if operand is inside it-block ctor; we allow null checks
    // on non-nullable fields (like Str) during construction, but not
    // value types (like Int)
    if (curMethod != null && curMethod.isItBlockCtor)
    {
      // check that operand is this.{field} access
      field := expr.operand as FieldExpr
      if (field != null && field.target != null && field.target.id == ExprId.thisExpr && !field.ctype.isVal)
        return
    }

    // if we made it here, compirson to null is an error
    err("Comparison of non-nullable type '$t' to null", expr.loc)
  }

  private Void checkBools(CondExpr expr)
  {
    expr.operands.each |Expr operand, Int i|
    {
      expr.operands[i] = coerce(operand, ns.boolType) |->|
      {
        err("Cannot apply '$expr.opToken.symbol' operator to '$operand.ctype'", operand.loc)
      }
    }
  }

  private Void checkSame(BinaryExpr expr)
  {
    checkCompare(expr.lhs, expr.rhs)

    // don't allow for value types
    if (expr.lhs.ctype.isVal || expr.rhs.ctype.isVal)
      err("Cannot use '$expr.opToken.symbol' operator with value types", expr.loc)
  }

  private Bool checkCompare(Expr lhs, Expr rhs)
  {
    if (!lhs.ctype.fits(rhs.ctype) && !rhs.ctype.fits(lhs.ctype))
    {
      err("Incomparable types '$lhs.ctype' and '$rhs.ctype'", lhs.loc)
      return false
    }
    return true
  }

  private Void checkAssign(BinaryExpr expr)
  {
    // check that rhs is assignable to lhs
    expr.rhs = coerce(expr.rhs, expr.lhs.ctype) |->|
    {
      err("'$expr.rhs.toTypeStr' is not assignable to '$expr.lhs.ctype'", expr.rhs.loc)
    }

    // check that lhs is assignable
    if (!expr.lhs.isAssignable)
      err("Left hand side is not assignable", expr.lhs.loc)

    // check not assigning to same variable
    if (expr.lhs.sameVarAs(expr.rhs))
      err("Self assignment", expr.lhs.loc)

    // check left hand side field (common code with checkShortcut)
    if (expr.lhs.id === ExprId.field)
      expr.rhs = checkAssignField((FieldExpr)expr.lhs, expr.rhs)

    // check that no safe calls used on entire left hand side
    checkNoNullSafes(expr.lhs)

    // take this opportunity to generate a temp local variable if needed
    if (expr.leave && expr.lhs.assignRequiresTempVar)
      expr.tempVar = curMethod.addLocalVar(expr.loc, expr.lhs.ctype, null, null)
  }

  private Void checkElvis(BinaryExpr expr)
  {
    if (!expr.lhs.ctype.isNullable)
      err("Cannot use '?:' operator on non-nullable type '$expr.lhs.ctype'", expr.loc)

    expr.rhs = coerce(expr.rhs, expr.ctype) |->|
    {
      err("Cannot coerce '$expr.rhs.toTypeStr' to '$expr.ctype'", expr.rhs.loc);
    }
  }

  private Void checkNoNullSafes(Expr? x)
  {
    while (x is NameExpr)
    {
      ne := (NameExpr)x
      if (ne.isSafe) err("Null-safe operator on left hand side of assignment", x.loc)
      x = ne.target
    }
  }

  private Void checkShortcut(ShortcutExpr shortcut)
  {
    switch (shortcut.opToken)
    {
      // comparable
      case Token.eq: case Token.notEq:
      case Token.gt: case Token.gtEq:
      case Token.lt: case Token.ltEq:
      case Token.cmp:
        if (!checkCompare(shortcut.target, shortcut.args.first)) return
    }

    // if assignment
    if (shortcut.isAssign)
    {
      lhs := shortcut.target
      ret := shortcut.method.returnType

      // check that lhs is assignable
      if (!lhs.isAssignable)
        err("Target is not assignable", lhs.loc)

      // if the expression fits to type (no coercion supported)
      if (!ret.isThis && !lhs.ctype.fits(ret))
        err("'$ret' is not assignable to '$lhs.ctype'", lhs.loc)

      // check left hand side field (common code with checkAssign)
      if (lhs.id === ExprId.field)
        checkAssignField((FieldExpr)lhs, shortcut.args.first)

      // check that no safe calls used on entire left hand side
      checkNoNullSafes(lhs)
    }

    // take this oppotunity to generate a temp local variable if needed
    if (shortcut.leave && shortcut.isAssign && shortcut.target.assignRequiresTempVar)
      shortcut.tempVar = curMethod.addLocalVar(shortcut.loc, shortcut.ctype, null, null)

    // we need two scratch variables to manipulate the stack cause
    // .NET is lame when it comes to doing anything with the stack
    //   - scratchA: target collection
    //   - scratchB: index
    indexedAssign := shortcut as IndexedAssignExpr
    if (indexedAssign != null)
    {
      target := (ShortcutExpr)indexedAssign.target
      indexedAssign.scratchA = curMethod.addLocalVar(target.loc, target.target.ctype, null, null)
      indexedAssign.scratchB = curMethod.addLocalVar(target.loc, target.args[0].ctype, null, null)
    }

    // perform normal call checking
    if (!shortcut.isCompare)
      checkCall(shortcut)
  }

  ** Check if field is assignable, return new rhs.
  private Expr? checkAssignField(FieldExpr lhs, Expr? rhs)
  {
    field := ((FieldExpr)lhs).field

    // check protection scope (which might be more narrow than the scope
    // of the entire field as checked in checkProtection by checkField)
    if (field.setter != null && slotProtectionErr(curType, field) == null)
      checkSlotProtection(field.setter, lhs.loc, true)

    // if not-const we are done
    if (!field.isConst && !field.isReadonly) return rhs

    // for purposes of const field checking, consider closures
    // inside a constructor or static initializer to be ok
    inType := curType
    inMethod := curMethod
    if (inType.isClosure)
    {
      //curType.closure.setsConst = true
      inType = inType.closure.enclosingType
      inMethod = (curType.closure.enclosingSlot as MethodDef) ?: curMethod
    }

    // check attempt to set static field outside of static initializer
    if (field.isStatic && !inMethod.isStaticInit)
    {
      err("Cannot set const static field '$field.name' outside of static initializer", lhs.loc)
      return rhs
    }

    // we allow setting an instance ctor field in an
    // it-block, otherwise dive in for further checking
    if (curType.isClosure && curType.closure.isItBlock && 
      lhs.target is ItExpr &&
      curType.closure.followCtorType == curType.closure.itType &&
      curType.closure.followCtorType.fits(field.parent.asRef)) {
      //pass
    }
    else
    {
      // check attempt to set field outside of owning class or subclass
      if (inType != field.parent)
      {
        if (!inType.asRef().fits(field.parent.asRef) || !inMethod.isInstanceCtor)
        {
          if (field.parent.isVal) err("Cannot set struct field '$field.qname'", lhs.loc)
          else err("Cannot set const field '$field.qname'", lhs.loc)
          return rhs
        }
      }

      // check attempt to set instance field outside of ctor
      if (!field.isStatic && !(inMethod.isInstanceInit || inMethod.isInstanceCtor))
      {
        if (field.parent.isVal) err("Cannot set struct field '$field.qname'", lhs.loc)
        else err("Cannot set const field '$field.name' outside of constructor", lhs.loc)
        return rhs
      }
    }

    // any other errors should already be logged at this point (see isConstFieldType)
    if (field.isConst) {
      // if non-const make an implicit call toImmutable
      ftype := field.fieldType
      if (ftype.isConst)
        return rhs
      else
        return implicitToImmutable(ftype, rhs)
    }
    return rhs
  }

  private Expr implicitToImmutable(CType fieldType, Expr rhs)
  {
    // leave null literal as is
    if (rhs.id == ExprId.nullLiteral) return rhs

    // wrap existing assigned with call toImmutable
    call := CallExpr.makeWithMethod(rhs.loc, rhs, ns.objToImmutable) { isSafe = true }
    if (fieldType.toNonNullable.isObj) return call
    return TypeCheckExpr.coerce(call, fieldType)

  }

  private Void checkConstruction(CallExpr call)
  {
    if (!call.method.isCtor)
    {
      //warn("Using static method '$call.method.qname' as constructor", call.loc)

      // check that ctor method is the expected type
      if (call.ctype.toNonNullable != call.method.returnType.toNonNullable)
        err("Construction method '$call.method.qname' must return '$call.ctype.name'", call.loc)

      // but allow ctor to be typed as nullable
      call.ctype = call.method.returnType
    }

    checkCall(call)
  }

  private Void checkCall(CallExpr call)
  {
    m := call.method
    if (m == null)
    {
      err("Something wrong with method call?", call.loc)
      return
    }

    name := m.name
    
    // can't call method on Void
    if (call.target != null && call.target.ctype.isVoid)
    {
      err("Cannot call method on Void", call.loc)
      return
    }

    // check protection scope
    checkSlotProtection(call.method, call.loc)

    // if a foreign function, then verify we aren't using unsupported types
    if (m.isForeign)
    {
      // just log one use of unsupported return or param type and return
      if (!m.returnType.typeDef.isSupported)
      {
        err("Method '$name' uses unsupported type '$m.returnType'", call.loc)
        return
      }
      unsupported := m.params.find |CParam p->Bool| { !p.paramType.typeDef.isSupported }
      if (unsupported != null)
      {
        err("Method '$name' uses unsupported type '$unsupported.paramType'", call.loc)
        return
      }
    }

    // arguments
    if (!call.isDynamic || call.isCheckedCall)
    {
      // do normal call checking and coercion
      checkArgs(call)
    }
    
    if (call.isDynamic)
    {
      // if dynamic all ensure all the args are boxed
      call.args.each |Expr arg, Int i| { call.args[i] = box(call.args[i]) }
    }

    // if constructor
    if (m.isCtor && !call.isCtorChain)
    {
      // ensure we aren't calling constructors on an instance
      if (call.target != null && call.target.id !== ExprId.staticTarget && !call.target.synthetic)
        err("Cannot call constructor '$name' on instance", call.loc)

      // ensure we aren't calling a constructor on an abstract class
      if (m.parent.isAbstract && !m.isStatic)
        err("Calling constructor on abstract class", call.loc)
    }

    // ensure we aren't calling static methods on an instance
    if (m.isStatic)
    {
      if (call.target != null && call.target.id !== ExprId.staticTarget)
        err("Cannot call static method '$name' on instance", call.loc)
    }

    // ensure we can't calling an instance method statically
    if (!m.isStatic && !m.isCtor)
    {
      if (call.target == null || call.target.id === ExprId.staticTarget)
        err("Cannot call instance method '$name' in static context", call.loc)
    }

    // if using super
    if (call.target != null && call.target.id === ExprId.superExpr)
    {
      // check that super is concrete
      if (m.isAbstract)
        err("Cannot use super to call abstract method '$m.qname'", call.target.loc)

      // check that calling super with exact param match otherwise stack overflow
      if (call.args.size != m.params.size && m.name == curMethod.name && !m.isInstanceCtor)
        err("Must call super method '$m.qname' with exactly $m.params.size arguments", call.target.loc)
    }

    // don't allow safe calls on static type
    if (call.isSafe && call.target != null && call.target.id === ExprId.staticTarget) {
      err("Cannot use null-safe call on static target type '$call.target.ctype'", call.target.loc)
      return
    }

    if (call.isSafe && call.target != null && !call.target.ctype.isNullable)
      err("Cannot use null-safe call on non-nullable type '$call.target.ctype'", call.target.loc)

    // if this call is not null safe, then verify that it's target isn't
    // a null safe call such as foo?.bar.baz
    if (!call.isSafe && call.target is NameExpr && ((NameExpr)call.target).isSafe)
    {
      err("Non-null safe call chained after null safe call", call.loc)
      return
    }

    // if calling a method on a value-type, ensure target is
    // coerced to non-null; we don't do this for comparisons
    // and safe calls since they are handled specially
    if (call.target != null && !call.isCompare && !call.isSafe && !call.method.isStatic)
    {
      if (call.target.ctype.isVal || call.method.parent.isVal)
      {
        if (name == "with") { err("Cannot call 'Obj.with' on value type", call.target.loc); return }
        call.target = coerce(call.target, call.method.parent.asRef) |->|
        {
          err("Cannot coerce '$call.target.ctype' to '$call.method.parent'", call.target.loc)
        }
      }
    }

    // ensure call operator target() not used on non-function types
    if (call.isCallOp && !call.target.ctype.isFunc)
      err("Cannot use () call operator on non-func type '$call.target.ctype'", call.target.loc)

    // ensure @Operator when using add as it-block comma operator
    if (call.isItAdd && !call.method.hasFacet("sys::Operator"))
      err("Missing Operator facet: $call.method.qname", call.loc)
  }

  private Void checkField(FieldExpr f)
  {
    field := f.field

    // check protection scope
    checkSlotProtection(field, f.loc)

    // if a FFI, then verify we aren't using unsupported types
    if (!field.fieldType.typeDef.isSupported)
    {
      err("Field '$field.name' has unsupported type '$field.fieldType'", f.loc)
      return
    }

    // ensure we aren't calling static methods on an instance
    if (field.isStatic)
    {
      if (f.target != null && f.target.id !== ExprId.staticTarget)
        err("Cannot access static field '$f.name' on instance", f.loc)
    }

    // if instance field
    else
    {
      if (f.target == null || f.target.id === ExprId.staticTarget)
        err("Cannot access instance field '$f.name' in static context", f.loc)
    }

    // if using super check that concrete
    if (f.target != null && f.target.id === ExprId.superExpr)
    {
      if (field.isAbstract)
        err("Cannot use super to access abstract field '$field.qname'", f.target.loc)
    }

    // don't allow safe access on non-nullable type
    if (f.isSafe && f.target != null && !f.target.ctype.isNullable)
      err("Cannot use null-safe access on non-nullable type '$f.target.ctype'", f.target.loc)

    // if this call is not null safe, then verify that it's target isn't
    // a null safe call such as foo?.bar.baz
    if (!f.isSafe && f.target is NameExpr && ((NameExpr)f.target).isSafe)
    {
      err("Non-null safe field access chained after null safe call", f.loc)
      return
    }

    // if using the field's accessor method
    if (f.useAccessor)
    {
      // check if we can optimize out the accessor (required for constants)
      f.useAccessor = useFieldAccessor(field)

      // check that we aren't using an field accessor inside of itself
      if (curMethod != null && (field.getter === curMethod || field.setter === curMethod) &&
          (f.target == null || f.target.id == ExprId.thisExpr))
        err("Cannot use field accessor inside accessor itself - use '&' operator", f.loc)
    }

    // if accessing storage directly
    else
    {
      // check that the current class gets access to direct
      // field storage (only defining class gets it); allow closures
      // same scope priviledges as enclosing class
      enclosing := curType.isClosure ? curType.closure.enclosingType : curType
      if (!field.isConst && !field.isReadonly && field.parent.qname != curType.qname &&
         field.parent.qname != enclosing.qname)
      {
        err("Field storage for '$field.qname' not accessible", f.loc)
        return
      }

      // sanity check that field has storage
      if (!field.isStorage)
      {
        if (field is FieldDef && ((FieldDef)field).concreteBase != null)
          err("Field storage of inherited field '${field->concreteBase->qname}' not accessible (might try super)", f.loc)
        else {
          err("Invalid storage access of field '$field.qname' which doesn't have storage", f.loc)
        }
        return
      }

      // cannot use storage operator in mixin
      if (enclosing.isMixin && !curMethod.isSynthetic)
      {
        err("Field storage not accessible in mixin '$field.qname'", f.loc)
        return
      }
    }
  }

  private Bool useFieldAccessor(CField f)
  {
    // if const field then use field directly
    if (f.isConst || f.isReadonly || f.getter == null) return false

    // always use accessor if field is imported from another
    // pod (in which case it isn't a def in my compilation unit)
    def := f as FieldDef
    if (def == null) return true

    // if virtual/override/native then always use accessor
    if (def.isVirtual || def.isOverride || f.isNative)
      return true

    // if the field has synthetic getter and setter, then
    // we can safely optimize internal field accessors to
    // use field directly
    if (!def.hasGet && !def.hasSet)
      return false

    // use accessor since there is a custom getter or setter
    return true
  }

  private Void checkThis(ThisExpr expr)
  {
    if (inStatic)
      err("Cannot access 'this' in static context", expr.loc)
  }

  private Void checkSuper(SuperExpr expr)
  {
    if (inStatic)
      err("Cannot access 'super' in static context", expr.loc)

    if (curType.isMixin)
    {
      if (expr.explicitType == null)
        err("Must use named 'super' inside mixin", expr.loc)
      else if (!expr.explicitType.isMixin)
        err("Cannot use 'Obj.super' inside mixin (yeah I know - take it up with Sun)", expr.loc)
    }

    if (expr.explicitType != null)
    {
      if (expr.explicitType.isClass)
        err("Cannot use named super on class type '$expr.explicitType'", expr.loc)

      if (!curType.asRef.fits(expr.explicitType))
        err("Named super '$expr.explicitType' not a super class of '$curType.name'", expr.loc)
    }
  }

  private Void checkTypeCheck(TypeCheckExpr expr)
  {
    // don't bother checking a synthetic coercion that the
    // compiler generated itself (which is most coercions)
    if (expr.synthetic) return

    // check type is visible
    checkTypeProtection(expr.check, expr.loc)

    // verify types are convertible
    check := expr.check
    target := expr.target.ctype
    if (!check.fits(target) && !target.fits(check) && !check.isMixin && !target.isMixin)
      err("Inconvertible types '$target' and '$check'", expr.loc)

    // box value types for is, as, isnot (everything but coerce)
    if (expr.id != ExprId.coerce && target.isVal)
      expr.target = box(expr.target)

    // don't allow as with nullable
    if (!curUnit.isFanx && expr.id === ExprId.asExpr && check.isNullable)
      err("Cannot use 'as' operator with nullable type '$check'", expr.loc)
      
    if (curUnit.isFanx && expr.id === ExprId.isExpr && check.isNullable)
      err("Cannot use 'is' operator with nullable type '$check'", expr.loc)
  }

  private Void checkTernary(TernaryExpr expr)
  {
    expr.condition = coerce(expr.condition, ns.boolType) |->|
    {
      err("Ternary condition must be Bool, not '$expr.condition.ctype'", expr.condition.loc)
    }
    expr.trueExpr = coerce(expr.trueExpr, expr.ctype) |->|
    {
      err("Ternary true expr '$expr.trueExpr.toTypeStr' cannot be coerced to $expr.ctype", expr.trueExpr.loc)
    }
    expr.falseExpr = coerce(expr.falseExpr, expr.ctype) |->|
    {
      err("Ternary false expr '$expr.falseExpr.toTypeStr' cannot be coerced to $expr.ctype", expr.falseExpr.loc)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Check Args
//////////////////////////////////////////////////////////////////////////

  private Void checkArgs(CallExpr call)
  {
    method := call.method
    base := call.target == null ? method.parent.asRef : call.target.ctype
    name := call.name
    args := call.args
    newArgs := args.dup
    isErr := false
    params := method.params
    genericParams := method.isTypeErasure ? method.generic.params : null

    // if we are calling call(A, B...) on a FuncType, then
    // use the first class Func signature rather than the
    // version of call which got picked because we might have
    // picked the wrong call version
    if (base.isFunc && name == "call")
    {
      if (base.genericArgs == null || base.genericArgs.size-1 != args.size)
      {
        //ignore on sig.defaultParameterized
        //echo("$base.genericArgs, $base.defaultParameterized, $base.typeDef.typeof")
        if (base.defaultParameterized || base.typeDef.isGeneric) {
          objType := ns.objType.toNullable
          args.size.times |i| {
            newArgs[i] = coerceBoxed(args[i], objType) |->| { isErr = true }
          }
        }
        else
          isErr = true
      }
      else
      {
        base.genericArgs[1..-1].each |CType p, Int i|
        {
          // check each argument and ensure boxed
          newArgs[i] = coerceBoxed(args[i], p) |->| { isErr = true }
        }
      }
    }

    // if more args than params, always an err
    else if (params.size < args.size)
    {
      isErr = true
    }

    // check each arg against each parameter
    else
    {
      params.each |CParam p, Int i|
      {
        if (i >= args.size)
        {
          // param has a default value, then that is ok
          if (!p.hasDefault) isErr = true
        }
        else
        {
          // ensure arg fits parameter type (or auto-cast)
          pt := p.paramType.parameterizeThis(base)
          newArgs[i] = coerce(args[i], pt) |->|
          {
            isErr = name != "compare" // TODO let anything slide for Obj.compare
            //echo("args coerce err: $args[i], $pt")
          }

          // if this a parameterized generic, then we need to box
          // even if the expected type is a value-type (since the
          // actual implementation methods are all Obj based)
          if (!isErr && genericParams != null && genericParams[i].paramType.isGenericParameter)
            newArgs[i] = box(newArgs[i])
        }
      }
    }

    if (!isErr)
    {
      checkNamedParam(call)
      call.args = newArgs
      return
    }

    msg := "Invalid args "
    msg += "$name(" + params.join(", ", |p| { paramTypeStr(base, p) }) + ")"
    msg += ", not (" + args.join(", ", |Expr e->Str| { "$e.toTypeStr" }) + ")"
    err(msg, call.loc)
  }

  internal static Str paramTypeStr(CType base, CParam param)
  {
    //return param.paramType.parameterizeThis(base).inferredAs.signature
    return param.paramType.parameterizeThis(base).toStr
  }

  private Void checkNamedParam(CallExpr call)
  {
    if (call.paramNames == null) return
    //args := call.args
    params := call.method.params
    call.paramNames.each |name, i| {
      if (params[i].name != name) {
        err("named param err: ${params[i].name} != $name in call $call.name", call.loc)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  private Void checkValidType(Loc loc, CType t)
  {
    if (!t.isValid) err("Invalid type '$t'", loc)
    checkParameterizedType(loc, t)
  }

  private Void checkParameterizedType(Loc loc, CType t)
  {
    if (t.isParameterized) {
      ParameterizedType o := t.typeDef
      if (o.defaultParameterized && o.qname != "sys::Func") {
        warn("Expected generic parameter", loc)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Flag Utils
//////////////////////////////////////////////////////////////////////////

  private Void checkProtectionFlags(Int flags, Loc loc)
  {
    isPublic    := flags.and(FConst.Public)    != 0
    isProtected := flags.and(FConst.Protected) != 0
    isPrivate   := flags.and(FConst.Private)   != 0
    isInternal  := flags.and(FConst.Internal)  != 0
    isVirtual   := flags.and(FConst.Virtual)   != 0
    isOverride  := flags.and(FConst.Override)  != 0

    if (isPublic)
    {
      if (isProtected) err("Invalid combination of 'public' and 'protected' modifiers", loc)
      if (isPrivate)   err("Invalid combination of 'public' and 'private' modifiers", loc)
      if (isInternal)  err("Invalid combination of 'public' and 'internal' modifiers", loc)
    }
    else if (isProtected)
    {
      if (isPrivate)   err("Invalid combination of 'protected' and 'private' modifiers", loc)
      if (isInternal)  err("Invalid combination of 'protected' and 'internal' modifiers", loc)
    }
    else if (isPrivate)
    {
      if (isInternal)  err("Invalid combination of 'private' and 'internal' modifiers", loc)
      if (isVirtual && !isOverride) err("Invalid combination of 'private' and 'virtual' modifiers", loc)
    }
  }

  private Void checkTypeProtection(CType t, Loc loc)
  {
    t = t.toNonNullable

    if (t.isParameterized)
    {
      x := (ParameterizedType)t.typeDef
      x.genericArgs.each |p| { checkTypeProtection(p, loc) }
    }
    else if (t.isThis) {
    }
    else
    {
      if (t.isInternal && t.podName != curType.podName)
        err("Internal type '$t' not accessible", loc)
    }

    checkDeprecated(t, loc)
  }

  private Void checkSlotProtection(CSlot slot, Loc loc, Bool setter := false)
  {
    errMsg := slotProtectionErr(curType, slot, setter)
    if (errMsg != null) err(errMsg, loc)

    checkDeprecated(slot, loc)
  }

  static Bool isSlotVisible(TypeDef curType, CSlot slot) { slotProtectionErr(curType, slot) == null }

  private static Str? slotProtectionErr(TypeDef curType, CSlot slot, Bool setter := false)
  {
    msg := setter ? "setter of field" : (slot is CMethod ? "method" : "field")

    // short circuit if method on myself
    if (curType == slot.parent)
      return null

    // allow closures same scope priviledges as enclosing class
    if (curType.isClosure) curType = curType.closure.enclosingType

    // consider the slot internal if its parent is internal
    isInternal := slot.isInternal || (slot.parent.isInternal && !(slot.parent is ParameterizedType))

    if (slot.isPrivate && curType != slot.parent && curType.qname != slot.parent.qname)
      return "Private $msg '$slot.qname' not accessible"

    else if (slot.isProtected && !curType.asRef.fits(slot.parent.asRef) && curType.podName != slot.parent.podName)
      return "Protected $msg '$slot.qname' not accessible"

    else if (isInternal && curType.pod != slot.parent.pod) {
      return "Internal $msg '$slot.qname' not accessible"
    }
    else
      return null
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Check for the deprecated facet where target is CType or CSlot
  **
  private Void checkDeprecated(Obj target, Loc loc)
  {
    slot := target as CSlot

    // don't check inside:
    //   - synthetic getter/setter or
    //   - synthetic method of type itself
    //   - a deprecated type itself
    if (curMethod != null && curMethod.isSynthetic)
    {
      if (curMethod.isFieldAccessor) return
      if (slot != null && slot.parent == curType) return
    }
    if (curType.facetAnno("sys::Deprecated") != null) return

    // check both slot and its parent type
    CFacet? f := null
    if (slot != null)
    {
      f = slot.facetAnno("sys::Deprecated")
      if (f == null) target = slot.parent.asRef
    }
    if (f == null) f = ((CType)target).typeDef.facetAnno("sys::Deprecated")
    if (f == null) return

    // we got a deprecration warning - log it
    kind := target is CType ? "type" : "slot"
    qname := (Str)target->qname
    msg := f.get("msg") as Str ?: ""
    if (!msg.isEmpty)
      warn("Deprecated $kind '$qname' - $msg", loc)
    else
      warn("Deprecated $kind '$qname'", loc)
  }

  **
  ** Ensure the specified expression is boxed to an object reference.
  **
  private Expr box(Expr expr)
  {
    if (expr.ctype.isVal)
      return TypeCheckExpr.coerce(expr, ns.objType.toNullable)
    else
      return expr
  }

  **
  ** Run the standard coerce method and ensure the result is boxed.
  **
  private Expr coerceBoxed(Expr expr, CType expected, |->| onErr)
  {
    return box(coerce(expr, expected, onErr))
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Int protectedRegionDepth := 0  // try statement depth
  private Int finallyDepth := 0          // finally block depth
  //private Bool isSys
}