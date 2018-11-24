//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Str
 */
fan.sys.Str = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.prototype.$ctor = function() {}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.equalsIgnoreCase = function(self, that)
{
  return self.toLowerCase() == that.toLowerCase();
}

fan.sys.Str.compareIgnoreCase = function(self, that)
{
  var a = self.toLowerCase();
  var b = that.toLowerCase();
  if (a < b) return -1;
  if (a == b) return 0;
  return 1;
}

fan.sys.Str.toStr = function(self) { return self; }
fan.sys.Str.toLocale = function(self) { return self; }
fan.sys.Str.$typeof = function(self) { return fan.sys.Str.$type; }

fan.sys.Str.hash = function(self)
{
  var hash = 0;
  if (self.length == 0) return hash;
  for (var i=0; i<self.length; i++)
  {
    var ch = self.charCodeAt(i);
    hash = ((hash << 5) - hash) + ch;
    hash = hash & hash;
  }
  return hash;
}

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.get = function(self, index)
{
  if (index < 0) index += self.length;
  if (index < 0 || index >= self.length) throw fan.sys.IndexErr.make(index);
  return self.charCodeAt(index);
}

fan.sys.Str.getSafe = function(self, index, def)
{
  if (def === undefined) def = 0;
  try
  {
    if (index < 0) index += self.length;
    if (index < 0 || index >= self.length) throw new Error();
    return self.charCodeAt(index);
  }
  catch (err) { return def; }
}

fan.sys.Str.getRange = function(self, range)
{
  var size = self.length;
  var s = range.startIndex(size);
  var e = range.endIndex(size);
  if (e+1 < s) throw fan.sys.IndexErr.make(range);
  return self.substr(s, (e-s)+1);
}

fan.sys.Str.plus = function(self, obj)
{
  if (obj == null) return self + "null";
  var x = fan.sys.ObjUtil.toStr(obj);
  if (x.length == 0) return self;
  return self + x;
}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.intern = function(self) { return self; }
fan.sys.Str.isEmpty = function(self) { return self.length == 0; }
fan.sys.Str.size = function(self) { return self.length; }

fan.sys.Str.startsWith = function(self, test)
{
  if (self.length < test.length) return false;
  for (var i=0; i<test.length; i++)
    if (self[i] != test[i])
      return false;
  return true;
}

fan.sys.Str.endsWith = function(self, test)
{
  if (self.length < test.length) return false;
  for (var i=0; i<test.length; i++)
    if (self[self.length-i-1] != test[test.length-i-1])
      return false;
  return true;
}

fan.sys.Str.contains = function(self, arg)
{
  return self.indexOf(arg) != -1
}

fan.sys.Str.containsChar = function(self, arg)
{
  return self.indexOf(fan.sys.Int.toChar(arg)) != -1
}

fan.sys.Str.find = function(self, s, off)
{
  var i = 0;
  if (off != null) i = off;
  if (i < 0) i = self.length+i;
  var r = self.indexOf(s, i);
  return r;
}

fan.sys.Str.findr = function(self, s, off)
{
  var i = -1;
  if (off != null) i = off;
  if (i < 0) i = self.length+i;
  var r = self.lastIndexOf(s, i);
  return r;
}

fan.sys.Str.index = function(self, s, off)
{
  var i = 0;
  if (off != null) i = off;
  if (i < 0) i = self.length+i;
  var r = self.indexOf(s, i);
  if (r < 0) return null;
  return r;
}

fan.sys.Str.indexr = function(self, s, off)
{
  var i = -1;
  if (off != null) i = off;
  if (i < 0) i = self.length+i;
  var r = self.lastIndexOf(s, i);
  if (r < 0) return null;
  return r;
}

fan.sys.Str.indexIgnoreCase = function(self, s, off)
{
  return fan.sys.Str.index(self.toLowerCase(), s.toLowerCase(), off);
}

