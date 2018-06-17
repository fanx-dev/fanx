//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Jul 07  Brian Frank  Split from Method
//
package fan.sys;

import fanx.main.*;

/**
 * Func models an executable subroutine.
 */
public abstract class Func extends FanObj {

	//////////////////////////////////////////////////////////////////////////
	// Methods
	//////////////////////////////////////////////////////////////////////////
	private static Type type = Sys.findType("sys::Func");

	public Type typeof() {
		return type;
	}

	// public abstract Type returns();

	public abstract long arity();

	// public abstract List params();

	// public abstract boolean isImmutable();
	//
	public Object toImmutable() {
		if (isImmutable())
			return this;
		throw NotImmutableErr.make("Func");
	}

	// public abstract Method method();
	private Err tooFewArgs(int given) {
		return ArgErr.make("Too few arguments: " + given + " < " + arity());
	}

	public Object callList(List args) {
		int size = (args == null) ? 0 : (int) args.size();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(args.get(0));
		}
		case 2: {
			return call(args.get(0), args.get(1));
		}
		case 3: {
			return call(args.get(0), args.get(1), args.get(2));
		}
		case 4: {
			return call(args.get(0), args.get(1), args.get(2), args.get(3));
		}
		case 5: {
			return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4));
		}
		case 6: {
			return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5));
		}
		case 7: {
			return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5), args.get(6));
		}
		case 8: {
			return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5), args.get(6),
					args.get(7));
		}
		}
		throw ArgErr.make("too many args:" + size);
	}

	public Object callOn(Object target, List args) {
		int size = (args == null) ? 1 : (int) args.size() + 1;
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(target);
		}
		case 2: {
			return call(target, args.get(0));
		}
		case 3: {
			return call(target, args.get(0), args.get(1));
		}
		case 4: {
			return call(target, args.get(0), args.get(1), args.get(2));
		}
		case 5: {
			return call(target, args.get(0), args.get(1), args.get(2), args.get(3));
		}
		case 6: {
			return call(target, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4));
		}
		case 7: {
			return call(target, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5));
		}
		case 8: {
			return call(target, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5),
					args.get(6));
		}
		}
		
		List dupArgs = List.make(args.size()+1);
		dupArgs.add(target);
		for (int i=0; i<args.size(); ++i) {
			dupArgs.add(args.get(i));
		}
		return callList(dupArgs);
	}

	public Object call() {
		int size = (int) arity();
		if (size == 0)
			call();
		throw tooFewArgs(0);
	}

	public Object call(Object a) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		}
		throw tooFewArgs(1);
	}

	public Object call(Object a, Object b) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		}
		throw tooFewArgs(2);
	}

	public Object call(Object a, Object b, Object c) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		case 3: {
			return call(a, b, c);
		}
		}
		throw tooFewArgs(3);
	}

	public Object call(Object a, Object b, Object c, Object d) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		case 3: {
			return call(a, b, c);
		}
		case 4: {
			return call(a, b, c, d);
		}
		}
		throw tooFewArgs(4);
	}

	public Object call(Object a, Object b, Object c, Object d, Object e) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		case 3: {
			return call(a, b, c);
		}
		case 4: {
			return call(a, b, c, d);
		}
		case 5: {
			return call(a, b, c, d, e);
		}
		}
		throw tooFewArgs(5);
	}

	public Object call(Object a, Object b, Object c, Object d, Object e, Object f) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		case 3: {
			return call(a, b, c);
		}
		case 4: {
			return call(a, b, c, d);
		}
		case 5: {
			return call(a, b, c, d, e);
		}
		case 6: {
			return call(a, b, c, d, e, f);
		}
		}
		throw tooFewArgs(6);
	}

	public Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		case 3: {
			return call(a, b, c);
		}
		case 4: {
			return call(a, b, c, d);
		}
		case 5: {
			return call(a, b, c, d, e);
		}
		case 6: {
			return call(a, b, c, d, e, f);
		}
		case 7: {
			return call(a, b, c, d, e, f, g);
		}
		}
		throw tooFewArgs(7);
	}

	public Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g, Object h) {
		int size = (int) arity();
		switch (size) {
		case 0: {
			return call();
		}
		case 1: {
			return call(a);
		}
		case 2: {
			return call(a, b);
		}
		case 3: {
			return call(a, b, c);
		}
		case 4: {
			return call(a, b, c, d);
		}
		case 5: {
			return call(a, b, c, d, e);
		}
		case 6: {
			return call(a, b, c, d, e, f);
		}
		case 7: {
			return call(a, b, c, d, e, f, g);
		}
		case 8: {
			return call(a, b, c, d, e, f, g, h);
		}
		}
		throw tooFewArgs(8);
	}

	final boolean callBool(Object a) {
		return ((Boolean) call(a)).booleanValue();
	}

	final boolean callBool(Object a, Object b) {
		return ((Boolean) call(a, b)).booleanValue();
	}

	// Hooks used by compiler to generate runtime const field checks for
	// it-blocks
	// public void enterCtor(Object o) {
	// }
	//
	// public void exitCtor() {
	// }
	//
	// public void checkInCtor(Object o) {
	// }

	public void enterCtor(Object o) {
		this.inCtor = o;
	}

	public void exitCtor() {
		this.inCtor = null;
	}

	public void checkInCtor(Object it) {
		if (it == inCtor)
			return;
		String msg = it == null ? "null" : FanObj.typeof(it).qname();
		throw ConstErr.make(msg);
	}

	protected Object inCtor;

	//////////////////////////////////////////////////////////////////////////
	// Indirect
	//////////////////////////////////////////////////////////////////////////

	// public static final int MaxIndirectParams = 8; // max callX()

	////////////////////////////////////////////////////////////////////////////
	//// Bind
	////////////////////////////////////////////////////////////////////////////

	public final Func bind(List args) {
		if (args.size() == 0)
			return this;
		if (args.size() > arity())
			throw ArgErr.make("args.size >params.size");
		return new BindFunc(this, args);
	}

	static class BindFunc extends Func {
		final Func orig;
		final List bound;
		private Boolean isImmutable;

		BindFunc(Func orig, List bound) {
			this.orig = orig;
			this.bound = bound.ro();
		}

		public boolean isImmutable() {
			if (this.isImmutable == null) {
				boolean isImmutable = false;
				if (orig.isImmutable()) {
					isImmutable = true;
					for (int i = 0; i < bound.size(); ++i) {
						Object obj = bound.get(i);
						if (obj != null && !FanObj.isImmutable(obj)) {
							isImmutable = false;
							break;
						}
					}
				}
				this.isImmutable = Boolean.valueOf(isImmutable);
			}
			return this.isImmutable.booleanValue();
		}

		// this isn't a very optimized implementation
		public final Object call() {
			List args = List.make(1);
			return callList(args);
		}

		public final Object call(Object a) {
			List args = List.make(1);
			args.add(a);
			return callList(args);
		}

		public final Object call(Object a, Object b) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			return callList(args);
		}

		public final Object call(Object a, Object b, Object c) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			args.add(c);
			return callList(args);
		}

		public final Object call(Object a, Object b, Object c, Object d) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			args.add(c);
			args.add(d);
			return callList(args);
		}

		public final Object call(Object a, Object b, Object c, Object d, Object e) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			args.add(c);
			args.add(d);
			args.add(e);
			return callList(args);
		}

		public final Object call(Object a, Object b, Object c, Object d, Object e, Object f) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			args.add(c);
			args.add(d);
			args.add(e);
			args.add(f);
			return callList(args);
		}

		public final Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			args.add(c);
			args.add(d);
			args.add(e);
			args.add(f);
			args.add(g);
			return callList(args);
		}

		public final Object call(Object a, Object b, Object c, Object d, Object e, Object f, Object g, Object h) {
			List args = List.make(1);
			args.add(a);
			args.add(b);
			args.add(c);
			args.add(d);
			args.add(e);
			args.add(f);
			args.add(g);
			args.add(h);
			return callList(args);
		}

		public Object callList(List args) {
			if (args == null) {
				args = List.make(1);
			}
			int origReq = (int) orig.arity();
			int haveSize = (int) (bound.size() + args.size());
			if (origReq <= bound.size())
				return orig.callList(bound);

			List temp = List.make(haveSize);
			for (int i=0; i < bound.size(); ++i) {
				temp.add(bound.get(i));
			}
			for (int j = 0; j < args.size(); ++j) {
				temp.add(args.get(j));
			}

			return orig.callList(temp);
		}

		public final Object callOn(Object obj, List args) {
			if (args == null) {
				args = List.make(1);
			}
			int origReq = (int) orig.arity();
			int haveSize = (int) (bound.size() + args.size()) + 1;
			if (origReq <= bound.size())
				return orig.callList(bound);

			List temp = List.make(haveSize);
			for (int i=0; i < bound.size(); ++i) {
				temp.add(bound.get(i));
			}
			temp.add(obj);
			for (int j = 0; j < args.size(); ++j) {
				temp.add(args.get(j));
			}
			return orig.callList(temp);
		}

		@Override
		public long arity() {
			return orig.arity() - bound.size();
		}
	}

}