//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Dec 08  Brian Frank  Creation
//
package fan.util;

import java.util.HashMap;
import java.util.ArrayList;

import fan.sys.*;
import fan.std.*;
import fanx.main.*;
import java.lang.Math;

/**
 * Unit
 */
public final class Unit
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Database
//////////////////////////////////////////////////////////////////////////

  public static Unit fromStr(String name) { return fromStr(name, true); }
  public static Unit fromStr(String name, boolean checked)
  {
    synchronized (byId)
    {
      Unit unit = (Unit)byId.get(name);
      if (unit != null || !checked) return unit;
      throw Err.make("Unit not found: " + name);
    }
  }

  public static List list()
  {
    synchronized (list)
    {
      return list.dup().ro();
    }
  }

  public static List quantities()
  {
    return quantityNames;
  }

  public static List quantity(String quantity)
  {
    List list = (List)quantities.get(quantity);
    if (list == null) throw Err.make("Unknown unit database quantity: " + quantity);
    return list;
  }

  private static List loadDatabase()
  {
    InStream in = null;
    List quantityNames = List.make(64);
    try
    {
      // open etc/sys/units.txt
      String path = "etc/sys/units.txt";
      //if (Sys.isJarDist)
      if (false)
        in = fanx.interop.Interop.toFan(Unit.class.getClassLoader().getResourceAsStream(path));
      else
        in = Env.cur().findFile(Uri.fromStr(path)).in();

      // parse each line
      String curQuantityName = null;
      List curQuantityList = null;
      String line;
      while ((line = in.readLine()) != null)
      {
        // skip comment and blank lines
        line = line.trim();
        if (line.startsWith("//") || line.length() == 0) continue;

        // quanity sections delimited as "-- name (dim)"
        if (line.startsWith("--"))
        {
          if (curQuantityName != null) quantities.put(curQuantityName, curQuantityList.toImmutable());
          curQuantityName = line.substring(2, line.indexOf('(')).trim();
          curQuantityList = List.make(8);//Sys.UnitType);
          quantityNames.add(curQuantityName);
          continue;
        }

        // must be a unit
        try
        {
          Unit unit = Unit.define(line);
          curQuantityList.add(unit);
        }
        catch (Exception e)
        {
          System.out.println("WARNING: Init unit in etc/sys/units.txt: " + line);
          System.out.println("  " + e);
        }
      }
      quantities.put(curQuantityName, curQuantityList.toImmutable());
    }
    catch (Throwable e)
    {
      try { in.close(); } catch (Exception e2) {}
      System.out.println("WARNING: Cannot load etc/sys/units.txt");
      e.printStackTrace();
    }
    return (List)quantityNames.toImmutable();
  }

