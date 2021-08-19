//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Dec 09  Andy Frank  Creation
//

//
// Pod
//
//fan.sys.Pod.$sysPod = fan.sys.Pod.find("sys");

//
// Bool
//
fan.sys.Bool.m_defVal = false;

//
// Int
//
fan.sys.Int.m_maxVal = Math.pow(2, 53)
fan.sys.Int.m_minVal = -Math.pow(2, 53)
fan.sys.Int.m_defVal = 0;
fan.sys.Int.Chunk  = 4096;

// Float
fan.sys.Float.m_posInf = fan.sys.Float.make(Number.POSITIVE_INFINITY);
fan.sys.Float.m_negInf = fan.sys.Float.make(Number.NEGATIVE_INFINITY);
fan.sys.Float.m_nan    = fan.sys.Float.make(Number.NaN);
fan.sys.Float.m_e      = fan.sys.Float.make(Math.E);
fan.sys.Float.m_pi     = fan.sys.Float.make(Math.PI);
fan.sys.Float.m_defVal = fan.sys.Float.make(0);

//
// Num
//
/*
fan.sys.NumPattern.cache("00");    fan.sys.NumPattern.cache("000");       fan.sys.NumPattern.cache("0000");
fan.sys.NumPattern.cache("0.0");   fan.sys.NumPattern.cache("0.00");      fan.sys.NumPattern.cache("0.000");
fan.sys.NumPattern.cache("0.#");   fan.sys.NumPattern.cache("#,###.0");   fan.sys.NumPattern.cache("#,###.#");
fan.sys.NumPattern.cache("0.##");  fan.sys.NumPattern.cache("#,###.00");  fan.sys.NumPattern.cache("#,###.##");
fan.sys.NumPattern.cache("0.###"); fan.sys.NumPattern.cache("#,###.000"); fan.sys.NumPattern.cache("#,###.###");
fan.sys.NumPattern.cache("0.0#");  fan.sys.NumPattern.cache("#,###.0#");  fan.sys.NumPattern.cache("#,###.0#");
fan.sys.NumPattern.cache("0.0##"); fan.sys.NumPattern.cache("#,###.0##"); fan.sys.NumPattern.cache("#,###.0##");
*/
//
// Str
//
fan.sys.Str.m_defVal = "";

