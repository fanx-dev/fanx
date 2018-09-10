//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Oct 10  Brian Frank  Creation
//

**
** JsIndexedProps is used to support JavaScript implementation
** of `sys::Env.index`
**
class JsIndexedProps
{
  **
  ** Write out a stream of indexed props to be added to the
  ** JavaScript implementation of `sys::Env`.  If pods is null
  ** index every pod installed, otherwise just the pods specified.
  **
  Void write(OutStream out, Pod[]? pods := null)
  {
    if (pods == null) pods = Pod.list

    index := Str:Str[][:]
    pods.each |pod|
    {
      try
        addToIndex(pod, index)
      catch (Err e)
        echo("ERROR: JsIndexProps.write: $pod.name\n$e.traceToStr")
    }

    out.printLine(
      "(function() {
         ${JsPod.requireSys}
         var i = fan.sys.Map.make(fan.sys.Str.\$type, new fan.sys.ListType(fan.sys.Str.\$type));")

    index.each |vals, key|
    {
      v := vals.join(",") |v| { v.toCode }
      out.printLine("  i.set(\"$key\", fan.sys.List.make(fan.sys.Str.\$type, [$v]));")
    }

    out.printLine(
      "  fan.sys.Env.cur().\$setIndex(i);
       }).call(this);")
  }

  private Void addToIndex(Pod pod,  Str:Str[] index)
  {
    f := pod.file(`/index.props`, false)
    if (f == null) return


    f.in.readPropsListVals.each |v, n|
    {
      list := index[n]
      if (list == null) index[n] = list = Str[,]
      list.addAll(v)
    }
  }

  static Void main(Str[] args)
  {
    make.write(Env.cur.out)
  }
}


