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
  tildeArrow    ("~>"),
  elvis         ("?:"),
  safeDot       ("?."),
  safeArrow     ("?->"),
  safeTildeArrow("?~>"),
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
  referKeyword,
  asyncKeyword,
  yieldKeyword,
  lretKeyword,
  awaitKeyword,
  addressofKeyword,
  sizeofKeyword,
  offsetofKeyword,
  uninitKeyword,
  weakKeyword,
  varKeyword,
  letKeyword,
  funKeyword,

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