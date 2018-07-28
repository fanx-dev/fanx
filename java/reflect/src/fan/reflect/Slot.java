package fan.reflect;

import fan.sys.*;
import fanx.fcode.*;
import fanx.main.*;

public abstract class Slot extends FanObj {
	//////////////////////////////////////////////////////////////////////////
	// Management
	//////////////////////////////////////////////////////////////////////////

	public static Method findMethod(String qname) {
		return (Method) find(qname, true);
	}

	public static Method findMethod(String qname, boolean checked) {
		Slot slot = find(qname, checked);
		if (slot instanceof Method || checked)
			return (Method) slot;
		return null;
	}

	public static Field findField(String qname) {
		return (Field) find(qname, true);
	}

	public static Field findField(String qname, boolean checked) {
		Slot slot = find(qname, checked);
		if (slot instanceof Field || checked)
			return (Field) slot;
		return null;
	}

	public static Slot find(String qname) {
		return find(qname, true);
	}

	public static Slot find(String qname, boolean checked) {
		String typeName, slotName;
		int dot = qname.lastIndexOf('.');
		typeName = qname.substring(0, dot);
		slotName = qname.substring(dot + 1);

		Type type = Sys.findType(typeName, checked);
		if (type == null)
			return null;

		return FanType.slot(type, slotName, checked);
	}

	public static Func findFunc(String qname) {
		return findFunc(qname, true);
	}

	public static Func findFunc(String qname, boolean checked) {
		Method m = (Method) find(qname, checked);
		if (m == null)
			return null;
		return m.func();
	}

	//////////////////////////////////////////////////////////////////////////
	// Constructor
	//////////////////////////////////////////////////////////////////////////

	public Slot(Type parent, String name, int flags, List facets, int lineNum) {
		this.parent = parent;
		this.name = name;
		this.qname = parent == null ? name : parent.qname() + "." + name;
		this.flags = flags;
		this.facets = (List)facets.toImmutable();
		this.lineNum = lineNum;
	}

	//////////////////////////////////////////////////////////////////////////
	// Methods
	//////////////////////////////////////////////////////////////////////////

	static Type typeof = Sys.findType("reflect::Slot");

	public Type typeof() {
		return typeof;
	}

	public Type parent() {
		return parent;
	}

	public String name() {
		return name;
	}

	public String qname() {
		return qname;
	}

	public boolean isField() {
		return this instanceof Field;
	}

	public boolean isMethod() {
		return this instanceof Method;
	}

	public abstract String signature();

	//////////////////////////////////////////////////////////////////////////
	// Flags
	//////////////////////////////////////////////////////////////////////////

	public final int flags() {
		return flags;
	}

	public final boolean isAbstract() {
		return (flags & FConst.Abstract) != 0;
	}

	public /* */ boolean isConst() {
		return (flags & FConst.Const) != 0;
	} // we let synthetic Methods override

	public final boolean isCtor() {
		return (flags & FConst.Ctor) != 0;
	}

	public final boolean isInternal() {
		return (flags & FConst.Internal) != 0;
	}

	public final boolean isNative() {
		return (flags & FConst.Native) != 0;
	}

	public final boolean isOverride() {
		return (flags & FConst.Override) != 0;
	}

	public final boolean isPrivate() {
		return (flags & FConst.Private) != 0;
	}

	public final boolean isProtected() {
		return (flags & FConst.Protected) != 0;
	}

	public final boolean isPublic() {
		return (flags & FConst.Public) != 0;
	}

	public final boolean isStatic() {
		return (flags & FConst.Static) != 0;
	}

	public final boolean isSynthetic() {
		return (flags & FConst.Synthetic) != 0;
	}

	public final boolean isVirtual() {
		return (flags & FConst.Virtual) != 0;
	}

	public Object trap(String name, List args) {
		// private undocumented access
		if (name.equals("flags"))
			return Long.valueOf(flags);
		if (name.equals("lineNumber"))
			return Long.valueOf(lineNum);
		return super.trap(name, args);
	}

	//////////////////////////////////////////////////////////////////////////
	// Facets
	//////////////////////////////////////////////////////////////////////////

	public List facets() {
		return facets;
	}

	public Facet facet(Type t) {
		return facet(t, true);
	}

	public Facet facet(Type t, boolean c) {
		for (int i = 0; i < facets.size(); ++i) {
			FanObj f = (FanObj) facets.get(i);
			if (f.typeof() == t) {
				return (Facet) f;
			}
		}
		if (c)
			throw UnknownFacetErr.make(t.podName());
		return null;
	}

	public final boolean hasFacet(Type t) {
		return facet(t, false) != null;
	}

	//////////////////////////////////////////////////////////////////////////
	// Documentation
	//////////////////////////////////////////////////////////////////////////

	public String doc() {
		// parent.doc(); // ensure parent has loaded documentation
		return parent.ftype().doc().slotDoc(name);
	}

	//////////////////////////////////////////////////////////////////////////
	// Conversion
	//////////////////////////////////////////////////////////////////////////

	public String toStr() {
		return qname;
	}

	// public void encode(ObjEncoder out) {
	// parent.encode(out);
	// out.w(name);
	// }

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	final int flags;
	final String name;
	final String qname;
	Type parent;
	final List facets;
	// public String doc;
	public final int lineNum;

}
