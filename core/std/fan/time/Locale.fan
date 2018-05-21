//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   03 Nov 07  Brian Frank  Creation
//

**
** Locale models a cultural language and region/country.
** See `docLang::Localization` for details.
**
** Also see `Env.locale` and `Pod.locale`.
**
@Serializable { simple = true }
const class Locale
{
  private const Str str
//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Constant for the English Locale "en"
  static const Locale en := fromStr("en")

  **
  ** Parse a locale according to the `toStr` format.
  ** If invalid format and checked is false return null,
  ** otherwise throw ParseErr.
  **
  static new fromStr(Str s, Bool checked := true) {
    len := s.size
    try
    {
      if (len == 2)
      {
        if (s.isLower)
          return Locale(s, s, null);
      }

      if (len == 5)
      {
        Str lang := s[0..<2]
        Str country := s[3..<5]
        if (lang.isLower && country.isUpper && s[2] == '-')
          return Locale(s, lang, country)
      }
    }
    catch (Err e) {
    }
    if (!checked) return en;
    throw ParseErr.make("Locale:$s");
  }

  **
  ** Private constructor
  **
  private new make(Str str, Str lang, Str? country) {
    this.str = str
    this.lang = lang
    this.country = country
  }

//////////////////////////////////////////////////////////////////////////
// Thread
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the current thread's locale.
  **
  native static Locale cur()

  **
  ** Set the current thread's locale.
  ** Throw NullErr if null is passed.
  **
  native static Void setCur(Locale locale)

  **
  ** Run the specified function using this locale as the
  ** the actor's current locale.  This method guarantees
  ** that upon return the actor's current locale remains
  ** unchanged.
  **
  native This use(|This| func)

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the language as a lowercase ISO 639 two letter code.
  **
  const Str lang

  **
  ** Get the country/region as an uppercase ISO 3166 two
  ** letter code.  Return null if the country is unspecified.
  **
  const Str? country

  **
  ** Compute hash code base on normalized toStr format.
  **
  override Int hash() { str.hash }

  **
  ** Equality is based on the normalized toStr format.
  **
  override Bool equals(Obj? obj) {
    if (obj is Locale) {
      return str == ((Locale)obj).str
    }
    return false
  }

  **
  ** Return string representation:
  **   <locale>  := <lang> ["-" <country>]
  **   <lang>    := lowercase ISO 636 two letter code
  **   <country> := uppercase ISO 3166 two letter code
  **
  override Str toStr() { str }

}