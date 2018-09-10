
native mixin Math
{
  **
  ** Float value for e which is the base of natural logarithms.
  **
  const static Float e

  **
  ** Float value for pi which is the ratio of the
  ** circumference of a circle to its diameter.
  **
  const static Float pi

/////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the absolute value of this float.  If this value is
  ** positive then return this, otherwise return the negation.
  **
  static extension Float abs(Float self)

  **
  ** Return the smaller of this and the specified Float values.
  **
  static extension Float min(Float self, Float that)

  **
  ** Return the larger of this and the specified Float values.
  **
  static extension Float max(Float self, Float that)

  **
  ** Returns the smallest whole number greater than or equal
  ** to this number.
  **
  static extension Float ceil(Float self)

  **
  ** Returns the largest whole number less than or equal to
  ** this number.
  **
  static extension Float floor(Float self)

  **
  ** Returns the nearest whole number to this number.
  **
  static extension Float round(Float self)

  **
  ** Return e raised to this power.
  **
  static extension Float exp(Float self)

  **
  ** Return natural logarithm of this number.
  **
  static extension Float log(Float self)

  **
  ** Return base 10 logarithm of this number.
  **
  static extension Float log10(Float self)

  **
  ** Return this value raised to the specified power.
  **
  static extension Float pow(Float self, Float pow)

  **
  ** Return square root of this value.
  **
  static extension Float sqrt(Float self)

//////////////////////////////////////////////////////////////////////////
// Trig
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the arc cosine.
  **
  static extension Float acos(Float self)

  **
  ** Return the arc sine.
  **
  static extension Float asin(Float self)

  **
  ** Return the arc tangent.
  **
  static extension Float atan(Float self)

  **
  ** Converts rectangular coordinates (x, y) to polar (r, theta).
  **
  static extension Float atan2(Float y, Float x)

  **
  ** Return the cosine of this angle in radians.
  **
  static extension Float cos(Float self)

  **
  ** Return the hyperbolic cosine.
  **
  static extension Float cosh(Float self)

  **
  ** Return sine of this angle in radians.
  **
  static extension Float sin(Float self)

  **
  ** Return hyperbolic sine.
  **
  static extension Float sinh(Float self)

  **
  ** Return tangent of this angle in radians.
  **
  static extension Float tan(Float self)

  **
  ** Return hyperbolic tangent.
  **
  static extension Float tanh(Float self)

  **
  ** Convert this angle in radians to an angle in degrees.
  **
  static extension Float toDegrees(Float self)

  **
  ** Convert this angle in degrees to an angle in radians.
  **
  static extension Float toRadians(Float self)

}

