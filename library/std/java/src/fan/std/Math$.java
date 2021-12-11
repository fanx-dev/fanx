//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fan.std;

import java.lang.Math;

import fanx.main.Sys;
import fanx.main.Type;

public class Math$ {
	public static double pi() {
		return Math.PI;
	}

	public static double e() {
		return Math.E;
	}
	
	private static Type type = null;
	public Type typeof() { if (type == null) { type = Sys.findType("std::Math"); } return type;  }

	//////////////////////////////////////////////////////////////////////////
	// Math
	//////////////////////////////////////////////////////////////////////////

	
  public static boolean approx(double self, double that) { return approx(self, that, null); }
  public static boolean approx(double self, double that, Double tolerance)
  {
    // need this to check +inf, -inf, and nan
    if (fan.sys.FanFloat.compare(self, that) == 0) return true;

    double t;
    if (tolerance == null)
      t = Math.min( Math.abs(self/1e6), Math.abs(that/1e6) );
    else
      t = tolerance.doubleValue();
    return Math.abs(self - that) <= t;
  }

	public static double abs(double self) {
		if (self >= 0)
			return self;
		return -self;
	}

	public static double min(double self, double that) {
		if (self <= that)
			return self;
		return that;
	}

	public static double max(double self, double that) {
		if (self >= that)
			return self;
		return that;
	}

	public static double clamp(double self, double min, double max)
	{
	    if (self < min) return min;
	    if (self > max) return max;
	    return self;
	}

	public static double clip(double self, double min, double max)
	{
	    if (self < min) return min;
	    if (self > max) return max;
	    return self;
	}

	public static double ceil(double self) {
		return Math.ceil(self);
	}

	public static double floor(double self) {
		return Math.floor(self);
	}

	public static double round(double self) {
		return Math.rint(self);
	}

	public static double exp(double self) {
		return Math.exp(self);
	}

	public static double log(double self) {
		return Math.log(self);
	}

	public static double log10(double self) {
		return Math.log10(self);
	}

	public static double pow(double self, double pow) {
		return Math.pow(self, pow);
	}

	public static double sqrt(double self) {
		return Math.sqrt(self);
	}

	//////////////////////////////////////////////////////////////////////////
	// Trig
	//////////////////////////////////////////////////////////////////////////

	public static double acos(double self) {
		return Math.acos(self);
	}

	public static double asin(double self) {
		return Math.asin(self);
	}

	public static double atan(double self) {
		return Math.atan(self);
	}

	public static double atan2(double y, double x) {
		return Math.atan2(y, x);
	}

	public static double cos(double self) {
		return Math.cos(self);
	}

	public static double cosh(double self) {
		return Math.cosh(self);
	}

	public static double sin(double self) {
		return Math.sin(self);
	}

	public static double sinh(double self) {
		return Math.sinh(self);
	}

	public static double tan(double self) {
		return Math.tan(self);
	}

	public static double tanh(double self) {
		return Math.tanh(self);
	}

	public static double toDegrees(double self) {
		return Math.toDegrees(self);
	}

	public static double toRadians(double self) {
		return Math.toRadians(self);
	}

}
