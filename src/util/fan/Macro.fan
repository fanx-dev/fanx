//
// Copyright (c) 2017, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Jun 17  Matthew Giannini  Creation
//

**
** Macro provides a way to replace macro expressions within a pattern
** using a pluggable implementation for the macro resolution. See
** `apply` for macro syntax.
**
@Js const class Macro
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Create a macro for the given pattern.
  new make(Str pattern)
  {
    this.pattern = pattern
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** The unresolved macro pattern
  const Str pattern

  // Modes
  private static const Int norm    := 0
  private static const Int inMacro := 1

//////////////////////////////////////////////////////////////////////////
// Macro
//////////////////////////////////////////////////////////////////////////

  ** The `pattern` text is scanned for keys delimited by
  ** '{{' and '}}'. The text between the delimiters is the key.
  ** The supplied callback is invoked to resolve the key and the macro
  ** is replaced with that value in the text. Returns the resulting Str
  ** after the macro has been applied. Throws `sys::ParseErr` if the pattern
  ** contains invalid macros.
  **
  **   Macro("{{hello}} {{world}}!").apply { it.upper } => HELLO WORLD!
  **   Macro("{{notTerminated").apply { it.upper } => ParseErr
  **
  ** No lexical restriction is placed on the macro keys. The callback
  ** is entirely reponsible for validating keys. For example, all the following
  ** are perfectly acceptable keys as far as parsing the macro goes:
  **   - '{{}}'      - empty key
  **   - '{{  }}'    - all white space
  **   - '{{ foo }}' - leading and trailing white space
  **
  Str apply(|Str key->Str| resolve)
  {
    resBuf := StrBuf()
    keyBuf := StrBuf()
    pos    := 0
    start  := -1
    size   := pattern.size
    mode   := norm

    while (true)
    {
      // normal scanning
      if (mode == norm)
      {
        if (pos == size) break

        if (pattern[pos] == '{' && pattern.getSafe(pos+1) == '{')
        {
          mode  = inMacro
          start = pos
          pos += 2
          keyBuf.clear
        }
        else
        {
          resBuf.addChar(pattern[pos++])
        }
      }
      // inside a macro
      else if (mode == inMacro)
      {
        if (pos == size) throw ParseErr("Unterminated macro at index $start: $pattern")

        if (pattern[pos] == '}' && pattern.getSafe(pos+1) == '}')
        {
          mode = norm
          pos += 2
          // NOTE: currently allowing empty keys and keys with
          // leading/trailing white space
          resBuf.add(resolve(keyBuf.toStr))
        }
        else
        {
          keyBuf.addChar(pattern[pos++])
        }
      }
      else throw Err("Illegal State: mode [$mode] pos [$pos]: $pattern")
    }
    return resBuf.toStr
  }

  ** Get a list of all the macro keys in the order they appear in the macro
  ** `pattern`. Duplicates are not removed.
  **
  **   Macro("{{hello}} {{world}}! Good-bye {{world}}").keys
  **      => ["hello", "world", "world"]
  **
  Str[] keys()
  {
    acc := Str[,]
    apply |Str key->Str| { acc.add(key); return key }
    return acc
  }
}