fan.sys.Str.indexrIgnoreCase = function(self, s, off)
{
  return fan.sys.Str.indexr(self.toLowerCase(), s.toLowerCase(), off);
}

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.each = function(self, f)
{
  var len = self.length;
  if (f.m_params.size() == 1)
  {
    for (var i=0; i<len; i++)
      f.call(self.charCodeAt(i), i);
  }
  else
  {
    for (var i=0; i<len; i++)
      f.call(self.charCodeAt(i), i);
  }
}

fan.sys.Str.eachr = function(self, f)
{
  if (f.m_params.size() == 1)
  {
    for (var i=self.length-1; i>=0; i--)
      f.call(self.charCodeAt(i), i);
  }
  else
  {
    for (var i=self.length-1; i>=0; i--)
      f.call(self.charCodeAt(i), i);
  }
}

fan.sys.Str.any = function(self, f)
{
  var len = self.length;
  if (f.m_params.size() == 1)
  {
    for (var i=0; i<len; ++i)
      if (f.call(self.charCodeAt(i)) == true)
        return true;
  }
  else
  {
    for (var i=0; i<len; ++i)
      if (f.call(self.charCodeAt(i), i) == true)
        return true;
  }
  return false;
}

fan.sys.Str.all = function(self, f)
{
  var len = self.length;
  if (f.m_params.size() == 1)
  {
    for (var i=0; i<len; ++i)
      if (f.call(self.charCodeAt(i)) == false)
        return false;
  }
  else
  {
    for (var i=0; i<len; ++i)
      if (f.call(self.charCodeAt(i), i) == false)
        return false;
  }
  return true;
}

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.spaces = function(n)
{
  if (fan.sys.Str.$spaces == null)
  {
    fan.sys.Str.$spaces = new Array();
    var s = "";
    for (var i=0; i<20; i++)
    {
      fan.sys.Str.$spaces[i] = s;
      s += " ";
    }
  }
  if (n < 20) return fan.sys.Str.$spaces[n];
  var s = "";
  for (var i=0; i<n; i++) s += " ";
  return s;
}
fan.sys.Str.$spaces = null;

// Fantom restricts lower/upper to ASCII chars only
fan.sys.Str.lower = function(self)
{
  var lower = "";
  for (var i = 0; i < self.length; ++i)
  {
    var char = self[i];
    var code = self.charCodeAt(i);
    if (65 <= code && code <= 90)
      char = String.fromCharCode(code | 0x20);
    lower = lower + char;
  }
  return lower;
}
fan.sys.Str.upper = function(self)
{
  var upper = "";
  for (var i = 0; i < self.length; ++i)
  {
    var char = self[i];
    var code = self.charCodeAt(i);
    if (97 <= code && code <= 122)
      char = String.fromCharCode(code & ~0x20);
    upper = upper + char;
  }
  return upper;
}

fan.sys.Str.capitalize = function(self)
{
  if (self.length > 0)
  {
    var ch = self.charCodeAt(0);
    if (97 <= ch && ch <= 122)
      return String.fromCharCode(ch & ~0x20) + self.substring(1);
  }
  return self;
}

fan.sys.Str.decapitalize = function(self)
{
  if (self.length > 0)
  {
    var ch = self.charCodeAt(0);
    if (65 <= ch && ch <= 90)
    {
      s = String.fromCharCode(ch | 0x20);
      s += self.substring(1)
      return s;
    }
  }
  return self;
}

