//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 May 10  Andy Frank  Creation
//

using compiler

**
** JsProps
**
class JsProps : JsNode
{
  new make(PodDef pod, File file, Uri uri, JsCompilerSupport s) : super(s)
  {
    this.pod  = pod
    this.file = file
    this.uri  = uri
  }

  override Void write(JsWriter out)
  {
    doWrite(pod.name, uri, file.in.readProps, out)
  }

  static Void writeProps(OutStream out, Pod pod, Uri uri, Duration maxAge)
  {
    props := Env.cur.props(pod, uri, maxAge)
    if (!props.isEmpty) doWrite(pod.name, uri, props, JsWriter(out))
  }

  private static Void doWrite(Str pod, Uri uri, Str:Str props, JsWriter out)
  {
    key := "$pod:$uri"
    out.w("with (fan.sys.Env.cur().\$props($key.toCode))").nl
    out.w("{").nl
    out.indent
    props.each |v,k| { out.w("set($k.toCode,$v.toCode);").nl }
    out.unindent
    out.w("}").nl
  }

  PodDef pod  // pod container
  File file   // props file
  Uri uri     // relative uri to prop file
}

