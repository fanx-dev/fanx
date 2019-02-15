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
abstract const class UriScheme
{
  private static const ConcurrentMap<Str,UriScheme> cache := ConcurrentMap()

  **
  ** Lookup a UriScheme for the specified scheme name.
  ** Scheme name must be lower case - note that `Uri.scheme`
  ** is always normalized to lower case.  If the scheme is
  ** not mapped and checked is true then throw UnresolvedErr
  ** otherwise return null.
  **
  static UriScheme? find(Str scheme, Bool checked := true) {
    
    x := cache.get(scheme)
    if (x != null) return x

    try {
        UriScheme? s
        if (scheme == "fan")  s = FanScheme()
        else if (scheme == "file") s = FileScheme()
        else {
          qname := Env.cur.index("sys.uriScheme." + scheme).first
          if (qname == null) throw UnresolvedErr.make
          t := Type.find(qname)
          s = t.make()
        }

        cache.set(scheme, s)
        return s
    }
    catch (Err e) {
      if (checked) throw e
      return null
    }
  }

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
  override Obj? get(Uri uri, Obj? base) {
    // don't support anything but relative fan: URIs right now
    if (uri.auth == null)
      throw ArgErr("Invalid format for fan: URI - " + uri)

    // lookup pod
    podName := uri.auth
    pod := Pod.find(podName, false)
    if (pod == null) throw UnresolvedErr(uri.toStr)
    if (uri.pathStr.size == 0 || uri.pathStr == "/") return pod

    // dive into file of pod
    return pod.file(uri)
  }
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



