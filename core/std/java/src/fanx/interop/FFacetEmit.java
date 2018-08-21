package fanx.interop;

//
//Copyright (c) 2010, Brian Frank and Andy Frank
//Licensed under the Academic Free License version 3.0
//
//History:
//10 Sep 10  Brian Frank  Creation
//

import java.lang.Enum;
import java.util.*;
import java.util.Map.Entry;
import fan.sys.*;
import fan.sys.List;
import fan.std.*;
import fan.std.Map;
import fanx.emit.*;
import fanx.fcode.*;
import fanx.main.JavaType;
import fanx.main.Type;
import fanx.util.*;

/**
 * FFacetEmit is used to emit Fantom facets as Java annotations.
 */
public class FFacetEmit implements FConst {

	public static void emitFacet(Emitter emit, FPod pod, FAttrs attrs, AttrEmit attr) {
		FFacetEmit x = new FFacetEmit(emit, pod, attrs);
		if (x.num == 0)
			return;

		x.doEmit(attr.info);
	}

	//////////////////////////////////////////////////////////////////////////
	// Construction
	//////////////////////////////////////////////////////////////////////////

	public FFacetEmit(Emitter emit, FPod pod, FAttrs attrs) {
		this.emit = emit;
		this.pod = pod;
		this.facets = attrs.facets;
		this.num = computeNumJavaFacets();
	}

	private int computeNumJavaFacets() {
		if (facets == null)
			return 0;
		int num = 0;
		for (int i = 0; i < facets.length; ++i)
			if (pod.typeRef(facets[i].type).isFFI())
				num++;
		return num;
	}

	//////////////////////////////////////////////////////////////////////////
	// RuntimeVisibleAnnotation Generation
	//////////////////////////////////////////////////////////////////////////

	private void doEmit(Box info) {
		info.u2(num);
		try {
			for (int i = 0; i < facets.length; ++i) {
				FAttrs.FFacet facet = facets[i];
				FTypeRef type = pod.typeRef(facet.type);
				if (type.isFFI())
					encode(info, type, facet.val);
			}
		} catch (Exception e) {
			System.out.println("ERROR: Cannot emit annotations for " + emit.className);
			System.out.println("  Facet type: " + curType);
			e.printStackTrace();
			info.len = 0;
			info.u2(0);
		}
	}

	private void encode(Box info, FTypeRef type, String val) throws Exception {
		// reset type class
		this.curType = type;
		this.curClass = null;

		// parse value into name/value elements
		Elem[] elems = parseElems(val);

		// annotation type
		int cls = emit.cls(type.jname());
		info.u2(cls);
		info.u2(elems.length);
		for (int i = 0; i < elems.length; ++i) {
			Elem elem = elems[i];
			info.u2(emit.utf(elem.name)); // element_name_index
			encodeVal(info, elem); // element_value_pairs
		}
	}

	private void encodeVal(Box info, Elem elem) throws Exception {
		Object v = elem.val;
		if (v instanceof String) {
			encodeStr(info, elem);
			return;
		}
		if (v instanceof Boolean) {
			encodeBool(info, elem);
			return;
		}
		if (v instanceof Long) {
			encodeInt(info, elem);
			return;
		}
		if (v instanceof Double) {
			encodeFloat(info, elem);
			return;
		}
		if (v instanceof Enum) {
			encodeEnum(info, elem);
			return;
		}
		if (v instanceof Type) {
			encodeType(info, elem);
			return;
		}
		if (v instanceof List) {
			encodeList(info, elem);
			return;
		}
		throw new RuntimeException("Unsupported annotation element type '" + curType + "." + elem.name + "': "
				+ elem.val.getClass().getName());
	}

	private void encodeStr(Box info, Elem elem) {
		String val = (String) elem.val;
		info.u1('s');
		info.u2(emit.utf(val));
	}

	private void encodeBool(Box info, Elem elem) {
		Boolean val = (Boolean) elem.val;
		info.u1('Z');
		info.u2(emit.intConst(val.booleanValue() ? 1 : 0));
	}

