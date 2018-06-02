//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 05  Brian Frank  Creation
//
package fanx.fcode;

import java.io.*;
import java.util.*;

/**
 * FSlot is the fcode representation of sys::Slot.
 */
public class FSlot implements FConst {

	public final boolean isStatic() {
		return (flags & FConst.Static) != 0;
	}

	public final boolean isAbstract() {
		return (flags & FConst.Abstract) != 0;
	}

	public final boolean isSynthetic() {
		return (flags & FConst.Synthetic) != 0;
	}

	protected void readCommon(FStore.Input in) throws IOException {
		name = in.name();
		flags = in.u4();
	}

	protected void readAttrs(FStore.Input in) throws IOException {
		attrs = FAttrs.read(in);
	}

	public String name; // simple slot name
	public int flags; // bitmask
	public FAttrs attrs; // meta-data

}