//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Apr 06  Brian Frank  Creation
//

**
** Enum is the base class for enum classes defined using the 'enum'
** keyword.  An enum models a fixed range of discrete values.  Each
** value has an Int ordinal and a Str name.
**
** Every enum class implicitly has the following slots auto-generated
** by the compiler:
**   - a static const field for each name in the enum's range.
**   - a static field called "vals" which contains the list of
**     discrete values indexed by ordinal.
**   - a static method called "fromStr" which maps an enum name
**     to an enum instance
**
** See `docLang::Enums` for details.
**
abstract const class Enum
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Protected constructor - for compiler use only.
  **
  protected new make(Int ordinal, Str name) {
    this._name = name
    this._ordinal = ordinal
  }

  **
  ** Protected fromStr implementation - for compiler use only.
  ** A public static fromStr method is always auto-generated
  ** by the compiler for each enum.
  **
  native protected static Enum? doFromStr(Str type, Str name, Bool checked)
  /*
  protected static Enum? doFromStr(Type t, Str name, Bool checked) {
    slot := t.slot(name, false)
    //TODO
    if (slot != null)// && (slot.flags & FConst.Enum) != 0)
    {
      try
      {
        return (sys::Enum)((Field)slot).get(null)
      }
      catch (sys::Err e)
      {
      }
    }
    if (!checked) return null
    throw ParseErr(t.qname +","+ name)
  }
  */

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Enums are only equal if same instance using ===.
  **
  override Bool equals(Obj? obj) { this === obj }

  **
  ** Compare based on ordinal value.
  **
  override Int compare(Obj obj) {
    return ordinal.compare(((Enum)obj).ordinal)
  }

  **
  ** Always returns name().
  **
  override Str toStr() { name }

/////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the programatic name for this enum.
  **
  private const Str _name
  Str name() { _name }

  **
  ** Return ordinal value which is a zero based index into values.
  **
  private const Int _ordinal
  Int ordinal() { _ordinal }

}