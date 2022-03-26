//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 07  Brian Frank  Creation
//

**
** RegexMatcher is used to matching operations
** on a regular expression.
**
native final class RegexMatcher
{
  private const Int handle
//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new make() {}

//////////////////////////////////////////////////////////////////////////
// Matching
//////////////////////////////////////////////////////////////////////////

  **
  ** Match the entire region against the pattern.  If a match
  ** is made then return true - additional info is available
  ** via the `group`, `start`, and `end` methods.  Return false
  ** if a match cannot be made.
  **
  native Bool matches()

  **
  ** Attempt to find the next match .  If a match is made
  ** then return true - additional info is available via
  ** the `group`, `start`, and `end` methods.  Return false
  ** if a match cannot be made.
  **
  native Bool find()

//////////////////////////////////////////////////////////////////////////
// Replace
//////////////////////////////////////////////////////////////////////////

  **
  ** Replace the first sequence which matches the pattern with
  ** the given replacment string.
  **
  native Str replaceFirst(Str replacement)

  **
  ** Replace every sequence which matches the pattern with the
  ** given replacment string.
  **
  native Str replaceAll(Str replacement)

//////////////////////////////////////////////////////////////////////////
// Group
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the number of capturing groups or zero if no match.
  ** Group zero is is not included.
  **
  native Int groupCount()

  **
  ** Return the substring captured by the matching operation.
  ** Group index zero denotes the entire pattern and capturing
  ** groups are indexed from left to right starting at one.  Return
  ** null if group failed to match part of the input.  Throw exception
  ** if failed to match input or group index is invalid.
  **
  native Str? group(Int group := 0)

  **
  ** Return the start index of the given `group`.
  ** Throw exception if failed to match input or group
  ** index is invalid.
  **
  native Int start(Int group := 0)

  **
  ** Return end index+1 one of the given `group`.
  ** Throw exception if failed to match input or group
  ** index is invalid.
  **
  native Int end(Int group := 0)

  //native protected override Void finalize()
}