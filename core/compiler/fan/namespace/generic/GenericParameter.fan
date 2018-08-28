//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jul 06  Brian Frank  Creation
//

**************************************************************************
** GenericParameterType
**************************************************************************

**
** GenericParameterType models the generic parameter types
** sys::V, sys::K, etc.
**

class GenericParameter : ProxyType {
  CType bound() { super.root }
  override Str name() { "${parent.name}^${paramName}" }
  override Str qname() { "${parent.qname}^${paramName}" }
  override Str extName()   { "" }
  CType parent
  Str paramName
  Int index

  new make(CNamespace ns, Str name, CType parent, Int index, CType bound := ns.objType.toNullable) : super(bound) {
    this.parent = parent
    this.paramName = name
    this.index = index
  }

  override CPod pod() { parent.pod }

  override CType raw() {
    raw := bound
    if (isNullable) raw = raw.toNullable
    return raw
  }

  override Bool isNullable() { true }

  override Bool hasGenericParameter() { true }
}