fan.sys.Str.toDisplayName = function(self)
{
  if (self.length == 0) return "";
  var s = '';

  // capitalize first word
  var c = self.charCodeAt(0);
  if (97 <= c && c <= 122) c &= ~0x20;
  s += String.fromCharCode(c);

  // insert spaces before every capital
  var last = c;
  for (var i=1; i<self.length; ++i)
  {
    c = self.charCodeAt(i);
    if (65 <= c && c <= 90 && last != 95)
    {
      var next = i+1 < self.length ? self.charCodeAt(i+1) : 81;
      if (!(65 <= last && last <= 90) || !(65 <= next && next <= 90))
        s += ' ';
    }
    else if (97 <= c && c <= 122)
    {
      if ((48 <= last && last <= 57)) { s += ' '; c &= ~0x20; }
      else if (last == 95) c &= ~0x20;
    }
    else if (48 <= c && c <= 57)
    {
      if (!(48 <= last && last <= 57)) s += ' ';
    }
    else if (c == 95)
    {
      s += ' ';
      last = c;
      continue;
    }
    s += String.fromCharCode(c);
    last = c;
  }
  return s;
}

fan.sys.Str.fromDisplayName = function(self)
{
  if (self.length == 0) return "";
  var s = "";
  var c = self.charCodeAt(0);
  var c2 = self.length == 1 ? 0 : self.charCodeAt(1);
  if (65 <= c && c <= 90 && !(65 <= c2 && c2 <= 90)) c |= 0x20;
  s += String.fromCharCode(c);
  var last = c;
  for (var i=1; i<self.length; ++i)
  {
    c = self.charCodeAt(i);
    if (c != 32)
    {
      if (last == 32 && 97 <= c && c <= 122) c &= ~0x20;
      s += String.fromCharCode(c);
    }
    last = c;
  }
  return s;
}

fan.sys.Str.mult = function(self, times)
{
  if (times <= 0) return "";
  if (times == 1) return self;
  var s = '';
  for (var i=0; i<times; ++i) s += self;
  return s;
}

fan.sys.Str.justl = function(self, width) { return fan.sys.Str.padr(self, width, 32); }
fan.sys.Str.justr = function(self, width) { return fan.sys.Str.padl(self, width, 32); }

fan.sys.Str.padl = function(self, w, ch)
{
  if (ch === undefined) ch = 32;
  if (self.length >= w) return self;
  var c = String.fromCharCode(ch);
  var s = '';
  for (var i=self.length; i<w; ++i) s += c;
  s += self;
  return s;
}

fan.sys.Str.padr = function(self, w, ch)
{
  if (ch === undefined) ch = 32;
  if (self.length >= w) return self;
  var c = String.fromCharCode(ch);
  var s = '';
  s += self;
  for (var i=self.length; i<w; ++i) s += c;
  return s;
}

fan.sys.Str.reverse = function(self)
{
  var rev = "";
  for (var i=self.length-1; i>=0; i--)
    rev += self[i];
  return rev;
}

fan.sys.Str.trim = function(self, trimStart, trimEnd)
{
  if (self.length == 0) return self;
  if (trimStart == null) trimStart = true;
  if (trimEnd == null) trimEnd = true;
  var s = 0;
  var e = self.length-1;
  while (trimStart && s<self.length && self.charCodeAt(s) <= 32) s++;
  while (trimEnd && e>=s && self.charCodeAt(e) <= 32) e--;
  return self.substr(s, (e-s)+1);
}
fan.sys.Str.trimStart = function(self) { return fan.sys.Str.trim(self, true, false); }
fan.sys.Str.trimEnd   = function(self) { return fan.sys.Str.trim(self, false, true); }

fan.sys.Str.trimToNull = function(self)
{
  var trimmed = fan.sys.Str.trim(self, true, true);
  return trimmed.length == 0 ? null : trimmed;
}

fan.sys.Str.split = function(self, sep, trimmed)
{
  if (sep == null) return fan.sys.Str.splitws(self);
  var toks = fan.sys.List.makeFromJs(fan.sys.Str.$type, []);
  var trim = (trimmed != null) ? trimmed : true;
  var len = self.length;
  var x = 0;
  for (var i=0; i<len; ++i)
  {
    if (self.charCodeAt(i) != sep) continue;
    if (x <= i) toks.add(fan.sys.Str.splitStr(self, x, i, trim));
    x = i+1;
  }
  if (x <= len) toks.add(fan.sys.Str.splitStr(self, x, len, trim));
  return toks;
}

