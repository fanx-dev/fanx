class Test
{
  Str:Obj bindings := [
    "print": |Obj[] args|
    {
      args.each |arg| { result += arg.toStr + "," }
    }
  ]
  Str result := ""
}