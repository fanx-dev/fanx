//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Apr 08  Brian Frank  Creation
//

/**
 * NumDigits is used to represents the character digits in a number for
 * locale pattern processing. It inputs a long, double, or BigDecimal into
 * an array of digit chars and the index to the decimal point.
 */
internal class NumDigits {
  //new makeDecimal(Decimal d) : this.make(d.toStr) {
  //}

  new make(Str s) {
    digits = Int[,]
    digits.capacity = s.size + 16

    Int expPos := -1
    decimal := -99
    for (Int i := 0; i < s.size; ++i) {
      Int c := s.get(i)
      if (c == '-') {
        negative = true
        continue
      }
      if (c == '.') {
        decimal = negative ? i - 1 : i
        continue
      }
      if (c == 'e' || c == 'E') {
        expPos = i
        break
      }
      digits.add(c)
    }
    size = digits.size

    // add decimal to end if not in orig string,
    // otherwise removing any trailing fractional zeros
    if (decimal < 0)
      decimal = size
    else if (size > decimal && digits[size - 1] == '0')
      size--

    // if we had an exponent, then we need to normalize it
    if (expPos >= 0) {
      // move the decimal by the exponent
      Int exp := (s[(expPos + 1)..-1]).toInt
      decimal += exp

      // add leading/trailing zeros as necessary
      if (decimal >= size) {
        while (size <= decimal)
          digits[size++] = '0'
      } else if (decimal < 0) {
        /*
        System.arraycopy(digits, 0, digits, -decimal, size)
        for (Int i := 0; i < -decimal; ++i)
          digits[i] = '0'
        */
        zs := Int[,]
        zs.fill('0', -decimal)
        digits.insertAll(0, zs)

        size += -decimal
        decimal = 0
      }
    }
  }

  new makeInt(Int d) {
    if (d < 0) {
      negative = true
      d = -d
    }
    Str s := d.toStr
    if (s.get(0) == '-')
      s = "9223372036854775808" // handle overflow case
    digits = s.chars
    size = digits.size
    decimal = digits.size
  }

  Int intSize() {
    return decimal
  }

  Int fracSize() {
    return size - decimal
  }

  Bool zeroInt() {
    for (Int i := 0; i < decimal; ++i)
      if (digits[i] != '0')
        return false
    return true
  }

  Bool zeroFrac(Int maxFrac) {
    Int until := decimal + maxFrac
    if (until >= digits.size)
      return true
    for (Int i := decimal; i < until; ++i)
      if (digits[i] != '0')
        return false
    return true
  }

  Void round(Int maxFrac) {
    // if frac sie already eq or less than maxFrac no rounding needed
    if (fracSize <= maxFrac)
      return

    // if we need to round, then round the prev digit
    if (digits[decimal + maxFrac] >= '5') {
      Int i := decimal + maxFrac - 1
      while (true) {
        if (digits[i] < '9') {
          digits[i]++
          break
        }
        digits[i--] = '0'
        if (i < 0) {
          digits.insert(0, '1')
          //System.arraycopy(digits, 0, digits, 1, size)
          //digits[0] = '1'
          size++
          decimal++
          break
        }
      }
    }

    // update size and clip any trailing zeros
    size = decimal + maxFrac
    while (digits[size - 1] == '0' && size > decimal)
      size--
  }

  override Str toStr() {
    return Str.fromChars(digits, 0, size) + " neg=" + negative + " decimal=" + decimal
  }

  Int[] digits // char digits
  Int decimal // index where decimal fits into digits
  Int size // size of digits used
  Bool negative // is this a negative number
}

//////////////////////////////////////////////////////////////////////////
// NumPattern
//////////////////////////////////////////////////////////////////////////

/**
 * NumPattern parses and models a numeric locale pattern.
 */
