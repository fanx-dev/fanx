//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

**
** Depend models a dependency as a pod name and a version
** constraint.  Convention for Fantom pods is a four part
** version format of 'major.minor.build.patch'.
**
** The string format for Depend:
**
**   <depend>        := <name> space <version>
**   <version>       := <digits> ["." <digits>]*
**   <digits>        := <digit> [<digits>]*
**   <digit>         := "0" - "9"
**
**  Examples:
**    "foo 1.2"      Any version of foo 1.2 with any build or patch number
**    "foo 1.2.64"   Any version of foo 1.2.64 with any patch number
**
@Serializable { simple = true }
final const class Depend
{
  private const Str str

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse the string according into a dependency.  See class
  ** header for specification of the format.  If invalid format
  ** and checked is false return null, otherwise throw ParseErr.
  **
  static new fromStr(Str s) {
    pos := s.find(" ")
    if (pos <= 0 || pos >= s.size-1) {
      throw ParseErr("Invalid Depend :$s")
    }
    name := s[0..<pos]

    end := s.find("+")
    if (end == -1) end = s.find(",")
    ver := Version.fromStr(s[pos+1..end])
    return privateMake(name, ver)
  }

  **
  ** Private constructor
  **
  private new privateMake(Str name, Version ver) {
    this.name = name
    this.version = ver
    this.str = "$name $version"
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two Depends are equal if they have same normalized string representation.
  **
  override Bool equals(Obj? that) {
    if (that isnot Depend) return false
    return str == ((Depend)that).str
  }

  **
  ** Return a hash code based on the normalized string representation.
  **
  override Int hash() { str.hash }

  **
  ** Get the normalized string format of this dependency.  Normalized
  ** dependency strings do not contain any optional spaces.  See class
  ** header for specification of the format.
  **
  override Str toStr() { str }

  **
  ** Get the pod name of the dependency.
  **
  const Str name

//////////////////////////////////////////////////////////////////////////
// Version Constraints
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the version constraint
  **
  const Version version

  **
  ** Return if the specified version is a match against
  ** this dependency's constraints.  See class header for
  ** matching rules.
  **
  Bool match(Version v) {
    if (version.segments.size > v.segments.size) {
      return false
    }
    for (i:=0; i<version.segments.size; ++i) {
      if (version.segments[i] != v.segments[i]) {
        return false
      }
    }
    return true
  }
}

