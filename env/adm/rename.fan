#! /usr/bin/env fan

class FileReplace
{

  Void replace(File f, Str from, Str to)
  {
    s := f.readAllStr(true)
    changed := false
    Int? pos := 0
    while (true) {
      pos = s.index(from, pos)
      if (pos == null) break
      end := pos + from.size
      if (s[end].isAlphaNum) {
        pos = end
        continue
      }
      if (pos > 0 && s[pos-1].isAlphaNum) {
        pos = end
        continue
      }
      s = s[0..<pos] + to + s[end..-1]
      pos = pos + to.size
      changed = true
    }

    if (!changed) {
      return
    }

    echo("  Replace $f")
    f.out.print(s).close
  }

  Void main(Str[] args)
  {
    if (args.size < 4)
    {
      echo("usage: filereplace <from> <to> <dir> <ext>")
      return
    }
    from := args[0]
    to   := args[1]
    dir  := File.os(args[2])
    ext  := args[3]
    if (from.size == 0) {
      echo("from is empty")
      return
    }
    dir.walk |File f| { if (f.ext == ext) replace(f, from, to) }
  }

}