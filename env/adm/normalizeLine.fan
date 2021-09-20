#! /usr/bin/env fan

class NormalizeLine {
  static Void main(Str[] args) {
    file := File.os(args.first)
    file.walk |f| {
      //echo("walk:$f")
      if (f.isDir == false && f.ext == "sh") {
        converFile(f)
      }
      if (f.name == ".DS_Store") f.delete
    }
  }

  private static Void converFile(File file) {
    echo(file)
    lines := file.readAllLines
    out := file.out
    lines.each |line| { out.print(line+"\n") }
    out.close
  }
}