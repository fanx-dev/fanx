//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//
package fanx.main;


public interface IObj extends Comparable {
	Object toImmutable();
	boolean isImmutable();
	Type typeof();
}