fan.sys.Str.splitStr = function(val, s, e, trim)
{
  if (trim == true)
  {
    while (s < e && val.charCodeAt(s) <= 32) ++s;
    while (e > s && val.charCodeAt(e-1) <= 32) --e;
  }
  return val.substring(s, e);
}

fan.sys.Str.splitws = function(val)
{
  var toks = fan.sys.List.makeFromJs(fan.sys.Str.$type, []);
  var len = val.length;
  while (len > 0 && val.charCodeAt(len-1) <= 32) --len;
  var x = 0;
  while (x < len && val.charCodeAt(x) <= 32) ++x;
  for (var i=x; i<len; ++i)
  {
    if (val.charCodeAt(i) > 32) continue;
    toks.add(val.substring(x, i));
    x = i + 1;
    while (x < len && val.charCodeAt(x) <= 32) ++x;
    i = x;
  }
  if (x <= len) toks.add(val.substring(x, len));
  if (toks.size() == 0) toks.add("");
  return toks;
}

fan.sys.Str.splitLines = function(self)
{
  var lines = fan.sys.List.makeFromJs(fan.sys.Str.$type, []);
  var len = self.length;
  var s = 0;
  for (var i=0; i<len; ++i)
  {
    var c = self.charAt(i);
    if (c == '\n' || c == '\r')
    {
      lines.add(self.substring(s, i));
      s = i+1;
      if (c == '\r' && s < len && self.charAt(s) == '\n') { i++; s++; }
    }
  }
  lines.add(self.substring(s, len));
  return lines;
}

fan.sys.Str.replace = function(self, oldstr, newstr)
{
  if (oldstr == '') return self;
  return self.split(oldstr).join(newstr);
}

fan.sys.Str.numNewlines = function(self)
{
  var numLines = 0;
  var len = self.length;
  for (var i=0; i<len; ++i)
  {
    var c = self.charCodeAt(i);
    if (c == 10) numLines++;
    else if (c == 13)
    {
      numLines++;
      if (i+1<len && self.charCodeAt(i+1) == 10) i++;
    }
  }
  return numLines;
}

fan.sys.Str.isAscii = function(self)
{
  for (var i=0; i<self.length; i++)
    if (self.charCodeAt(i) > 127)
      return false;
  return true;
}

fan.sys.Str.isSpace = function(self)
{
  for (var i=0; i<self.length; i++)
  {
    var ch = self.charCodeAt(i);
    if (ch != 32 && ch != 9 && ch != 10 && ch != 12 && ch != 13)
      return false;
  }
  return true;
}

fan.sys.Str.isUpper = function(self)
{
  for (var i=0; i<self.length; i++)
  {
    var ch = self.charCodeAt(i);
    if (ch < 65 || ch > 90) return false;
  }
  return true;
}

fan.sys.Str.isLower = function(self)
{
  for (var i=0; i<self.length; i++)
  {
    var ch = self.charCodeAt(i);
    if (ch < 97 || ch > 122) return false;
  }
  return true;
}

fan.sys.Str.isAlpha = function(self)
{
  var Int = fan.sys.Int;
  for (var i=0; i<self.length; i++)
  {
    var ch = self.charCodeAt(i);
    if (ch >= 128 || (Int.charMap[ch] & Int.ALPHA) == 0)
      return false;
  }
  return true;
}

fan.sys.Str.isAlphaNum = function(self)
{
  var Int = fan.sys.Int;
  for (var i=0; i<self.length; i++)
  {
    var ch = self.charCodeAt(i);
    if (ch >= 128 || (Int.charMap[ch] & Int.ALPHANUM) == 0)
      return false;
  }
  return true;
}

