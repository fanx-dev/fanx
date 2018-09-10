//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Apr 06  Brian Frank  Creation
//

**
** Token is the enum for all the token types.
**
enum class Token
{

//////////////////////////////////////////////////////////////////////////
// Enum
//////////////////////////////////////////////////////////////////////////

  // identifer/literals
  identifier      ("identifier"),
  strLiteral      ("Str literal"),
  intLiteral      ("Int literal"),
  floatLiteral    ("Float literal"),
  decimalLiteral  ("Decimal literal"),
  durationLiteral ("Duration literal"),
  uriLiteral      ("Uri literal"),
  dsl             ("DSL"),
  localeLiteral   ("Locale literal"),

  // operators
  dot("."),
  semicolon     (";"),
  comma         (","),
  colon         (":"),
  doubleColon   ("::"),
  plus          ("+"),
  minus         ("-"),
  star          ("*"),
  slash         ("/"),
  percent       ("%"),
  pound         ("#"),
  increment     ("++"),
  decrement     ("--"),
  bang          ("!"),
  question      ("?"),
  tilde         ("~"),
  pipe          ("|"),
  amp           ("&"),
  caret         ("^"),
  at            ("@"),
  doublePipe    ("||"),
  doubleAmp     ("&&"),
  same          ("==="),
  notSame       ("!=="),
  eq            ("=="),
  notEq         ("!="),
  cmp           ("<=>"),
  lt            ("<"),
  ltEq          ("<="),
  gt            (">"),
  gtEq          (">="),
  lbrace        ("{"),
  rbrace        ("}"),
  lparen        ("("),
  rparen        (")"),
  lbracket      ("["),
  rbracket      ("]"),
  dotDot        (".."),
  dotDotLt      ("..<"),
  defAssign     (":="),
  assign        ("="),
  assignPlus    ("+="),
  assignMinus   ("-="),
  assignStar    ("*="),
  assignSlash   ("/="),
  assignPercent ("%="),
  arrow         ("->"),
  elvis         ("?:"),
  safeDot       ("?."),
  safeArrow     ("?->"),
  docComment    ("**"),
  dollar        ("\$"),
  lparenSynthetic ("("),  // synthetic () grouping of interpolated string exprs

  // keywords
  abstractKeyword,
  asKeyword,
  //assertKeyword,
  breakKeyword,
  caseKeyword,
  catchKeyword,
  classKeyword,
  constKeyword,
  continueKeyword,
  defaultKeyword,
  doKeyword,
  elseKeyword,
  falseKeyword,
  finalKeyword,
  finallyKeyword,
  forKeyword,
  foreachKeyword,
  ifKeyword,
  internalKeyword,
  isKeyword,
  isnotKeyword,
  itKeyword,
  mixinKeyword,
  nativeKeyword,
  newKeyword,
  nullKeyword,
  onceKeyword,
  overrideKeyword,
  privateKeyword,
  protectedKeyword,
  publicKeyword,
  readonlyKeyword,
  returnKeyword,
  staticKeyword,
  superKeyword,
  switchKeyword,
  thisKeyword,
  throwKeyword,
  trueKeyword,
  tryKeyword,
  usingKeyword,
  virtualKeyword,
  volatileKeyword,
  voidKeyword,
  whileKeyword,
  extensionKeyword,
  rtconstKeyword,
  inlineKeyword,
  variKeyword,
  defiKeyword,
  referKeyword,
  asyncKeyword,
  yieldKeyword,
  lretKeyword,

  // misc
  eof("eof");

  // potential keywords:
  //   async, checked, contract, decimal, duck, def, isnot,
  //   namespace, once, unchecked, unless, when,  var, with

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with symbol str, or null symbol for keyword.
  **
  private new make(Str? symbol := null)
  {
    if (symbol == null)
    {
      if (!name.endsWith("Keyword")) throw Err(name)
      this.symbol   = name[0..-8]
      this.keyword  = true
      this.isAssign = false
    }
    else
    {
      this.symbol   = symbol
      this.keyword  = false
      this.isAssign = name.startsWith("assign")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get this Token as a ExprId or throw Err.
  **
  ExprId toExprId()
  {
    switch (this)
    {
      // unary
      case bang:         return ExprId.boolNot

      // binary
      case assign:       return ExprId.assign
      case doubleAmp:    return ExprId.boolAnd
      case doublePipe:   return ExprId.boolOr
      case same:         return ExprId.same
      case notSame:      return ExprId.notSame
      case elvis:        return ExprId.elvis

      // default
      default: throw Err(toStr)
    }
  }

  **
  ** Map an operator token to it's shortcut operator enum.
  ** Degree is 1 for unary and 2 for binary.
  **
  ShortcutOp toShortcutOp(Int degree)
  {
    switch (this)
    {
      case plus:           return ShortcutOp.plus      // a + b
      case minus:          return degree == 1 ? ShortcutOp.negate : ShortcutOp.minus  // -a; a - b
      case star:           return ShortcutOp.mult      // a * b
      case slash:          return ShortcutOp.div       // a / b
      case percent:        return ShortcutOp.mod       // a % b
      case increment:      return ShortcutOp.increment // ++a, a++
      case decrement:      return ShortcutOp.decrement // --a, a--
      case eq:             return ShortcutOp.eq        // a == b
      case notEq:          return ShortcutOp.eq        // a != b
      case cmp:            return ShortcutOp.cmp       // a <=> b
      case gt:             return ShortcutOp.cmp       // a > b
      case gtEq:           return ShortcutOp.cmp       // a >= b
      case lt:             return ShortcutOp.cmp       // a < b
      case ltEq:           return ShortcutOp.cmp       // a <= b
      case assignPlus:     return ShortcutOp.plus      // a += b
      case assignMinus:    return ShortcutOp.minus     // a -= b
      case assignStar:     return ShortcutOp.mult      // a *= b
      case assignSlash:    return ShortcutOp.div       // a /= b
      case assignPercent:  return ShortcutOp.mod       // a %= b
      default: throw Err(toStr)
    }
  }

  **
  ** Is one of: public, protected, internal, private
  **
  Bool isProtectionKeyword()
  {
    this === publicKeyword || this === protectedKeyword ||
    this === internalKeyword || this === privateKeyword
  }

  **
  ** Return if -- or ++
  **
  Bool isIncrementOrDecrement()
  {
    this === Token.increment || this === Token.decrement
  }

  override Str toStr() { symbol }

//////////////////////////////////////////////////////////////////////////
// Keyword Lookup
//////////////////////////////////////////////////////////////////////////

  **
  ** Get a map of the keywords
  **
  const static Str:Token keywords
  static
  {
    map := Str:Token[:]
    vals.each |Token t|
    {
      if (t.keyword) map[t.symbol] = t
    }
    keywords = map
  }

//////////////////////////////////////////////////////////////////////////
// Test
//////////////////////////////////////////////////////////////////////////

  static Void main()
  {
    vals.each |Token t|
    {
      echo(t.name + "  '" + t.symbol + "'")
    }

    echo(keywords)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** Get string used to display token to user in error messages
  const Str symbol

  ** Is this a keyword token such as "null"
  const Bool keyword

  ** Is this an assignment token such as "=", etc "+=", etc
  const Bool isAssign

}