//////////////////////////////////////////////////////////////////////////
// Definition
//////////////////////////////////////////////////////////////////////////

  public static Unit define(String str)
  {
    // parse
    Unit unit = null;
    try
    {
      unit = parseUnit(str);
    }
    catch (Throwable e)
    {
      String msg = str;
      if (e instanceof ParseErr) msg += ": " + ((ParseErr)e).msg();
      throw ParseErr.make("Unit:" + msg);
    }

    // register
    synchronized (byId)
    {
      // check that none of the units are defined
      for (int i=0; i<unit.ids.size(); ++i)
      {
        String id = (String)unit.ids.get(i);
        if (byId.get(id) != null) throw Err.make("Unit id already defined: " + id);
      }

      // this is a new definition
      for (int i=0; i<unit.ids.size(); ++i)
      {
        String id = (String)unit.ids.get(i);
        byId.put(id, unit);
      }
      list.add(unit);
    }

    return unit;
  }

  /**
   * Parse an un-interned unit:
   *   unit := <ids> [";" <dim> [";" <scale> [";" <offset>]]]
   */
  private static Unit parseUnit(String s)
  {
    String idStrs = s;
    int c = s.indexOf(';');
    if (c > 0) idStrs = s.substring(0, c);
    List ids = FanStr.split(idStrs, Long.valueOf(','));
    if (c < 0) return new Unit(ids, dimensionless, 1, 0);

    String dim = s = s.substring(c+1).trim();
    c = s.indexOf(';');
    if (c < 0) return new Unit(ids, parseDim(dim), 1, 0);

    dim = s.substring(0, c).trim();
    String scale = s = s.substring(c+1).trim();
    c = s.indexOf(';');
    if (c < 0) return new Unit(ids, parseDim(dim), Double.parseDouble(scale), 0);

    scale = s.substring(0, c).trim();
    String offset = s.substring(c+1).trim();
    return new Unit(ids, parseDim(dim), Double.parseDouble(scale), Double.parseDouble(offset));
  }

  /**
   * Parse an dimension string and intern it:
   *   dim    := <ratio> ["*" <ratio>]*
   *   ratio  := <base> <exp>
   *   base   := "kg" | "m" | "sec" | "K" | "A" | "mol" | "cd"
   */
  private static Dimension parseDim(String s)
  {
    // handle empty string as dimensionless
    if (s.length() == 0) return dimensionless;

    // parse dimension
    Dimension dim = new Dimension();
    List ratios = FanStr.split(s, (long)'*', true);
    for (int i=0; i<ratios.size(); ++i)
    {
      String r = (String)ratios.get(i);
      if (r.startsWith("kg"))  { dim.kg  = Byte.parseByte(r.substring(2).trim()); continue; }
      if (r.startsWith("sec")) { dim.sec = Byte.parseByte(r.substring(3).trim()); continue; }
      if (r.startsWith("mol")) { dim.mol = Byte.parseByte(r.substring(3).trim()); continue; }
      if (r.startsWith("m"))   { dim.m   = Byte.parseByte(r.substring(1).trim()); continue; }
      if (r.startsWith("K"))   { dim.K   = Byte.parseByte(r.substring(1).trim()); continue; }
      if (r.startsWith("A"))   { dim.A   = Byte.parseByte(r.substring(1).trim()); continue; }
      if (r.startsWith("cd"))  { dim.cd  = Byte.parseByte(r.substring(2).trim()); continue; }
      throw ParseErr.make("Bad ratio '" + r + "'");
    }

    // intern
    return dim.intern();
  }

  /**
   * Private constructor.
   */
  private Unit(List ids, Dimension dim, double scale, double offset)
  {
    this.ids    = checkIds(ids);
    this.dim    = dim;
    this.scale  = scale;
    this.offset = offset;
  }

  static List checkIds(List ids)
  {
    if (ids.size() == 0) throw ParseErr.make("No unit ids defined");
    for (int i=0; i<ids.size(); ++i) checkId((String)ids.get(i));
    return (List)ids.toImmutable();
  }

  static void checkId(String id)
  {
    if (id.length() == 0) throw ParseErr.make("Invalid unit id length 0");
    for (int i=0; i<id.length(); ++i)
    {
      int c = id.charAt(i);
      if (FanInt.isAlpha(c) || c == '_' || c == '%' || c == '/' || c == '$' || c > 128) continue;
      throw ParseErr.make("Invalid unit id " + id + " (invalid char '" + (char)c + "')");
    }
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public final boolean equals(Object obj) { return this == obj; }

  public final int hashCode() { return toStr().hashCode(); }

  public final long hash() { return FanObj.hash(toStr()); }

  private static Type type = null;
  public final Type typeof() { if (type == null) { type = Sys.findType("util::Unit"); } return type; }

  public final String toStr() { return (String)ids.last(); }

  public final List ids() { return ids; }

  public final String name() { return (String)ids.first(); }

  public final String symbol() { return (String)ids.last(); }

  public final double scale() { return scale; }

  public final double offset() { return offset; }

  public final String definition()
  {
    StringBuilder s = new StringBuilder();
    for (int i=0; i<ids.size(); ++i)
    {
      if (i > 0) s.append(", ");
      s.append(ids.get(i));
    }
    if (dim != dimensionless)
    {
      s.append("; ").append(dim);
      if (scale != 1.0 || offset != 0.0)
      {
        s.append("; ").append(scale);
        if (offset != 0.0) s.append("; ").append(offset);
      }
    }
    return s.toString();
  }

//////////////////////////////////////////////////////////////////////////
// Dimension
//////////////////////////////////////////////////////////////////////////

  public final long kg() { return dim.kg; }

  public final long m() { return dim.m; }

  public final long sec() { return dim.sec; }

  public final long K() { return dim.K; }

  public final long A() { return dim.A; }

  public final long mol() { return dim.mol; }

  public final long cd() { return dim.cd; }

  public final String dim() { return dim.toString(); }

  static class Dimension
  {
    public int hashCode()
    {
      return (kg << 28) ^ (m << 23) ^ (sec << 18) ^
             (K << 13) ^ (A << 8) ^ (mol << 3) ^ cd;
    }

    public boolean equals(Object o)
    {
      Dimension x = (Dimension)o;
      return kg == x.kg && m   == x.m   && sec == x.sec && K == x.K &&
             A  == x.A  && mol == x.mol && cd  == x.cd;
    }

    public String toString()
    {
      if (str == null)
      {
        StringBuilder s = new StringBuilder();
        append(s, "kg",  kg);  append(s, "m",   m);
        append(s, "sec", sec); append(s, "K",   K);
        append(s, "A",   A);   append(s, "mol", mol);
        append(s, "cd",  cd);
        str = s.toString();
      }
      return str;
    }

    private void append(StringBuilder s, String key, int val)
    {
      if (val == 0) return;
      if (s.length() > 0) s.append('*');
      s.append(key).append(val);
    }

    public Dimension add(Dimension b)
    {
      Dimension r = new Dimension();
      r.kg  = (byte)(kg  + b.kg);
      r.m   = (byte)(m   + b.m);
      r.sec = (byte)(sec + b.sec);
      r.K   = (byte)(K   + b.K);
      r.A   = (byte)(A   + b.A);
      r.mol = (byte)(mol + b.mol);
      r.cd  = (byte)(cd  + b.cd);
      return r;
    }

    public Dimension subtract(Dimension b)
    {
      Dimension r = new Dimension();
      r.kg  = (byte)(kg  - b.kg);
      r.m   = (byte)(m   - b.m);
      r.sec = (byte)(sec - b.sec);
      r.K   = (byte)(K   - b.K);
      r.A   = (byte)(A   - b.A);
      r.mol = (byte)(mol - b.mol);
      r.cd  = (byte)(cd  - b.cd);
      return r;
    }

    public Dimension intern()
    {
      // intern
      synchronized (dims)
      {
        Dimension cached = (Dimension)dims.get(this);
        if (cached != null) return cached;
        dims.put(this, this);
        return this;
      }
    }

    public boolean isDimensionless()
    {
      return toString().length() == 0;
    }

    String str;
    byte kg, m, sec, K, A, mol, cd;
  }

//////////////////////////////////////////////////////////////////////////
// Arithmetic
//////////////////////////////////////////////////////////////////////////

  public final Unit mult(Unit b)
  {
    synchronized (combos)
    {
      Combo key = new Combo(this, "*", b);
      Unit r = (Unit)combos.get(key);
      if (r == null)
      {
        r = findMult(this, b);
        combos.put(key, r);
      }
      return r;
    }
  }

  private static Unit findMult(Unit a, Unit b)
  {
    // if either is dimensionless give up immediately
    if (a.dim.isDimensionless() || b.dim.isDimensionless())
      throw Err.make("Cannot compute dimensionless: " + a + " * " + b);

    // compute dim/scale of a * b
    Dimension dim = a.dim.add(b.dim).intern();
    double scale = a.scale * b.scale;

    // find all the matches
    Unit[] matches = match(dim, scale);
    if (matches.length == 1) return matches[0];

    // right how our technique for resolving multiple matches is lame
    String expectedName = a.name() + "_" + b.name();
    for (int i=0; i<matches.length; ++i)
      if (matches[i].name().equals(expectedName))
        return matches[i];

    // for now just give up
    throw Err.make("Cannot match to db: " + a + " * " + b);
  }

  public final Unit div(Unit b)
  {
    synchronized (combos)
    {
      Combo key = new Combo(this, "/", b);
      Unit r = (Unit)combos.get(key);
      if (r == null)
      {
        r = findDiv(this, b);
        combos.put(key, r);
      }
      return r;
    }
  }

  public final Unit findDiv(Unit a, Unit b)
  {
    // if either is dimensionless give up immediately
    if (a.dim.isDimensionless() || b.dim.isDimensionless())
      throw Err.make("Cannot compute dimensionless: " + a + " / " + b);

    // compute dim/scale of a / b
    Dimension dim = a.dim.subtract(b.dim).intern();
    double scale = a.scale / b.scale;

    // find all the matches
    Unit[] matches = match(dim, scale);
    if (matches.length == 1) return matches[0];

    // right how our technique for resolving multiple matches is lame
    String expectedName = a.name() + "_per_" + b.name();
    for (int i=0; i<matches.length; ++i)
      if (matches[i].name().contains(expectedName))
        return matches[i];

    // for now just give up
    throw Err.make("Cannot match to db: " + a + " / " + b);
  }

  private static Unit[] match(Dimension dim, double scale)
  {
    ArrayList acc = new ArrayList();
    synchronized (list)
    {
      for (int i=0; i<list.size(); ++i)
      {
        Unit x = (Unit)list.get(i);
        if (x.dim == dim && approx(x.scale, scale))
          acc.add(x);
      }
    }
    return (Unit[])acc.toArray(new Unit[acc.size()]);
  }

  private static boolean approx(double a, double b)
  {
    // pretty loose with our approximation because the database
    // doesn't have super great resolution for some normalizations
    if (a == b) return true;
    double t = Math.min( Math.abs(a/1e3), Math.abs(b/1e3) );
    return Math.abs(a - b) <= t;
  }

  static class Combo
  {
    Combo(Unit a, String op, Unit b) { this.a  = a; this.op = op; this.b  = b; }
    public int hashCode() { return a.hashCode() ^ op.hashCode() ^ (b.hashCode() << 13); }
    public boolean equals(Object that) { Combo x = (Combo)that; return a == x.a && op == x.op && b == x.b; }
    final Unit a;
    final String op;
    final Unit b;
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  public final double convertTo(double scalar, Unit to)
  {
    if (dim != to.dim) throw Err.make("Incovertable units: " + this + " and " + to);
    return ((scalar * this.scale + this.offset) - to.offset) / to.scale;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private static final List list = List.make(16);//(Sys.UnitType);
  private static final HashMap byId = new HashMap(); // String id-> Unit
  private static final HashMap dims = new HashMap(); // Dimension -> Dimension
  private static final HashMap quantities = new HashMap(); // String -> List
  private static final HashMap combos = new HashMap();  // Combo -> Unit
  private static final List quantityNames;
  private static final Dimension dimensionless = new Dimension();
  static
  {
    dims.put(dimensionless, dimensionless);
    quantityNames = loadDatabase();
  }

  private final List ids;
  private final double scale;
  private final double offset;
  private final Dimension dim;

}