fan.sys.Str.isEveryChar = function(self, ch)
{
  var len = self.length;
  for (var i=0; i<len; ++i)
    if (self.charCodeAt(i) != ch) return false;
  return true;
}

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.localeCompare = function(self, that)
{
  return self.localeCompare(that, fan.sys.Locale.cur().toStr(), {sensitivity:'base'});
}

fan.sys.Str.localeUpper = function(self)
{
  return self.toLocaleUpperCase(fan.sys.Locale.cur().toStr());
}

fan.sys.Str.localeLower = function(self)
{
  return self.toLocaleLowerCase(fan.sys.Locale.cur().toStr());
}

fan.sys.Str.localeCapitalize = function(self)
{
  var upper = fan.sys.Str.localeUpper(self);
  return upper[0] + self.substring(1);
}

fan.sys.Str.localeDecapitalize = function(self)
{
  var lower = fan.sys.Str.localeLower(self);
  return lower[0] + self.substring(1);
}

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.toBool = function(self, checked) { return fan.sys.Bool.fromStr(self, checked); }
fan.sys.Str.toFloat = function(self, checked) { return fan.sys.Float.fromStr(self, checked); }
fan.sys.Str.toInt = function(self, radix, checked) { return fan.sys.Int.fromStr(self, radix, checked); }
fan.sys.Str.toDecimal = function(self, checked) { return fan.sys.Decimal.fromStr(self, checked); }

fan.sys.Str.$in = function(self) { return fan.sys.InStream.makeForStr(self); }
fan.sys.Str.toUri = function(self) { return fan.sys.Uri.fromStr(self); }
fan.sys.Str.toRegex = function(self) { return fan.sys.Regex.fromStr(self); }

fan.sys.Str.chars = function(self)
{
  var ch = fan.sys.List.makeFromJs(fan.sys.Int.$type, []);
  for (var i=0; i<self.length; i++) ch.add(self.charCodeAt(i));
  return ch;
}

fan.sys.Str.fromChars = function(ch)
{
  var i, s = '';
  for (i=0; i<ch.size(); i++) s += String.fromCharCode(ch.get(i));
  return s;
}

fan.sys.Str.toBuf = function(self, charset)
{
  if (charset === undefined) charset = fan.sys.Charset.utf8();

  var buf = new fan.sys.MemBuf();
  buf.charset$(charset);
  buf.print(self);
  return buf.flip();
}

fan.sys.Str.toCode = function(self, quote, escu)
{
  if (quote === undefined) quote = 34;
  if (escu === undefined) escu = false;

  // opening quote
  var s = "";
  var q = 0;
  if (quote != null)
  {
    q = String.fromCharCode(quote);
    s += q;
  }

  // NOTE: these escape sequences are duplicated in ObjEncoder
  var len = self.length;
  for (var i=0; i<len; ++i)
  {
    var c = self.charAt(i);
    switch (c)
    {
      case '\n': s += '\\' + 'n'; break;
      case '\r': s += '\\' + 'r'; break;
      case '\f': s += '\\' + 'f'; break;
      case '\t': s += '\\' + 't'; break;
      case '\\': s += '\\' + '\\'; break;
      case '"':  if (q == '"')  s += '\\' + '"';  else s += c; break;
      case '`':  if (q == '`')  s += '\\' + '`';  else s += c; break;
      case '\'': if (q == '\'') s += '\\' + '\''; else s += c; break;
      case '$':  s += '\\' + '$'; break;
      default:
        var hex  = function(x) { return "0123456789abcdef".charAt(x); }
        var code = c.charCodeAt(0);
        if (code < 32 || (escu && code > 127))
        {
          s += '\\' + 'u'
            + hex((code>>12)&0xf)
            + hex((code>>8)&0xf)
            + hex((code>>4)&0xf)
            + hex(code & 0xf);
        }
        else
        {
          s += c;
        }
    }
  }

  // closing quote
  if (q != 0) s += q;
  return s;
}

