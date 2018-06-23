//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Jun 06  Brian Frank  Creation
//

internal class UriParser {
  Str? scheme
  Str? userInfo
  Str? host
  Int? port
  Str pathStr := ""
  [Str:Str]? query
  Str? frag

  override Str toStr() {
    sb := StrBuf()
    sb.add("scheme:").add(scheme).add(",userInfo:").add(userInfo).add(",host:").add(host)
    .add(",port:").add(port).add(",pathStr:").add(pathStr).add(",query:").add(query).add(",frag:").add(frag)
    return sb.toStr
  }

  private Void normalize() {
    if (pathStr == "") {
      pathStr = "/"
    }
    else if (pathStr.startsWith("./")) {
      pathStr = pathStr[2..-1]
    }

    if (host != null) {
      if (!pathStr.startsWith("/")) {
        pathStr = "/" + pathStr
      }
    }
  }

  static Str:Str parseQuery(Str s, Bool decode) {
    query := OrderedMap<Str,Str>()
    start := 0
    eq := 0
    k := ""
    v := ""
    i := 0
    for (; i<s.size; ++i) {
      ch := s[i]
      if (ch == '=') eq = i
      if (ch != '&' && ch != ';') {
        continue
      }
      if (start < i) {
        if (start == eq && s[start] != '=') {
          k = s[start..<i]
          v = ""
        }
        else {
          k = s[start..<eq]
          v = s[eq+1..<i]
        }
        if (decode) {
          ek := Uri.decodeToken(k, true)
          ev := Uri.decodeToken(v, true)
          query[ek] = ev
        } else {
          query[k] = v
        }
      }
      start = i + 1
      eq = start
    }
    if (start < i) {
      if (start == eq && s[start] != '=') {
        k = s[start..<i]
        v = ""
      }
      else {
        k = s[start..<eq]
        v = s[eq+1..<i]
      }
      if (decode) {
        ek := Uri.decodeToken(k, true)
        ev := Uri.decodeToken(v, true)
        query[ek] = ev
      } else {
        query[k] = v
      }
    }
    return query
  }

  Void parse(Str str) {
    len := str.size
    pos := 0

    // ==== SCHEME ====

    //scheme
    // scan the string from the beginning looking for either a
    // colon or any character which doesn't fit a valid scheme
    hasUpper := false
    for (i:=0;i < len; ++i) {
      ch := str[i]
      if (ch.isAlphaNum || ch == '_') {
        if (ch.isUpper) hasUpper = true
        continue
      }
      if (ch != ':') break

      // at this point we have a scheme; if we detected
      // any upper case characters normalize to lowercase
      pos = i + 1
      scheme = str[0..<i]
      if (hasUpper) scheme = scheme.lower
      break
    }

    // ==== authority ====

    // authority must start with //
    if (pos+1 < len && str[pos] == '/' && str[pos+1] == '/' ) {
      // find end of authority which is /, ?, #, or end of string;
      // while we're scanning look for @ and last colon which isn't
      // inside an [] IPv6 literal
      authStart := pos+2; authEnd := len; at := -1; colon := -1;
      for (i:=authStart; i<len; ++i)
      {
        c := str[i]
        if (c == '/' || c == '?' || c == '#') { authEnd = i; break; }
        else if (c == '@' && at < 0) { at = i; colon = -1; }
        else if (c == ':') colon = i;
        else if (c == ']') colon = -1;
      }

      // start with assumption that there is no userinfo or port
      hostStart := authStart; hostEnd := authEnd;

      // if we found an @ symbol, parse out userinfo
      if (at > 0)
      {
        this.userInfo = str[authStart..<at]
        hostStart = at+1
      }

      // if we found an colon, parse out port
      if (colon > 0)
      {
        this.port = str[colon+1..<authEnd].toInt
        hostEnd = colon;
      }

      // host is everything left in the authority
      this.host = str[hostStart..<hostEnd]
      pos = authEnd
    }

    // ==== path ====

    // scan the string looking '?' or '#' which ends the path
    // section; while we're scanning count the number of slashes
    pathStart := pos; pathEnd := len; numSegs := 1; prev := 0
    for (i:=pathStart; i<len; ++i)
    {
      c := str[i]
      if (prev != '\\')
      {
        if (c == '?' || c == '#') { pathEnd = i; break; }
        if (i != pathStart && c == '/') ++numSegs;
        prev = c;
      }
      else
      {
        prev = (c != '\\') ? c : 0;
      }
    }

    // we now have the complete path section
    this.pathStr = str[pathStart..<pathEnd]
    //this.path = pathSegments(pathStr, numSegs);
    pos = pathEnd

    // ==== query ====

    if (pos < len && str[pos] == '?')
    {
      // look for end of query which is # or end of string
      queryStart := pos+1; queryEnd := len; prev = 0;
      for (i:=queryStart; i<len; ++i)
      {
        c := str[i]
        if (prev != '\\')
        {
          if (c == '#') { queryEnd = i; break; }
          prev = c;
        }
        else
        {
          prev = (c != '\\') ? c : 0;
        }
      }

      // we now have the complete query section
      queryStr := str[queryStart..<queryEnd]
      this.query = parseQuery(queryStr, false);
      //echo("'$queryStr, $query'")
      pos = queryEnd;
    }

    // ==== frag ====

    if (pos < len  && str[pos] == '#')
    {
      this.frag = str[pos+1..<len]
    }

    normalize
    //echo("'$str => $this'")
  }
}