internal const class NumPattern {
  // pre-compute common patterns to aVoid parsing
  private const static [Str:NumPattern] cache

  private static Void doCache([Str:NumPattern] map, Str p) {
    map[p] = parse(p)
  }

  static {
    map := [Str:NumPattern][:]
    doCache(map, "00")
    doCache(map, "000")
    doCache(map, "0000")
    doCache(map, "0.0")
    doCache(map, "0.00")
    doCache(map, "0.000")
    doCache(map, "0.#")
    doCache(map, "#,###.0")
    doCache(map, "#,###.#")
    doCache(map, "0.##")
    doCache(map, "#,###.00")
    doCache(map, "#,###.##")
    doCache(map, "0.###")
    doCache(map, "#,###.000")
    doCache(map, "#,###.###")
    doCache(map, "0.0#")
    doCache(map, "#,###.0#")
    doCache(map, "#,###.0#")
    doCache(map, "0.0##")
    doCache(map, "#,###.0##")
    doCache(map, "#,###.0##")
    cache = map
  }

  static new parse(Str s) {
    x := cache.get(s)
    if (x != null)
      return x
    return make(s)
  }

  private new make(Str s) {
    Int group := Int.maxVal
    Bool optInt := true
    Bool comma := false
    Bool decimal := false
    Int minInt := 0
    minFrac := 0
    maxFrac := 0
    Int last := 0
    for (Int i := 0; i < s.size; ++i) {
      Int c := s.get(i)
      switch (c) {
      case ',':
        comma = true
        group = 0
        break
      case '0':
        if (decimal) {
          minFrac++
          maxFrac++
        } else {
          minInt++
          if (comma)
            group++
        }
        break
      case '#':
        if (decimal)
          maxFrac++
        else if (comma)
          group++
        break
      case '.':
        decimal = true
        optInt = last == '#'
        break
      default:
        throw ArgErr.make("Invalid pattern char '" + c + "': " + s)
      }
      last = c
    }
    if (!decimal)
      optInt = last == '#'

    this.pattern = s
    this.group = group
    this.optInt = optInt
    this.minInt = minInt
    this.minFrac = minFrac
    this.maxFrac = maxFrac
  }

  override Str toStr() {
    return pattern + " group=" + group + " minInt=" + minInt + " maxFrac=" + maxFrac + " minFrac=" + minFrac
        + " optInt=" + optInt
  }

  const Str pattern // pattern parsed
  const Int group // grouping size (typically 3 for 1000)
  const Bool optInt // if we have "#." then the Int part if optional
              // (no leading zero)
  const Int minInt // min digits in integer part (leading zeros)
  const Int minFrac // min digits in fractional part (trailing zeros)
  const Int maxFrac // max digits in fractional part (clipping)
}

//////////////////////////////////////////////////////////////////////////
// NumFormat
//////////////////////////////////////////////////////////////////////////

internal class NumFormat {
  static Str format(NumPattern p, NumDigits d) {
    // string buffer
    //Locale.NumSymbols symbols = locale.numSymbols
    s := StrBuf()
    if (d.negative) s.addChar('-')

    // if we have more frac digits then maxFrac, then round off
    d.round(p.maxFrac)

    // if we have an optional integer part, and only
    // fractional digits, then don't include leading zero
    Int start := 0
    if (p.optInt && d.zeroInt) start = d.decimal

    // if min required fraction digits are zero and we
    // have nothing but zeros, then truncate to a whole number
    if (p.minFrac == 0 && d.zeroFrac(p.maxFrac)) d.size = d.decimal

    // leading zeros
    for (Int i:=0; i<p.minInt-d.decimal; ++i) s.addChar('0')

    // walk thru the digits and apply locale symbols
    Bool decimal := false
    for (Int i:=start; i<d.size; ++i)
    {
      if (i < d.decimal)
      {
        if ((d.decimal - i) % p.group == 0 && i > 0)
          s.addChar(',')
      }
      else
      {
        if (i == d.decimal && p.maxFrac > 0)
        {
          s.addChar('.')
          decimal = true
        }
        if (i-d.decimal >= p.maxFrac) break
      }
      s.addChar(d.digits[i])
    }

    // trailing zeros
    for (Int i:=0; i<p.minFrac-d.fracSize; ++i)
    {
      if (!decimal) { s.addChar('.'); decimal = true }
      s.addChar('0')
    }

    // handle #.# case
    if (s.size == 0) return "0"

    return s.toStr
  }

  static Str formatDigits(Str str, Str pattern) {
    // parse pattern and get digits
    p := NumPattern.parse(pattern);
    d := NumDigits(str);

    // route to common FanNum method
    return format(p, d);
  }

  static Str formatInt(Int self, Str? pattern) {
    // if pattern is "B" format as bytes
    if (pattern != null && pattern.size() == 1 && pattern.get(0) == 'B')
      return toLocaleBytes(self);

    // get default pattern if necessary
    if (pattern == null)
      pattern = "#,###"

    // parse pattern and get digits
    p := NumPattern.parse(pattern);
    d := NumDigits(self);

    // route to common FanNum method
    return format(p, d);
  }

  private static Str toLocaleBytes(Int b)
  {
    if (b < KB)    return b.toStr + "B";
    if (b < 10*KB) return formatDigits((b.toFloat/KB).toStr, "#.#") + "KB";
    if (b < MB)    return (b.toFloat/KB+0.5).toInt.toStr + "KB";
    if (b < 10*MB) return formatDigits((b.toFloat/MB).toStr, "#.#") + "MB";
    if (b < GB)    return (b.toFloat/MB+0.5).toInt.toStr + "MB";
    if (b < 10*GB) return formatDigits((b.toFloat/GB).toStr, "#.#") + "GB";
    return (b.toFloat/GB+0.5).toInt.toStr + "GB";
  }
  private static const Int KB := 1024
  private static const Int MB := 1024*1024
  private static const Int GB := 1024*1024*1024
}


