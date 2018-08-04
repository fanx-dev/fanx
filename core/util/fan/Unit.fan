//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Dec 08  Brian Frank  Creation
//   15 Sep 10  Brian Frank  Significant rework of API
//

**
** Unit models a unit of measurement.  Units are represented as:
**
**  - ids: each unit has one or more unique identifiers for the unit
**    within the VM.  Units are typically defined in the unit database
**    "etc/sys/units.txt" or can be via by the `define` method.
**    Every id assigned to a unit must be unique within the VM.
**
**  - name: the first identifier in the ids list is called the *name*
**    and should be a descriptive summary of the unit using words separated
**    by underbar such as "miles_per_hour".
**
**  - symbol: the last identifier in the ids list should be the
**    abbreviated symbol; for example "kilogram" has the symbol "kg".
**    In units with only one id, the symbol is the same as the name.
**    Units with exponents should use Unicode superscript chars, not
**    ASCII digits.
**
**  - dimension: defines the ratio of the seven SI base units: m, kg,
**    sec, A, K, mol, and cd
**
**  - scale/factor: defines the normalization equations for unit conversion
**
** A unit identifier is limited to the following characters:
**  - any Unicode char over 128
**  - ASCII letters 'a' - 'z' and 'A' - 'Z'
**  - underbar '_'
**  - division sign '/'
**  - percent sign '%'
**  - dollar sign '$'
**
** Units with equal dimensions are considered to the measure the same
** physical quantity.  This is not always true, but good enough for
** practice. Conversions with the 'convertTo' method are expressed with
** the following equations:
**
**   unit       = dimension * scale + offset
**   toNormal   = scalar * scale + offset
**   fromNormal = (scalar - offset) / scale
**   toUnit     = fromUnit.fromNormal( toUnit.toNormal(sclar) )
**
** As a simple, pragmatic solution for modeling Units, there are some
** units which don't fit this model including logarithm and angular units.
** Units which don't cleanly fit this model should be represented as
** dimensionless (all ratios set to zero).
**
** Fantom's model for units of measurement and the unit database are
** derived from the OASIS oBIX specification.
**
@Serializable { simple = true }
native const class Unit
{

//////////////////////////////////////////////////////////////////////////
// Unit Database
//////////////////////////////////////////////////////////////////////////

  **
  ** Define a new Unit definition in the VM's unit database
  ** using the following string format:
  **
  **   unit   := <ids> [";" <dim> [";" <scale> [";" <offset>]]]
  **   names  := <ids> ("," <id>)*
  **   id     := <idChar>*
  **   idChar := 'a'-'z' | 'A'-'Z' | '_' | '%' | '/' | any char > 128
  **   dim    := <ratio> ["*" <ratio>]*   // no whitespace allowed
  **   ratio  := <base> <exp>
  **   base   := "kg" | "m" | "sec" | "K" | "A" | "mol" | "cd"
  **   exp    := <int>
  **   scale  := <float>
  **   offset := <float>
  **
  ** If the format is incorrect or any identifiers are already
  ** defined then throw an exception.
  **
  static Unit define(Str s)

  **
  ** Find a unit by one of its identifiers if it has been defined in this
  ** VM.  If the unit isn't defined yet and checked is false then return
  ** null, otherwise throw Err.  Any units declared in "etc/sys/units.txt"
  ** are implicitly defined.
  **
  static new fromStr(Str s, Bool checked := true)

  **
  ** List all the units currently defined in the VM.  Any units
  ** declared in "etc/sys/units.txt" are implicitly defined.
  **
  static Unit[] list()

  **
  ** List the quantity names used to organize the unit database in
  ** "etc/sys/units.txt".  Quantities are merely a convenient mechanism
  ** to organize the unit database - there is no guarantee that they
  ** include all current VM definitions.
  **
  static Str[] quantities()

  **
  ** Get the units organized under a specific quantity name in the
  ** unit database "etc/sys/units.txt".  Quantities are merely a convenient
  ** mechanism to organize the unit database - there is no guarantee that
  ** they include all current VM definitions.
  **
  static Unit[] quantity(Str quantity)

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two units are equal if they have reference equality
  ** because all units are interned during definition.
  **
  override Bool equals(Obj? that)

  **
  ** Return 'toStr.hash'.
  **
  override Int hash()

  **
  ** Return `symbol`.
  **
  override Str toStr()

  **
  ** Return the list of programatic identifiers for this unit.
  ** The first item is always `name` and the last is always `symbol`.
  **
  Str[] ids()

  **
  ** Return the primary name identifier of this unit.
  ** This is always the first item in `ids`.
  **
  Str name()

  **
  ** Return the abbreviated symbol for this unit.
  ** This is always the last item in `ids`.
  **
  Str symbol()

  **
  ** Return the scale factor used to convert this unit "from normal".
  ** For example the scale factor for kilometer is 1000 because it is
  ** defined as a 1000 meters where meter is the normalized unit for
  ** length.  See class header for normalization and conversion equations.
  ** The scale factor the normalized unit is always one.
  **
  Float scale()

  **
  ** Return the offset factor used to convert this unit "from normal".
  ** See class header for normalization and conversion equations.  Offset
  ** is used most commonly with temperature units.  The offset for
  ** normalized unit is always zero.
  **
  Float offset()

  **
  ** Return string format as specified by `define`.
  **
  Str definition()

//////////////////////////////////////////////////////////////////////////
// Dimension
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the string format of the dimension portion of `definition`
  **
  Str dim()

  **
  ** Kilogram (mass) component of the unit dimension.
  **
  Int kg()

  **
  ** Meter (length) component of the unit dimension.
  **
  Int m()

  **
  ** Second (time) component of the unit dimension.
  **
  Int sec()

  **
  ** Kelvin (thermodynamic temperature) component of the unit dimension.
  **
  Int K()

  **
  ** Ampere (electric current) component of the unit dimension.
  **
  Int A()

  **
  ** Mole (amount of substance) component of the unit dimension.
  **
  Int mol()

  **
  ** Candela (luminous intensity) component of the unit dimension.
  **
  Int cd()

//////////////////////////////////////////////////////////////////////////
// Arithmetic
//////////////////////////////////////////////////////////////////////////

  **
  ** Match the product of this and b against current database definitions.
  ** If an unambiguous match cannot be made then throw Err.
  **
  @Operator Unit mult(Unit that)

  **
  ** Match quotient of this divided by b against current database definitions.
  ** If an unambiguous match cannot be made then throw Err.
  **
  @Operator Unit div(Unit b)

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Convert a scalar value from this unit to the given unit.  If
  ** the units do not have the same dimension then throw Err.
  ** For example, to convert 3km to meters:
  **   m  := Unit("meter")
  **   km := Unit("kilometer")
  **   km.convertTo(3f, m)  =>  3000f
  **
  Float convertTo(Float scalar, Unit unit)

}