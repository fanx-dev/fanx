class Foo
 {
    [Str:Obj]? map1
     Obj? foo() { [Str:Obj?]["a":"b"] }
     Obj? bar()
     {
       map2 := map1 ?: [Str:Obj?][:]
       map3 := foo
       map2.setAll(map3)
       return map2
    }
 }