**
** Uri is used to immutably represent a Universal Resource Identifier
** according to [RFC 3986]`http://tools.ietf.org/html/rfc3986`.
** The generic format for a URI is:
**
**   <uri>        := [<scheme> ":"] <body>
**   <body>       := ["//" <auth>] ["/" <path>] ["?" <query>] ["#" <frag>]
**   <auth>       := [<userInfo> "@"] <host> [":" <port>]
**   <path>       := <name> ("/" <name>)*
**   <name>       := <basename> ["." <ext>]
**   <query>      := <queryPair> (<querySep> <queryPair>)*
**   <querySep>   := "&" | ";"
**   <queryPair>  := <queryKey> ["=" <queryVal>]
**   <gen-delims> := ":" / "/" / "?" / "#" / "[" / "]" / "@"
**
** Uris are expressed in the following forms:
**   - Standard Form: any char allowed, general delimiters are "\" escaped
**   - Encoded Form: '%HH' percent encoded
**
** In standard form the full range of Unicode characters is allowed in all
** sections except the general delimiters which separate sections.  For
** example '?' is barred in any section before the query, but is permissible
** in the query string itself or the fragment identifier.  The scheme must
** be strictly defined in terms of ASCII alphanumeric, ".", "+", or "-".
** Any general delimiter used outside of its normal role, must be
** escaped using the "\" backslash character.  The backslash itself is
** escaped as "\\".  For example a filename with the "#" character is
** represented as "file \#2".  Only the path, query, and fragment sections
** can use escaped general delimiters; the scheme and authority sections
** cannot use escaped general delimters.
**
** Encoded form as defined by RFC 3986 uses a stricter set of rules for
** the characters allowed in each section of the URI (scheme, userInfo,
** host, path, query, and fragment).  Any character outside of the
** allowed set is UTF-8 encoded into octets and '%HH' percent encoded.
** The encoded form should be used when working with external applications
** such as HTTP, HTML, or XML.
**
** The Uri API is designed to work with the standard form of the Uri.
** Access methods like `host`, `pathStr`, or `queryStr` all use standard
** form.  To summarize different ways of working with Uri:
**   - `Uri.fromStr`:  parses a string from its standard form
**   - `Uri.toStr`:    returns the standard form
**   - `Uri.decode`:   parses a string from percent encoded form
**   - `Uri.encode`:   translate into percent encoded form
**
** Uri can be used to model either absolute URIs or relative references.
** The `plus` and `relTo` methods can be used to resolve and relativize
** relative references against a base URI.
**
@Serializable { simple = true }
const final class Uri
{
  private const Str str
//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse the specified string into a Uri.  If invalid format
  ** and checked is false return null,  otherwise throw ParseErr.
  ** a standard form Unicode string into its generic parts.
  ** It does not unescape '%' or '+' and handles normal Unicode
  ** characters in the string.  If general delimiters such
  ** as the "?" or "#" characters are used outside their normal
  ** role, then they must be backslash escaped.
  **
  ** All Uris are automatically normalized as follows:
  **   - Replacing "." and ".." segments in the middle of a path
  **   - Scheme always normalizes to lowercase
  **   - If http then port 80 normalizes to null
  **   - If http then a null path normalizes to /
  **
  static new fromStr(Str s, Bool checked := true) {
    res := decode(s, checked)
    if (res == null) return defVal
    return res
  }

  **
  ** Parse an ASCII percent encoded string into a Uri according to
  ** RFC 3986.  All '%HH' escape sequences are translated into octects,
  ** and then the octect sequence is UTF-8 decoded into a Str.  The '+'
  ** character in the query section is unescaped into a space.  If
  ** checked if true then throw ParseErr if the string is a malformed
  ** URI or if not encoded correctly, otherwise return null. Refer
  ** to `fromStr` for normalization rules.
  **
  static Uri? decode(Str s, Bool checked := true) {
    try {
      if (s == "") {
        return privateMake(null, null, null, null, "", null, null)
      }
      parser := UriParser()
      parser.parse(s)

      if (parser.scheme != null) parser.scheme = decodeToken(parser.scheme, false)
      if (parser.userInfo != null) parser.userInfo = decodeToken(parser.userInfo, false)
      if (parser.host != null) parser.host = decodeToken(parser.host, false)
      if (parser.pathStr.size > 0) parser.pathStr = decodeToken(parser.pathStr, false)

      if (parser.query != null) {
        query2 := OrderedMap<Str,Str>()
        parser.query.each |v,k| {
          query2[decodeToken(k, true)] = decodeToken(v, true)
        }
        parser.query = query2
      }
      if (parser.frag != null) parser.frag = decodeToken(parser.frag, false)

      return privateMake(parser.scheme, parser.userInfo, parser.host, parser.port, parser.pathStr, parser.query, parser.frag)
    } catch (Err e) {
      if (checked) throw ParseErr("uri:$s", e)
      return null
    }
  }

  **
  ** Default value is '``'.
  **
  static const Uri defVal := ``

  **
  ** Private constructor
  **
  private new privateMake(Str? scheme, Str? userInfo, Str? host, Int? port, Str pathStr, [Str:Str]? query, Str? frag, Str? str := null) {
    this.scheme = scheme
    this.userInfo = userInfo
    this.host = host
    this.port = port
    this.pathStr = pathStr
    this.query = query ?: Map.defVal
    this.frag = frag
    this.str = str ?: partsToStr(scheme, userInfo, host, port, pathStr, query, frag, true)
  }

  private static Str partsToStr(Str? scheme, Str? userInfo, Str? host, Int? port, Str? path, [Str:Str]? query, Str? frag, Bool encode) {
    buf := StrBuf()
    if (scheme != null) {
      if (encode) scheme = encodeToken(scheme, false)
      buf.add(scheme).add(":")
    }

    if (userInfo != null || host != null || port != null) {
      buf.add("//")
      if (userInfo != null) {
        if (encode) userInfo = encodeToken(userInfo, false)
        buf.add(userInfo).addChar('@')
      }
      if (host != null) {
        if (encode) host = encodeToken(host, false)
        buf.add(host)
      }
      if (port != null) {
        buf.addChar(':').add(port.toStr)
      }
    }

    if (path != null) {
      if (encode) path = encodeToken(path, false)
      buf.add(path)
    }

    if (query != null && query.size > 0) {
      if (path != null) buf.addChar('?')
      i := 0
      query.each |Str v, k| {
        if (i>0) buf.addChar('&')
        if (encode) {
          k = encodeToken(k, true)
          v = v == "" ? "" : encodeToken(v, true)
        }
        if (v.size == 0)
          buf.add(k)
        else
          buf.add(k).addChar('=').add(v)
        ++i
      }
    }
    if (frag != null) {
      if (encode) frag = encodeToken(frag, false)
      buf.addChar('#').add(frag)
    }
    return buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Encode/Decode
//////////////////////////////////////////////////////////////////////////

  private static Void percentEncodeByte(StrBuf buf, Int c)
  {
    buf.addChar('%')
    Int hi := (c.shiftr(4)).and(0xf)
    Int lo := c.and(0xf)
    buf.addChar((hi < 10 ? '0'+hi : 'A'+(hi-10)))
    buf.addChar((lo < 10 ? '0'+lo : 'A'+(lo-10)))
  }

  **
  ** Unescape "%xx" percent encoded string to its normalized form
  ** for the given section.  Any delimiters for the section are
  ** backslash escaped.  Section must be `sectionPath`, `sectionQuery`,
  ** or `sectionFrag`.  Also see `encodeToken`.
  **
  ** Examples:
  **   Uri.decodeToken("a%2Fb%23c", Uri.sectionPath)  =>  "a\/b\#c"
  **   Uri.decodeToken("a%3Db/c", Uri.sectionQuery)   =>  "a\=b/c"
  **
  static Str decodeToken(Str s, Bool isQuery) {
    sb := StrBuf()
    ba := ByteArray(s.size)
    bp := 0
    for (i:=0; i<s.size; ++i) {
      ch := s[i]
      if (ch == '%') {
        hi := s[++i]
        lo := s[++i]
        h := hi.fromDigit(16)
        l := lo.fromDigit(16)
        c := h.shiftl(4).or(l)
        //sb.addChar(c)
        ba.set(bp, c)
        ++bp
        continue
      }
      if (bp > 0) {
        t := Str.fromUtf8(ba, 0, bp)
        bp = 0
        sb.add(t)
      }

      if (isQuery && ch == '+') {
        sb.addChar(' ')
      }
      else {
        sb.addChar(ch)
      }
    }
    if (bp > 0) {
      t := Str.fromUtf8(ba, 0, bp)
      bp = 0
      sb.add(t)
    }
    return sb.toStr
  }

  **
  ** Encode a token so that any invalid character or delimter for
  ** the given section is "%xx" percent encoding.  Section must
  ** be `sectionPath`, `sectionQuery`, or `sectionFrag`.  Also see
  ** `decodeToken`.
  **
  ** Examples:
  **   Uri.encodeToken("a/b#c", Uri.sectionPath)   =>  "a%2Fb%23c"
  **   Uri.encodeToken("a=b/c", Uri.sectionQuery)  =>  "a%3Db/c"
  **
  static Str encodeToken(Str s, Bool isQuery) {
    sb := StrBuf()
    ba := s.toUtf8
    for (i:=0; i<ba.size; ++i) {
      ch := ba[i]
      if (ch < 127) {
        if (ch.isAlphaNum || ch == '-' || ch == '_' || ch == '.' || ch == '~' ) {
          sb.addChar(ch)
          continue
        }
        if (!isQuery && ch == '/') {
          sb.addChar(ch)
          continue
        }
        if (isQuery && ch == ' ') {
          sb.addChar('+')
          continue
        }
      }
      percentEncodeByte(sb, ch)
    }
    return sb.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Decode a map of query parameters which are URL encoded according
  ** to the "application/x-www-form-urlencoded" MIME type.  This method
  ** will unescape '%' percent encoding and '+' into space.  The parameters
  ** are parsed into map using the same semantics as `Uri.query`.  Throw
  ** ArgErr is the string is malformed.  See `encodeQuery`.
  **
  static Str:Str decodeQuery(Str s) {
    return UriParser.parseQuery(s, true)
  }

  **
  ** Encode a map of query parameters into URL percent encoding
  ** according to the "application/x-www-form-urlencoded" MIME type.
  ** See `decodeQuery`.
  **
  static Str encodeQuery(Str:Str q) {
    buf := StrBuf()
    first := true
    q.each |v, k| {
      ks := encodeToken(k, true)
      vs := encodeToken(v, true)
      if (first) first = false
      else buf.addChar('&')
      if (v == "") buf.add(ks)
      else buf.add(ks).addChar('=').add(vs)
    }
    return buf.toStr
  }

/* Need this?
  **
  ** Return if the specified string is an valid name segment to
  ** use in an unencoded URI.  The name must be at least one char
  ** long and can never be "." or "..".  The legal characters are
  ** defined by as follows from RFC 3986:
  **
  **   unreserved  =  ALPHA / DIGIT / "-" / "." / "_" / "~"
  **   ALPHA       =  %x41-5A / %x61-7A   ; A-Z / a-z
  **   DIGIT       =  %x30-39 ; 0-9
  **
  ** Although RFC 3986 does allow path segments to contain other
  ** special characters such as 'sub-delims', Fantom takes a strict
  ** approach to names to be used in URIs.
  **
  static Bool isName(Str name) {
    name.all |ch| {
      ch.isAlphaNum || ch == '-' || ch == '_' || ch == '.' || ch == '~'
    }
  }

  **
  ** If the specified string is not a valid name according
  ** to the `isName` method, then throw `NameErr`.
  **
  static Void checkName(Str name) {
    if (!isName(name))
      throw NameErr.make(name)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two Uris are equal if they have same string normalized representation.
  **
  override Bool equals(Obj? that) {
    if (that is Uri) {
      return str == ((Uri)that).str
    }
    return false
  }

  **
  ** Return a hash code based on the normalized string representation.
  **
  override Int hash() { str.hash }

  **
  ** Return normalized string representation.
  **
  override Str toStr() { str }

  **
  ** Return `toStr`.  This method is used to enable 'toLocale' to
  ** be used with duck typing across most built-in types.
  **
  Str toLocale() { toStr }

  **
  ** Return the percent encoded string for this Uri according to
  ** RFC 3986.  Each section of the Uri is UTF-8 encoded into octects
  ** and then percent encoded according to its valid character set.
  ** Spaces in the query section are encoded as '+'.
  **
  Str encode() {
    return str
  }

//////////////////////////////////////////////////////////////////////////
// Components
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if an absolute Uri which means it has a non-null scheme.
  **
  Bool isAbs() { scheme != null }

  **
  ** Return if a relative Uri which means it has a null scheme.
  **
  Bool isRel() { !isAbs }

  **
  ** A Uri represents a directory if it has a non-null path which
  ** ends with a "/" slash.  Directories are joined with other Uris
  ** relative to themselves versus non-directories which are joined
  ** relative to their parent.
  **
  ** Examples:
  **   `/a/b`.isDir   =>  false
  **   `/a/b/`.isDir  =>  true
  **   `/a/?q`.isDir  =>  true
  **
  Bool isDir() {
    p := pathStr
    if (p.size > 0)
    {
      len := p.size
      if (len > 0 && p.get(len-1) == '/')
        return true
    }
    return false
  }

  **
  ** Return the scheme component or null if not absolute.  The
  ** scheme is always normalized into lowercase.
  **
  ** Examples:
  **   `http://foo/a/b/c`.scheme      =>  "http"
  **   `HTTP://foo/a/b/c`.scheme      =>  "http"
  **   `mailto:who@there.com`.scheme  =>  "mailto"
  **
  const Str? scheme

  **
  ** The authority represents a network endpoint in the format:
  **   [<userInfo> "@"] host [":" <port>]
  **
  ** Examples:
  **   `http://user@host:99/`.auth  =>  "user@host:99"
  **   `http://host/`.auth          =>  "host"
  **   `/dir/file.txt`.auth         =>  null
  **
  Str? auth() {
    if (host == null) return null;
    if (port == null)
    {
      if (userInfo == null) return host;
      else return userInfo + "@" + host;
    }
    else
    {
      if (userInfo == null) return "$host:$port"
      else return "$userInfo@$host:$port"
    }
  }

  **
  ** Return the host address of the URI or null if not available.  The
  ** host is in the format of a DNS name, IPv4 address, or IPv6 address
  ** surrounded by square brackets.  Return null if the uri is not
  ** absolute.
  **
  ** Examples:
  **   `ftp://there:78/file`.host            =>  "there"
  **   `http://www.cool.com/`.host           =>  "www.cool.com"
  **   `http://user@10.162.255.4/index`.host =>  "10.162.255.4"
  **   `http://[::192.9.5.5]/`.host          =>  "[::192.9.5.5]"
  **   `//foo/bar`.host                      =>  "foo"
  **   `/bar`.host                           =>  null
  **
  const Str? host

  **
  ** User info is string information embedded in the authority using
  ** the "@" character.  Its use is discouraged for security reasons.
  **
  ** Examples:
  **   `http://brian:pass@host/`.userInfo  =>  "brian:pass"
  **   `http://www.cool.com/`.userInfo     =>  null
  **
  const Str? userInfo

  **
  ** Return the IP port of the host for the network end point.  It is optionally
  ** embedded in the authority using the ":" character.  If unspecified then
  ** return null.
  **
  ** Examples:
  **   `http://foo:81/`.port        =>  81
  **   `http://www.cool.com/`.port  =>  null
  **
  const Int? port

  **
  ** Return the path parsed into a list of simple names or
  ** an empty list if the pathStr is "" or "/".  Any general
  ** delimiters in the path such "?" or "#" are backslash
  ** escaped.
  **
  ** Examples:
  **   `mailto:me@there.com`  =>  ["me@there.com"]
  **   `http://host`.path     =>  Str[,]
  **   `http://foo/`.path     =>  Str[,]
  **   `/`.path               =>  Str[,]
  **   `/a`.path              =>  ["a"]
  **   `/a/b`.path            =>  ["a", "b"]
  **   `../a/b`.path          =>  ["..", "a", "b"]
  **
  Str[] path() {
    if (pathStr.size == 0) return List.defVal
    if (pathStr == "/") return List.defVal
    ps := pathStr.split('/')
    if (ps[0] == "") ps.removeAt(0)
    if (ps.last == "") ps.removeAt(ps.size-1)
    return ps.toImmutable
  }

  **
  ** Return the path component of the Uri.  Any general
  ** delimiters in the path such "?" or "#" are backslash
  ** escaped.
  **
  ** Examples:
  **   `mailto:me@there.com`  =>  "me@there.com"
  **   `http://host`          =>  ""
  **   `http://foo/`.pathStr  =>  "/"
  **   `/a`.pathStr           =>  "/a"
  **   `/a/b`.pathStr         =>  "/a/b"
  **   `../a/b`.pathStr       =>  "../a/b"
  **
  const Str pathStr

  **
  ** Return if the path starts with a leading slash.  If
  ** pathStr is null, then return false.
  **
  ** Examples:
  **   `http://foo/`.isPathAbs    =>  true
  **   `/dir/f.txt`.isPathAbs     =>  true
  **   `dir/f.txt`.isPathAbs      =>  false
  **   `../index.html`.isPathAbs  =>  false
  **
  Bool isPathAbs() {
    if (pathStr.size == 0)
      return false
    else
      return pathStr.get(0) == '/'
  }

  **
  ** Return not of `isPathAbs` when path is empty
  ** or does not start with a leading slash.
  **
  Bool isPathRel() { !isPathAbs }

  **
  ** Return if this Uri contains only a path component.  The
  ** authority (scheme, host, port), query, and fragment must
  ** be null.
  **
  Bool isPathOnly() { scheme == null && host == null && port == null &&
           userInfo == null && (query.size == 0) && frag == null }

  **
  ** Return simple file name which is path.last or ""
  ** if the path is empty.
  **
  ** Examples:
  **   `/`.name            =>  ""
  **   `/a/file.txt`.name  =>  "file.txt"
  **   `/a/file`.name      =>  "file"
  **   `somedir/`.name     =>  "somedir"
  **
  Str name() {
    len := pathStr.size
    if (len == 0) return ""

    start := 0
    endsSlash := pathStr[len-1] == '/'
    if (endsSlash) start = pathStr.findr("/", -2)
    else start = pathStr.findr("/")

    if (start != -1)
      start = start + 1
    else
      start = 0

    end := len
    if (endsSlash) {
      end = len-1
    }
    return pathStr[start..<end]
  }

  **
  ** Return file name without the extension (everything up
  ** to the last dot) or "" if name is "".
  **
  ** Examples:
  **   `/`.basename            =>  ""
  **   `/a/file.txt`.basename  =>  "file"
  **   `/a/file`.basename      =>  "file"
  **   `/a/file.`.basename     =>  "file"
  **   `..`.basename           =>  ".."
  **
  Str basename() {
    n := name
    dot := n.indexr(".")
    if (dot < 2)
    {
      if (dot < 0) return n;
      if (n.equals(".")) return n;
      if (n.equals("..")) return n;
    }
    return n[0..<dot]
  }

  **
  ** Return file name extension (everything after the last dot)
  ** or null if name is null or name has no dot.
  **
  ** Examples:
  **   `/`.ext            =>  null
  **   `/a/file.txt`.ext  =>  "txt"
  **   `/Foo.Bar`.ext     =>  "Bar"
  **   `/a/file`.ext      =>  null
  **   `/a/file.`.ext     =>  ""
  **   `..`.ext           =>  null
  **
  Str? ext() {
    n := name
    dot := n.indexr(".")
    if (dot < 2)
    {
      if (dot < 0) return null
      if (n.equals(".")) return null
      if (n.equals("..")) return null
    }
    return n[dot+1..-1]
  }

  **
  ** Return the MimeType mapped by the `ext` or null if
  ** no mapping.  If this uri is to a directory, then
  ** "x-directory/normal" is returned.
  **
  ** Examples:
  **   `file.txt`  =>  text/plain
  **   `somefile`  =>  null
  **
  MimeType? mimeType() {
    if (isDir) return MimeType.dir
    e := ext
    if (e == null) return null
    return MimeType.forExt(ext)
  }

  **
  ** Return the query parsed as a map of key/value pairs.  If no query
  ** string was specified return an empty map (this method will never
  ** return null).  The query is parsed such that pairs are separated by
  ** the "&" or ";" characters.  If a pair contains the "=", then
  ** it is split into a key and value, otherwise the value defaults
  ** to "true".  If delimiters such as "&", "=", or ";" are in the
  ** keys or values, then they are *not* escaped.  If duplicate keys
  ** are detected, then the values are concatenated together with a
  ** comma.
  **
  ** Examples:
  **   `http://host/path?query`.query  =>  ["query":"true"]
  **   `http://host/path`.query        =>  [:]
  **   `?a=b;c=d`.query                =>  ["a":"b", "c":"d"]
  **   `?a=b&c=d`.query                =>  ["a":"b", "c":"d"]
  **   `?a=b;;c=d;`.query              =>  ["a":"b", "c":"d"]
  **   `?a=b;;c`.query                 =>  ["a":"b", "c":"true"]
  **   `?x=1&x=2&x=3`.query            =>  ["x":"1,2,3"]
  **
  const [Str:Str] query

  **
  ** Return the query component of the Uri which is everything
  ** after the "?" but before the "#" fragment.  Return null if
  ** no query string specified.  Any delimiters used in keys
  ** or values such as "&", "=", or ";" are backslash escaped.
  **
  ** Examples:
  **   `http://host/path?query#frag`.queryStr =>  "query"
  **   `http://host/path?query`.queryStr      =>  "query"
  **   `http://host/path`.queryStr            =>  null
  **   `../foo?a=b&c=d`.queryStr              =>  "a=b&c=d"
  **   `?a=b;c;`.queryStr                     =>  "a=b;c;"
  **
  Str? queryStr() {
    if (query.size == 0) return null
    return encodeQuery(query)
  }

  **
  ** Return the fragment component of the Uri which is everything
  ** after the "#".  Return null if no fragment specified.
  **
  ** Examples:
  **   `http://host/path?query#frag`.frag  =>  "frag"
  **   `http://host/path`                  =>  null
  **   `#h1`                               =>  "h1"
  **
  const Str? frag

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the parent directory of this Uri or null if a parent
  ** path cannot be computed from this Uri.  If the path is not
  ** empty, then this method is equivalent to 'getRange(0..-2)'.
  **
  ** Examples:
  **   `http://foo/a/b/c?q#f`.parent  =>  `http://foo/a/b/`
  **   `/a/b/c/`.parent  =>  `/a/b/`)
  **   `a/b/c`.parent    =>  `a/b/`
  **   `/a`.parent       =>   `/`
  **   `/`.parent        =>   null
  **   `a.txt`.parent    =>   null
  **
  Uri? parent() {
    p := parentPathStr(pathStr)
    if (p == null) return null
    return privateMake(scheme, userInfo, host, port, p, null, null)
  }

  private Str? parentPathStr(Str pathStr) {
    len := pathStr.size
    if (len == 0 || pathStr == "/") return null
    end := pathStr.findr("/", -2)
    if (end == -1) return null
    return pathStr[0..end]
  }

  **
  ** Return a new Uri with only a path part.  If this Uri has
  ** an authority, fragment, or query they are stripped off.
  **
  ** Examples:
  **   `http://host/a/b/c?query`.pathOnly =>  `/a/b/c`
  **   `http://host/a/b/c/`.pathOnly      =>  `/a/b/c/`
  **   `/a/b/c`.pathOnly                  =>  `/a/b/c`
  **   `file.txt`.pathOnly                =>  `file.txt`
  **
  Uri pathOnly() {
    if (scheme == null && userInfo == null && host == null &&
        port == null && queryStr == null && frag == null) return this
    return privateMake(null, null, null, null, pathStr, null, null)
  }

  **
  ** Return a new Uri based on a slice of this Uri's path.  If the
  ** range starts at zero, then the authority is included otherwise
  ** it is stripped and the result is not path absolute.  If the
  ** range includes the last name in the path, then the query and
  ** fragment are included otherwise they are stripped and the result
  ** includes a trailing slash.  The range can include negative indices
  ** to access from the end of the path.  Also see `pathOnly` to create
  ** a slice without the authority, query, or fragment.
  **
  ** Examples:
  **   `http://host/a/b/c?q`[0..-1]  =>  `http://host/a/b/c?q`
  **   `http://host/a/b/c?q`[0..-2]  =>  `http://host/a/b/`
  **   `http://host/a/b/c?q`[0..-3]  =>  `http://host/a/`
  **   `http://host/a/b/c?q`[0..-4]  =>  `http://host/`
  **   `http://host/a/b/c?q`[1..-1]  =>  `b/c?q`
  **   `http://host/a/b/c?q`[2..-1]  =>  `c?q`
  **   `http://host/a/b/c?q`[3..-1]  =>  `?q`
  **   `/a/b/c/`[0..1]               =>  `/a/b/`
  **   `/a/b/c/`[0..0]               =>  `/a/`
  **   `/a/b/c/`[1..2]               =>  `b/c/`
  **   `/a/b/c/`[1..<2]              =>  `b/`
  **   `/a`[0..-2]                   =>  `/`
  **
  //@Operator Uri getRange(Range r) { slice(r, false) }

  //native private Uri slice(Range range, Bool forcePathAbs)

  **
  ** Return a slice of this Uri's path using the same semantics
  ** as `getRange`.  However this method ensures that the result has
  ** a leading slash in the path such that `isPathAbs` returns true.
  **
  ** Examples:
  **   `/a/b/c/`.getRangeToPathAbs(0..1)  =>  `/a/b/`
  **   `/a/b/c/`.getRangeToPathAbs(1..2)  =>  `/b/c/`
  **   `/a/b/c/`.getRangeToPathAbs(1..<2) =>  `/b/`
  **
  //Uri getRangeToPathAbs(Range r) { slice(r, true) }

  **
  ** Return a new Uri with the specified Uri appended to this Uri.
  **
  ** Examples:
  **   `http://foo/path` + `http://bar/`  =>  `http://bar/`
  **   `http://foo/path?q#f` + `newpath`  =>  `http://foo/newpath`
  **   `http://foo/path/?q#f` + `newpath` =>  `http://foo/path/newpath`
  **   `a/b/c`  + `d`                     =>  `a/b/d`
  **   `a/b/c/` + `d`                     =>  `a/b/c/d`
  **   `a/b/c`  + `../../d`               =>  `d`
  **   `a/b/c/` + `../../d`               =>  `a/d`
  **   `a/b/c`  + `../../../d`            =>  `../d`
  **   `a/b/c/` + `../../../d`            =>  `d`
  **
  @Operator Uri plus(Uri toAppend) {
    if (toAppend.scheme != null || toAppend.host != null) return toAppend

    toAppPath := toAppend.pathStr
    Str? resPath := null
    query := toAppend.query
    if (toAppend.query.isEmpty && toAppPath == "/") {
       query = this.query
    }

    if (toAppPath == "" || toAppPath == "/") {
      resPath = pathStr
    }
    else if (toAppPath.startsWith("/")) {
      resPath = toAppPath
    }
    else if (isDir) {
      resPath = pathStr+toAppPath
    }
    else {
      p := parentPathStr(pathStr)
      if (p == null) p = "/"
      resPath = p + toAppPath
    }
    //TODO support '..'

    return privateMake(scheme, userInfo, host, port, resPath, query, toAppend.frag)
  }

  **
  ** Return a new Uri with a single path name appended to this
  ** Uri.  If asDir is true, then add a trailing slash to the Uri
  ** to make it a directory Uri.  This method is potentially
  ** much more efficient than using `plus` when appending a
  ** single name.
  **
  ** Examples:
  **   `dir/`.plusName("foo")        =>  `dir/foo`
  **   `dir/`.plusName("foo", true)  =>  `dir/foo/`
  **   `/dir/file`.plusName("foo")   =>  `/dir/foo`
  **   `/dir/#frag`.plusName("foo")  =>  `/dir/foo`
  **
  Uri plusName(Str name, Bool asDir := false) {
    if (asDir && !name.endsWith("/")) name += "/"
    if (isDir) return privateMake(scheme, userInfo, host, port, pathStr+name, null, null)
    p := parentPathStr(pathStr)
    if (p == null) p = isPathAbs ? "/" : ""
    return privateMake(scheme, userInfo, host, port, p+name, null, null)
  }

  **
  ** Add a trailing slash to the path string of this Uri
  ** to make it a directory Uri.
  **
  ** Examples
  **   `http://h/dir`.plusSlash  => `http://h/dir/`
  **   `/a`.plusSlash            =>  `/a/`
  **   `/a/`.plusSlash           =>  `/a/`
  **   `/a/b`.plusSlash          =>  `/a/b/`
  **   `/a?q`.plusSlash          =>  `/a/?q`
  **
  Uri plusSlash() {
    if (isDir) return this
    return privateMake(scheme, userInfo, host, port, pathStr+"/", query, frag)
  }

  **
  ** Add the specified query key/value pairs to this Uri.
  ** If this uri has an existing query, then it is merged
  ** with the given query.  The key/value pairs should not
  ** be backslash escaped or percent encoded.  If the query
  ** param is null or empty, return this instance.
  **
  ** Examples:
  **   `http://h/`.plusQuery(["k":"v"])         =>  `http://h/?k=v`
  **   `http://h/?k=old`.plusQuery(["k":"v"])   =>  `http://h/?k=v`
  **   `/foo?a=b`.plusQuery(["k":"v"])          =>  `/foo?a=b&k=v`
  **   `?a=b`.plusQuery(["k1":"v1", "k2":"v2"]) =>  `?a=b&k1=v1&k2=v2`
  **
  Uri plusQuery([Str:Str]? query) {
    if (query == null || query.size == 0) return this
    nq := OrderedMap<Str,Str>()
    this.query.each |v,k| { nq[k] = v }
    query.each |v,k| { nq[k] = v }
    return privateMake(scheme, userInfo, host, port, pathStr, nq, frag)
  }

  **
  ** Relativize this uri against the specified base.
  **
  ** Examples:
  **   `http://foo/a/b/c`.relTo(`http://foo/a/b/c`) => ``
  **   `http://foo/a/b/c`.relTo(`http://foo/a/b`)   => `c`
  **   `/a/b/c`.relTo(`/a`)                         => `b/c`
  **   `a/b/c`.relTo(`/a`)                          => `b/c`
  **   `/a/b/c?q`.relTo(`/`)                        => `a/b/c?q`
  **   `/a/x`.relTo(`/a/b/c`)                       => `../x`
  **
  Uri relTo(Uri base) {
    same := this.scheme == base.scheme && this.userInfo == base.userInfo
      && this.host == base.host && this.port == base.port

    pos := pathStr.find(base.pathStr)
    path := pathStr
    if (pos == 0) {
      pos2 := base.pathStr.size
      path = pathStr[pos2..-1]
      if (path.size > 0 && path[0] == '/') {
        path = path[1..-1]
      }
    }
    else {
      if (!same) return this
    }

    if (!same) {
      if (!path.startsWith("/")) {
        path = "/" + path
      }
      return privateMake(scheme, userInfo, host, port, path, query, frag)
    }
    return privateMake(null, null, null, null, path, query, frag)
  }

  **
  ** Relativize this uri against its authority.  This method
  ** strips the authority if present and keeps the path, query,
  ** and fragment segments.
  **
  ** Examples:
  **   `http://host/a/b/c?q#frag`.relToAuth  => `/a/b/c?q#frag`
  **   `http://host/a/b/c`.relToAuth         => `/a/b/c`
  **   `http://user@host/index`.relToAuth    => `/index`
  **   `mailto:bob@bob.net`.relToAuth        => `bob@bob.net`
  **   `/a/b/c/`.relToAuth                   => `/a/b/c/`
  **   `logo.png`.relToAuth                  => `logo.png`
  **
  Uri relToAuth() {
    if (scheme == null && host == null && port == null && userInfo == null) {
      return this
    }
    return privateMake(null, null, null, null, pathStr, query, frag)
  }

//////////////////////////////////////////////////////////////////////////
// Resolution
//////////////////////////////////////////////////////////////////////////

  **
  ** Convenience for File.make(this) - no guarantee is made
  ** that the file exists.
  **
  File toFile() { File.make(this) }

  **
  ** Resolve this Uri into an Fantom object.
  ** See [docLang]`docLang::Naming#resolving` for the resolve process.
  **
  Obj? get(Obj? base := null, Bool checked := true) {
    try {
      uri := this
      if (base != null) {
        Uri baseUri := base->uri
        uri = baseUri + this
      }
      us := UriScheme.find(uri.scheme, checked)
      return us.get(this, base)
    } catch (Err e) {
      if (checked) throw UnresolvedErr("resolve uri: $this", e)
      return null
    }
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Get this Uri as a Fantom code literal.  This method will
  ** escape the "$" interpolation character.
  **
  Str toCode() { "`$this`" }

  static extension Uri toUri(Str str) { Uri(str) }
}