fan.sys.Str.toXml = function(self)
{
  var s = null;
  var len = self.length;
  for (var i=0; i<len; ++i)
  {
    var ch = self.charAt(i);
    var c = self.charCodeAt(i);
    if (c > 62)
    {
      if (s != null) s += ch;
    }
    else
    {
      var esc = fan.sys.Str.xmlEsc[c];
      if (esc != null && (c != 62 || i==0 || self.charCodeAt(i-1) == 93))
      {
        if (s == null)
        {
          s = "";
          s += self.substring(0,i);
        }
        s += esc;
      }
      else if (s != null)
      {
        s += ch;
      }
    }
  }
  if (s == null) return self;
  return s;
}

fan.sys.Str.xmlEsc = [];
fan.sys.Str.xmlEsc[38] = "&amp;";
fan.sys.Str.xmlEsc[60] = "&lt;";
fan.sys.Str.xmlEsc[62] = "&gt;";
fan.sys.Str.xmlEsc[39] = "&#39;";
fan.sys.Str.xmlEsc[34] = "&quot;";

//////////////////////////////////////////////////////////////////////////
// Rhino
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.javaToJs = function(java)
{
  var js = "";
  for(var i=0; i<java.length(); ++i) js += String.fromCharCode(java.charAt(i));
  return js;
}

//////////////////////////////////////////////////////////////////////////
// UTF8
//////////////////////////////////////////////////////////////////////////

fan.sys.Str.toUtf8 = function(str) {
    var n = str.length,
    idx = 0,
    utf8 = new Uint8Array(new ArrayBuffer(n * 4)),
    i, j, c;

  //http://user1.matsumoto.ne.jp/~goma/js/utf.js
  for (i = 0; i < n; ++i) {
    c = str.charCodeAt(i);
    if (c <= 0x7F) {
      utf8[idx++] = c;
    } else if (c <= 0x7FF) {
      utf8[idx++] = 0xC0 | (c >>> 6);
      utf8[idx++] = 0x80 | (c & 0x3F);
    } else if (c <= 0xFFFF) {
      utf8[idx++] = 0xE0 | (c >>> 12);
      utf8[idx++] = 0x80 | ((c >>> 6) & 0x3F);
      utf8[idx++] = 0x80 | (c & 0x3F);
    } else {
      j = 4;
      while (c >> (6 * j)) j++;
      utf8[idx++] = ((0xFF00 >>> j) & 0xFF) | (c >>> (6 * --j));
      while (j--)
        utf8[idx++] = 0x80 | ((c >>> (6 * j)) & 0x3F);
    }
  }
  var res = fan.sys.ByteArray.make(idx);
  for (var i =0; i<idx; ++i) {
    res.set(i, utf8[i]);
  }
  return res;
}

/* utf.js - UTF-8 <=> UTF-16 convertion
 *
 * Copyright (C) 1999 Masanao Izumo <iz@onicos.co.jp>
 * Version: 1.0
 * LastModified: Dec 25 1999
 * This library is free.  You can redistribute it and/or modify it.
 */
fan.sys.Str.fromUtf8 = function(byteArray) {
  var out, i, len, c;
  var char2, char3;
  var array = byteArray.m_array;

  out = "";
  len = array.length;
  i = 0;
  while(i < len) {
    c = array[i++];
    switch(c >> 4)
    { 
      case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
        // 0xxxxxxx
        out += String.fromCharCode(c);
        break;
      case 12: case 13:
        // 110x xxxx   10xx xxxx
        char2 = array[i++];
        out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
        break;
      case 14:
        // 1110 xxxx  10xx xxxx  10xx xxxx
        char2 = array[i++];
        char3 = array[i++];
        out += String.fromCharCode(((c & 0x0F) << 12) |
                       ((char2 & 0x3F) << 6) |
                       ((char3 & 0x3F) << 0));
        break;
    }
  }
  return out;
}
