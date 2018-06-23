//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 May 08  Brian Frank  Creation
//

**
** MimeType represents the parsed value of a Content-Type
** header per RFC 2045 section 5.1.
**
@Serializable { simple = true }
const final class MimeType
{

  static const MimeType imagePng   := parse("image/png")
  static const MimeType imageGif   := parse("image/gif")
  static const MimeType imageJpeg  := parse("image/jpeg")
  static const MimeType textPlain  := parse("text/plain")
  static const MimeType textHtml   := parse("text/html")
  static const MimeType textXml    := parse("text/xml")
  static const MimeType textJsUtf8 := parse("text/javascript; charset=utf-8")
  static const MimeType textJs     := parse("text/javascript")
  static const MimeType textJson   := parse("application/json")
  static const MimeType dir        := parse("x-directory/normal")
  static const MimeType textPlainUtf8 := parse("text/plain; charset=utf-8")
  static const MimeType textHtmlUtf8  := parse("text/html; charset=utf-8")
  static const MimeType textXmlUtf8   := parse("text/xml; charset=utf-8")

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse from string format.  If invalid format and
  ** checked is false return null, otherwise throw ParseErr.
  ** Parenthesis comments are treated as part of the value.
  **
  static new fromStr(Str s) {
    switch (s[0])
    {
      case 'i':
        if (s.equals("image/png"))  return imagePng;
        if (s.equals("image/jpeg")) return imageJpeg;
        if (s.equals("image/gif"))  return imageGif;
      case 't':
        if (s.equals("text/plain")) return textPlain;
        if (s.equals("text/html"))  return textHtml;
        if (s.equals("text/xml"))   return textXml;
        if (s.equals("text/javascript; charset=utf-8")) return textJsUtf8
        if (s.equals("text/javascript")) return textJs
        if (s.equals("text/plain; charset=utf-8")) return textPlainUtf8;
        if (s.equals("text/html; charset=utf-8"))  return textHtmlUtf8;
        if (s.equals("text/xml; charset=utf-8"))   return textXmlUtf8;
      case 'x':
        if (s.equals("x-directory/normal")) return dir;
      case 'a':
       if (s.equals("application/json")) return textJson
    }
    try {
      return parse(s)
    } catch (Err e) {
      throw ParseErr("MimeType:$s", e)
    }
  }

  private static MimeType parse(Str s) {
    pos := s.find("/")
    if (pos == -1) throw ParseErr("parse $s")
    media := s[0..<pos]
    sub := s[pos+1..-1]

    pos2 := sub.find(";")
    [Str:Str]? params := null
    if (pos2 != -1) {
      paramStr := sub[pos2+1..-1]
      sub = sub[0..<pos2]
      params = parseParams(paramStr.trim)
    }
    if (params == null) params = [:]
    return make(media.trim, sub.trim, params, s)
  }

  **
  ** Parse a set of attribute-value parameters where the
  ** values may be tokens or quoted-strings.  The resulting map
  ** is case insensitive.  If invalid format and checked is
  ** false return null, otherwise throw ParseErr.  Parenthesis
  ** comments are not supported.
  **
  ** Examples:
  **   a=b; c="d"  =>  ["a":"b", "c"="d"]
  **
  static [Str:Str]? parseParams(Str s, Bool checked := true) {
    params := [Str:Str][:]
    fs := s.split(';')
    fs.each |Str p|{
      ss := p.split('=')
      if (ss.size == 2) {
        params[ss[0].trim] = ss[1].trim
      }
    }
    return params
  }

  **
  ** Map a case insensitive file extension to a MimeType.
  ** This mapping is configured via "etc/sys/ext2mime.props".  If
  ** no mapping is available return null.
  **
  static MimeType? forExt(Str s) {
    switch (s)
    {
      case "png":   return imagePng;
      case "jpeg":  return imageJpeg;
      case "gif":   return imageGif;
      case "txt":   return textPlainUtf8;
      case "html":  return textHtml;
      case "xml":   return textHtmlUtf8;
      case "htm":   return textHtml;
      case "json":  return textJson;
      case "js":    return textJsUtf8;
    }
    return null
  }

  **
  ** Private constructor - must use fromStr
  **
  private new make(Str mediaType, Str subType, Str:Str params, Str str) {
    this.mediaType = mediaType
    this.subType = subType
    this.params = params
    this.str = str
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Hash code is derived from the mediaType, subType,
  ** and params hashes.
  **
  override Int hash() { str.hash }

  **
  ** Equality is based on the case insensitive mediaType
  ** and subType, and params (keys are case insensitive
  ** and values are case sensitive).
  **
  override Bool equals(Obj? that) {
    if (that is MimeType) {
      return str == ((MimeType)that).str
    }
    return false
  }

  **
  ** Encode as a MIME message according to RFC 822.  This
  ** is always the exact same string passed to `fromStr`.
  **
  override Str toStr() { str }

//////////////////////////////////////////////////////////////////////////
// MIME Type
//////////////////////////////////////////////////////////////////////////
  private const Str str
  **
  ** The primary media type always in lowercase:
  **   text/html  =>  text
  **
  const Str mediaType

  **
  ** The subtype always in lowercase:
  **   text/html  =>  html
  **
  const Str subType

  **
  ** Additional parameters stored in case-insensitive map.
  ** If no parameters, then this is an empty map.
  **   text/html; charset=utf-8    =>  [charset:utf-8]
  **   text/html; charset="utf-8"  =>  [charset:utf-8]
  **
  const Str:Str params

  **
  ** If a charset parameter is specified, then map it to
  ** the 'Charset' instance, otherwise return 'Charset.utf8'.
  **
  Charset charset() {
    s := params.get("charset")
    if (s == null) return Charset.utf8
    return Charset.fromStr(s)
  }

  **
  ** Return an instance with this mediaType and subType,
  ** but strip any parameters.
  **
  MimeType noParams() {
    if (params.isEmpty()) return this;
    return fromStr(mediaType + "/" + subType)
  }

}