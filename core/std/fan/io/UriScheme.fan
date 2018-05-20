//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Aug 08  Brian Frank  Creation
//

**
** UriSchemes are registered to handle a specific Uri scheme such
** as "file" or "http".  Scheme handlers are registered using the pod
** index key "sys.uriScheme.{scheme}={qname}" where "scheme" is
** lowercase scheme name and "qname" is the qualified type name
** of the subclass.  See [docLang]`docLang::Naming` for the details
** of scheme handling works.
**
const mixin UriScheme
{

  **
  ** Lookup a UriScheme for the specified scheme name.
  ** Scheme name must be lower case - note that `Uri.scheme`
  ** is always normalized to lower case.  If the scheme is
  ** not mapped and checked is true then throw UnresolvedErr
  ** otherwise return null.
  **
  native static UriScheme? find(Str scheme, Bool checked := true)

  **
  ** Default implementation returns type qname.
  **
  override Str toStr() { typeof.qname }

  **
  ** Resolve the uri to a Fantom object.  If uri cannot
  ** be resolved by this scheme then throw UnresolvedErr.
  **
  abstract Obj? get(Uri uri, Obj? base)

}

**************************************************************************
** FanScheme
**************************************************************************

internal const class FanScheme : UriScheme
{
  native override Obj? get(Uri uri, Obj? base)
}

**************************************************************************
** FileScheme
**************************************************************************

internal const class FileScheme : UriScheme
{
  override Obj? get(Uri uri, Obj? base) {
    File f := File.make(uri, false)
    if (f.exists()) return f
    throw UnresolvedErr(uri.toStr)
  }
}



