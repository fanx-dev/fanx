//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Mar 06  Brian Frank  Creation
//   4 Oct 08  Brian Frank  Refactor Num into Number/FanNum
//
package fan.sys;

import java.math.*;
import java.text.DecimalFormatSymbols;

import fanx.main.*;

/**
 * FanNum defines the methods for sys::Num. The actual class used for
 * representation is java.lang.Number.
 */
public class FanNum {

	public static long toInt(Number self) {
		return self.longValue();
	}

	public static double toFloat(Number self) {
		return self.doubleValue();
	}

	public static BigDecimal toDecimal(Number self) {
		if (self instanceof BigDecimal)
			return (BigDecimal) self;
		if (self instanceof Long)
			return new BigDecimal(self.longValue());
		return new BigDecimal(self.doubleValue());
	}

	private static Type type = Sys.findType("sys::Num");

	public static Type typeof(Number self) {
		return type;
	}

	//////////////////////////////////////////////////////////////////////////
	// Locale
	//////////////////////////////////////////////////////////////////////////
	//
	// public static String localeDecimal()
	// {
	// return Locale.cur().numSymbols().decimal;
	// }
	//
	// public static String localeGrouping()
	// {
	// return Locale.cur().numSymbols().grouping;
	// }
	//
	// public static String localeMinus()
	// {
	// return Locale.cur().numSymbols().minus;
	// }
	//
	// public static String localePercent()
	// {
	// return Locale.cur().numSymbols().percent;
	// }
	//
	// public static String localePosInf()
	// {
	// return Locale.cur().numSymbols().posInf;
	// }
	//
	// public static String localeNegInf()
	// {
	// return Locale.cur().numSymbols().negInf;
	// }
	//
	// public static String localeNaN()
	// {
	// return Locale.cur().numSymbols().nan;
	// }
	//
}