	private void encodeInt(Box info, Elem elem) throws Exception {
		Long val = (Long) elem.val;
		Class type = elem.type();
		if (type == int.class) {
			info.u1('I');
			info.u2(emit.intConst(Integer.valueOf(val.intValue())));
		} else if (type == short.class) {
			info.u1('S');
			info.u2(emit.intConst(Integer.valueOf(val.intValue())));
		} else if (type == byte.class) {
			info.u1('B');
			info.u2(emit.intConst(Integer.valueOf(val.intValue())));
		} else {
			info.u1('J');
			info.u2(emit.longConst(val));
		}
	}

	private void encodeFloat(Box info, Elem elem) throws Exception {
		Double val = (Double) elem.val;
		Class type = elem.type();
		if (type == float.class) {
			info.u1('F');
			info.u2(emit.floatConst(Float.valueOf(val.floatValue())));
		} else {
			info.u1('D');
			info.u2(emit.doubleConst(val));
		}
	}

	private void encodeEnum(Box info, Elem elem) throws Exception {
		Enum e = (Enum) elem.val;
		info.u1('e');
		info.u2(emit.utf(e.getClass().getName()));
		info.u2(emit.utf(e.toString()));
	}

	private void encodeType(Box info, Elem elem) throws Exception {
		Type t = (Type) elem.val;
		info.u1('c');
		info.u2(emit.utf(FanUtil.toJavaMemberSig(t)));
	}

	private void encodeList(Box info, Elem elem) throws Exception {
		List list = (List) elem.val;
		Class of = elem.type().getComponentType();
		info.u1('[');
		info.u2((int) list.sz());
		for (int i = 0; i < list.sz(); ++i)
			encodeVal(info, new Elem(elem.name, list.get(i), of));
	}

	//////////////////////////////////////////////////////////////////////////
	// Parsing
	//////////////////////////////////////////////////////////////////////////

	private Elem[] parseElems(String str) throws Exception {
		// empty string is a marker annotation
		if (str.length() == 0)
			return noElems;

		// Fantom compiler encodes FFI facets as map string name/value pairs
		Map map = (Map) ObjDecoder.decode(str);
		Elem[] acc = new Elem[(int) map.size()];

		map.each(new Func() {
			int n = 0;

			@Override
			public long arity() {
				return 2;
			}

			public Object call(Object v, Object k) {
				String name = (String) k;
				Object val = v;
				acc[n++] = new Elem(name, val);
				return null;
			}
		});
		return acc;
	}

	private Object parseElemVal(String name, String val) throws Exception {
		try {
			return ObjDecoder.decode(val);
		} catch (Exception e) {
			throw new Exception("Cannot parse " + curType + "." + name + " = " + val + "\n  " + e, e);
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Utils
	//////////////////////////////////////////////////////////////////////////

	Class curClass() throws Exception {
		if (curClass == null)
			curClass = Class.forName(curType.jname().replace("/", "."));
		return curClass;
	}

	//////////////////////////////////////////////////////////////////////////
	// Elem
	//////////////////////////////////////////////////////////////////////////

	class Elem {
		Elem(String n, Object v) {
			name = n;
			val = v;
		}

		Elem(String n, Object v, Class t) {
			name = n;
			val = v;
			type = t;
		}

		Class type() throws Exception {
			if (type == null)
				type = curClass().getMethod(name, new Class[0]).getReturnType();
			return type;
		}

		String name;
		Object val;
		Class type;
	}

	//////////////////////////////////////////////////////////////////////////
	// Fields
	//////////////////////////////////////////////////////////////////////////

	static final Elem[] noElems = new Elem[0];

	private final Emitter emit; // class emitter
	private final FPod pod; // pod being emitted
	private final FAttrs.FFacet[] facets; // all the facets (java and non-java)
	private final int num; // num of Java annotations in facets
	private FTypeRef curType; // current facet type
	private Class curClass; // current facet class
}