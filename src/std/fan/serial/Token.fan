//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//  3 Sep 05  Brian Frank  Creation for Fan compiler
//   17 Aug 07  Brian    Rework for serialization parser
//

/**
 * Token defines the token type constants and provides
 * associated utility methods.
 */
internal class Token
{

//////////////////////////////////////////////////////////////////////////
// Token Type Ids
//////////////////////////////////////////////////////////////////////////

  static const Int EOF            := -1
  static const Int ID             := 0
  static const Int BOOL_LITERAL   := 1
  static const Int STR_LITERAL    := 2
  static const Int INT_LITERAL    := 3
  static const Int FLOAT_LITERAL  := 4
  static const Int DECIMAL_LITERAL  := 5
  static const Int DURATION_LITERAL := 6
  static const Int URI_LITERAL    := 7
  static const Int NULL_LITERAL   := 8
  static const Int DOT          := 9   //  .
  static const Int SEMICOLON    := 10  //
  static const Int COMMA        := 11  //  ,
  static const Int COLON        := 12  //  :
  static const Int DOUBLE_COLON := 13  //  ::
  static const Int LBRACE       := 14  //  {
  static const Int RBRACE       := 15  //  }
  static const Int LPAREN       := 16  //  (
  static const Int RPAREN       := 17  //  )
  static const Int LBRACKET     := 18  //  [
  static const Int RBRACKET     := 19  //  ]
  static const Int LRBRACKET    := 20  //  []
  static const Int EQ           := 21  //  :=
  static const Int POUND        := 22  //  #
  static const Int QUESTION     := 23  //  ?
  static const Int AT           := 24  //  @
  static const Int DOLLAR       := 25  //  $
  static const Int AS           := 26  //  as
  static const Int USING        := 27  //  using
  static const Int JAVA_FFI     := 28  //  [java]

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  static Bool isLiteral(Int type)
  {
    return BOOL_LITERAL <= type && type <= NULL_LITERAL
  }

  static Str? keyword(Int type)
  {
    if (AS <= type && type <= USING)
      return toString(type)
    else
      return null
  }

  static Str toString(Int type)
  {
    switch (type)
    {
      case EOF:            return "end of file"
      case ID:             return "identifier"
      case BOOL_LITERAL:   return "Bool literal"
      case STR_LITERAL:    return "Str literal"
      case INT_LITERAL:    return "Int literal"
      case FLOAT_LITERAL:  return "Float literal"
      case DECIMAL_LITERAL:  return "Decimal literal"
      case DURATION_LITERAL: return "Duration literal"
      case URI_LITERAL:    return "Uri literal"
      case NULL_LITERAL:   return "null"
      case DOT:            return "."
      case SEMICOLON:      return ";"
      case COMMA:          return ","
      case COLON:          return ":"
      case DOUBLE_COLON:   return "::"
      case LBRACE:         return "{"
      case RBRACE:         return "}"
      case LPAREN:         return "("
      case RPAREN:         return ")"
      case LBRACKET:       return "["
      case RBRACKET:       return "]"
      case LRBRACKET:      return "[]"
      case EQ:             return ":="
      case POUND:          return "#"
      case QUESTION:       return "?"
      case AT:             return "@"
      case DOLLAR:         return "\$"
      case AS:             return "as"
      case USING:          return "using"
      default:             return "Token[" + type + "]"
    }
  }

}