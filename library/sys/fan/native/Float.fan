//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    2 Dec 05  Brian Frank  Creation
//   11 Oct 06  Brian Frank  Rename Real to Float
//

**
** Float is used to represent a 64-bit floating point number.
**
@Serializable { simple = true }
native const struct class Float : Num
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Make a Float for the specified 64-bit representation according
  ** IEEE 754 floating-point double format bit layout.  This method is
  ** paired with `Float.bits`.
  **
  static Float makeBits(Int bits)

  **
  ** Make a Float for the specified 32-bit representation according
  ** IEEE 754 floating-point single format bit layout.  This method is
  ** paired with `Float.bits32`.
  **
  static Float makeBits32(Int bits)

  **
  ** Parse a Str into a Float.  Representations for infinity and
  ** not-a-number are "-INF", "INF", "NaN".  This string format matches
  ** the lexical representation of Section 3.2.5 of XML Schema Part 2.
  ** If invalid format and checked is false return null, otherwise throw
  ** ParseErr.
  **
  static new fromStr(Str s, Bool checked := true)

  **
  ** Generate a random float between 0.0 inclusive and 1.0 exclusive.
  ** Also see `Int.random`, `Range.random`, `List.random`, and `util::Random`.
  **
  static Float random()

  **
  ** Default value is 0f.
  **
  static const Float defVal := 0f

  **
  ** Private constructor.
  **
  //TODO static new
  private new privateMake() {}

  **
  ** Float value for positive infinity.
  **
  const static Float posInf := 1f/0f

  **
  ** Float value for negative infinity.
  **
  const static Float negInf := -1f/0f

  **
  ** Float value for Not-A-Number.
  **
  const static Float nan := 0f/0f

  **
  ** Float value for e which is the base of natural logarithms.
  **
  @NoDoc
  const static Float e := 2.718281828459045

  **
  ** Float value for pi which is the ratio of the
  ** circumference of a circle to its diameter.
  **
  @NoDoc
  const static Float pi := 3.141592653589793

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if same float value.  Like Java, NaN != NaN.
  ** Also see `compare`.
  **
  override Bool equals(Obj? obj)

  **
  ** Compare based on floating point value.
  **
  ** NaN works as follows:
  **   - for the '<=>' operator NaN is always less than other
  **     values and equal to itself (so sort works as expected)
  **   - for all other comparison operators anything compared
  **     against NaN is false (normal Java semanatics)
  **
  ** Examples:
  **   Float.nan <=> Float.nan  =>  0
  **   2f <=> Float.nan         =>  1
  **   Float.nan <=> 2f         =>  -1
  **   2f < Float.nan           =>  false
  **   Float.nan < 2f           =>  false
  **   Float.nan <= Float.nan   =>  false
  **
  override Int compare(Obj obj) {
    self := this
    that := (Float)obj
    if (self.isNaN) {
      return that.isNaN ? 0 : -1;
    }
    else if (that.isNaN) {
      return +1;
    }
    else
    {
      if (self < that) return -1; return self == that ? 0 : +1;
    }
  }

  **
  ** Return if this is Float.nan.  Also see `compare`.
  **
  Bool isNaN()

  **
  ** Return if this is negative zero value.
  **
  Bool isNegZero() { bits() == 0x8000000000000000 }

  **
  ** If this value is negative zero then return
  ** normalized zero, otherwise return this value.
  **
  Float normNegZero() { bits() == 0x8000000000000000 ? 0f : this }

  **
  ** Return bits().
  **
  override Int hash() { bits() }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  ////////// unary //////////

  ** Negative of this.  Shortcut is -a.
  @Operator Float negate()

  ** Increment by one.  Shortcut is ++a or a++.
  @Operator Float increment() { this + 1.0 }

  ** Decrement by one.  Shortcut is --a or a--.
  @Operator Float decrement() { this - 1.0 }

  ////////// mult //////////

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Float mult(Float b)

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Float multInt(Int b)

  ** Multiply this with b.  Shortcut is a*b.
  //@Operator Decimal multDecimal(Decimal b)

  ////////// div //////////

  ** Divide this by b.  Shortcut is a/b.
  @Operator Float div(Float b)

  ** Divide this by b.  Shortcut is a/b.
  @Operator Float divInt(Int b)

  ** Divide this by b.  Shortcut is a/b.
  //@Operator Decimal divDecimal(Decimal b)

  ////////// mod //////////

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Float mod(Float b)

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Float modInt(Int b)

  ** Return remainder of this divided by b.  Shortcut is a%b.
  //@Operator Decimal modDecimal(Decimal b)

  ////////// plus //////////

  ** Add this with b.  Shortcut is a+b.
  @Operator Float plus(Float b)

  ** Add this with b.  Shortcut is a+b.
  @Operator Float plusInt(Int b)

  ** Add this with b.  Shortcut is a+b.
  //@Operator Decimal plusDecimal(Decimal b)

  ////////// minus //////////

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Float minus(Float b)

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Float minusInt(Int b)

  ** Subtract b from this.  Shortcut is a-b.
  //@Operator Decimal minusDecimal(Decimal b)


//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Return 64-bit representation according IEEE 754 floating-point
  ** double format bit layout.  This method is paired with `Float.makeBits`.
  **
  Int bits()

  **
  ** Return 32-bit representation according IEEE 754 floating-point
  ** single format bit layout.  This method is paired with `Float.makeBits32`.
  **
  Int bits32()

  **
  ** Get string representation according to the lexical representation defined
  ** by Section 3.2.5 of XML Schema Part 2.  Representations for infinity and
  ** not-a-number are "-INF", "INF", "NaN".
  **
  override Str toStr()

  **
  ** Get this Float as a Fantom code literal.
  **
  Str toCode() {
    if (isNaN) return "Float.nan";
    if (this == posInf) return "Float.posInf";
    if (this == negInf) return "Float.negInf";
    return toStr;
  }

  **
  ** Convert this number to an Int.
  **
  override Int toInt()

  **
  ** Convert this number to a Float.
  **
  override Float toFloat() { this }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  **
  ** Format this floating point number for the current locale.
  ** If pattern is null, then the locale's default pattern is used.
  ** Also see `Num.localeDecimal`, `Num.localeGrouping`, etc.
  **
  ** The pattern format:
  **   #   optional digit
  **   0   required digit
  **   .   decimal point
  **   ,   grouping separator (only last one before decimal matters)
  **
  ** Examples:
  **   12345.786f.toLocale("#,###.0")  =>  12,345.8
  **   7.1234f.toLocale("#.000")       =>  7.123
  **   0.1234f.toLocale("#.000")       =>  .123
  **   0.1234f.toLocale("0.00")        =>  0.12
  **   70.12f.toLocale("0.0000")       =>  70.1200
  **
  Str toLocale(Str? pattern := null)

}