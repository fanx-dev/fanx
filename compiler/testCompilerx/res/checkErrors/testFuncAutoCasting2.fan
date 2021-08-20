class Foo
{
   static Num a(|Num a, Num b->Num| f) { return f(3, 4) }
   // diff return types
   static Int a05() { return a |Num a, Num b->Str| { return a.toStr  } }
   // wrong arity
   static Int a07() { return a |Num a, Num b, Num c->Num| { return a.toInt  } }
   // wrong params
   static Int a09() { return a |Str a, Num b, Num c->Num| { return a.toInt  } }
   static Int a10() { return a |Num a, Str? b, Num c->Num| { return a.toInt  } }
   static Int a11() { return a |Str a, Str b, Str c->Num| { return a.toInt  } }

   static Void b(| |Num[] x| y |? f) {}
   // diff return types
   static Void b15() { b | |Num[] x| y | {}  }        // ok
   static Void b16() { b | |Int[] x| y | {}  }        // ok
   static Void b17() { b | |Obj[] x| y | {}  }        // ok
   static Void b18() { b | |Num[] x->Str| y | {}  }   // ok
   static Void b19() { b | |Str[] x| y | {}  }        // wrong params
   static Void b20() { b | |Num[] x| y, Obj o| {}  } // wrong arity
}