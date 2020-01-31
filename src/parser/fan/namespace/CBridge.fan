//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Nov 08  Brian Frank  Creation
//

**
** CBridge is the base class for compiler FFI plugins to expose
** external type systems to the Fantom compiler as CPods, CTypes, and
** CSlots.  Subclasses are registered for a FFI name with the
** "compilerBridge" facet and must declare a constructor with a
** Compiler arg.
**
abstract class CBridge
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor with associated compiler.
  **
//  new make(Compiler c) : super(c) {}

//////////////////////////////////////////////////////////////////////////
// Namespace
//////////////////////////////////////////////////////////////////////////

  **
  ** Resolve the specified foreign namespace to a CPod.
  ** Throw a CompilerErr with appropriate message if name
  ** cannot be resolved.
  **
  abstract CPod resolvePod(Str name, Loc? loc)

//////////////////////////////////////////////////////////////////////////
// AST
//////////////////////////////////////////////////////////////////////////

  **
  ** Coerce the target expression to the specified type.  If
  ** the expression is not type compatible run the onErr function.
  ** Default implementation provides standard Fantom coercion.
  **
  ** If the bridge is going to coerce 'expr' into a new expression,
  ** then it should mark the resulting expression as synthetic.
  ** A synthetic expression must be "undoable":
  **   - TypeCheckExpr where target is uncoerced expr
  **   - CallExpr where last argument is uncoerced expr
  ** See ResolveExpr.resolveAssign for more details.
  **
  virtual Expr coerce(Expr expr, CType expected, |->| onErr)
  {
    return Coerce.doCoerce(expr, expected, onErr)
  }

  **
  ** Resolve a construction call.  Type check the arguments
  ** and insert any conversions needed.
  **
  abstract Expr resolveConstruction(CallExpr call)

  **
  ** Resolve a construction chain call where a Fantom constructor
  ** calls the super-class constructor.  Type check the arguments
  ** and insert any conversions needed.
  **
  abstract Expr resolveConstructorChain(CallExpr call)

  **
  ** Given a dot operator slot access on the given foreign
  ** base type, determine the appopriate slot to use based on
  ** whether parens were used
  **   base.name    =>  noParens = true
  **   base.name()  =>  noParens = false
  **
  abstract CSlot? resolveSlotAccess(CType base, Str name, Bool noParens)

  **
  ** Resolve a method call.  Type check the arguments
  ** and insert any conversions needed.
  **
  abstract Expr resolveCall(CallExpr call)

  **
  ** Called during Inherit step when a Fantom slot overrides a FFI slot.
  ** Log and throw compiler error if there is a problem.
  **
  abstract Void checkOverride(TypeDef t, CSlot base, SlotDef def)

  **
  ** Called during CheckErrors step for a type which extends
  ** a FFI class or implements any FFI mixins.
  **
  abstract Void checkType(TypeDef def)

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  ** Guaranteed cleanup hook
  virtual Void cleanup() {}

}