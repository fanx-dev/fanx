//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 Jul 09  Brian Frank  Creation
//   04 Feb 10  Brian Frank  Rework from old Symbol design
//

**************************************************************************
** Serializable
**************************************************************************

**
** Serializable is a facet used to annotate types which can be serialized.
** Objects are serialized via `sys::OutStream.writeObj` and deserialized
** via `sys::InStream.readObj`.
**
** See the [Serialization Doc]`docLang::Serialization` for details.
**
@FacetMeta { inherited = true }
facet class Serializable
{
  **
  ** Simples are serialized atomically via a customized string representation
  ** using the following rules:
  **   - Override `sys::Obj.toStr` to return a suitable string representation
  **     of the object.
  **   - Must declare a static method called 'fromStr' which takes one 'Str'
  **     parameter and returns an instance of the declaring type.  The 'fromStr'
  **     method may contain additional parameters if they declare defaults.
  **
  const Bool simple := false

  **
  ** Collections are serializabled with a collection of child objects
  ** using the following  rules where 'Item' is the item type:
  **   - Provide an 'add(Item)' method to add child items during 'readObj'
  **   - Provide an 'each(|Item| f)' method to iterate children item
  **     during 'writeObj'
  **
  const Bool collection := false
}

**************************************************************************
** Transient
**************************************************************************

**
** Transient is a facet used to annotate fields which
** should not be serialized inside a `Serializable` type.
** See the [Serialization Doc]`docLang::Serialization` for
** details.
**
facet class Transient {}

**************************************************************************
** Js
**************************************************************************

**
** Used to annoate types which should be compiled into JavaScript.
**
//@Deprecated { msg = "use NoJs" }
facet class Js {}
facet class NoJs {}

**************************************************************************
** NoDoc
**************************************************************************

**
** This facet is used on public types and slots to indicate they should
** not be documented with automated tools such as [Fandoc]`fandoc::pod-doc`.
** As a developer you should avoid using these types and slots since they
** are explicitly marked as not part of the public API.
**
facet class NoDoc {}

**************************************************************************
** Deprecated
**************************************************************************

**
** Indicates that a type or slot is obsolete
**
facet class Deprecated
{
  **
  ** Message for compiler output when deprecated type or slot is used.
  **
  const Str msg := ""
}

**************************************************************************
** Operator
**************************************************************************

**
** Used on methods to indicate method may be used an operator.
** The operator symbol is determined by the method name:
**
**   prefix     symbol    degree
**   ------     ------    ------
**   negate     -a        unary
**   increment  ++a       unary
**   decrement  --a       unary
**   plus       a + b     binary
**   minus      a - b     binary
**   mult       a * b     binary
**   div        a / b     binary
**   mod        a % b     binary
**   get        a[b]      binary
**   set        a[b] = c  ternary
**   add        a { b, }
**
** In the case of binary operators multiple methods may
** be declared for a given symbol as long as every method starts
** with correct name, for example "plus" and "plusInt".  For
** unary/ternary operators there can only be one method and it must
** be named exactly "negate", "increment", "decrement", or "set".
**
** See [docLang]`docLang::Methods#operators` for additional details.
**
facet class Operator {}

**************************************************************************
** FacetUsage
**************************************************************************

**
** Facet meta-data applied to facet classes.
**
facet class FacetMeta
{
  **
  ** Indicates whether the facet is inherited by sub-types.
  ** See [docLang]`docLang::Facets#inheritance` for additional details.
  **
  const Bool inherited := false
}

**************************************************************************
** NativePeer
**************************************************************************

**
** to indicate the native class do not emit peer field
**
facet class NoPeer {}

**
** to indicate local native class
**
facet class Extern {
  const Bool simple := false
}
