//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Jul 10  Andy Frank  Creation
//

**
** JsUnitDatabase
**
class JsUnitDatabase
{
  Void write(OutStream out)
  {
    // open etc/sys/units.txt
    file := Env.cur.findFile(`etc/sys/units.txt`, false)
    if (file == null) return
    in := file.in
    out.printLine(
      "(function () {
       ${JsPod.requireSys}
       ")


    // parse each line
    curQuantityName := ""
    in.readAllLines.each |line|
    {
      // skip comment and blank lines
      line = line.trim
      if (line.startsWith("//") || line.size == 0) return

      // quanity sections delimited as "-- name (dim)"
      if (line.startsWith("--"))
      {
        name := line[2..<line.index("(")].trim
        if (name != curQuantityName)
        {
          // close off last def
          if (curQuantityName.size > 0)
          {
            out.printLine("}")
            writeImmutable(out, curQuantityName)
          }

          // start new def
          curQuantityName = name
          out.printLine(
            "// $curQuantityName
             fan.sys.Unit.m_quantityNames.add('$curQuantityName');
             with (fan.sys.Unit.m_quantities['$curQuantityName'] = fan.sys.List.make(fan.sys.Unit.\$type))
             {")
        }
        return
      }

      // add unit
      out.printLine(" add(fan.sys.Unit.define('$line'));")
    }

    // finish up
    out.printLine("}")
    writeImmutable(out, curQuantityName)
    out.printLine("fan.sys.Unit.m_quantityNames = fan.sys.Unit.m_quantityNames.toImmutable();")
    out.printLine("}).call(this);")
  }

  private Void writeImmutable(OutStream out, Str quantityName)
  {
    out.printLine("fan.sys.Unit.m_quantities['$quantityName'] = " +
                  "fan.sys.Unit.m_quantities['$quantityName'].toImmutable();")
  }
}

