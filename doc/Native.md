

## Native ##

Native classes, methods, and fields are used to implement Fantom in the native language of the runtime platform. For example a native method would be implemented in Java for the JVM, in C# for the CLR, and JavaScript for browsers. 

### Native Classes ###
A native class is one where the entire implementation is coded up in the native language. In general the native code must look exactly like what the compiler/runtime would emit.

A native class is indicated with the native keyword in the class header.
Native class is not support by FNI(fanrun runtime).

### Native Methods/Fields ###
Native methods are always routed to the peer:
```
// Fantom
class Foo
{
  native Str a(Bool x)
  static native Void b(Int x)
  native Str? f
}

// Java or C#
package fan.mypod;
class FooPeer
{
  public static FooPeer make(Foo self) { return new FooPeer(); }

  // instance methods always take implicit self
  public String a(Foo self, boolean x) { return "a"; }

  // static methods are just normal statics with matching signatures
  public static void b(long x) {}

  //field
  public String f(Foo t) { return f; }
  public void f(Foo t, String v) { f = v; }
  String f;
}

// JavaScript
fan.mypod.FooPeer.prototype.a = function(self, x) { return "a"; }
fan.mypod.FooPeer.b = function(x) {}

fan.mypod.FooPeer.prototype.m_f = "";
fan.mypod.FooPeer.prototype.f   = function(t) { return this.m_f; }
fan.mypod.FooPeer.prototype.f$  = function(t, v) { this.m_f = v; }


//FNI(fanrun runtime)
fr_Obj mypod_Foo_a(fr_Env env, frObj self, fr_Bool x) { return fr_newStrUtf8(env, "a"); }
void mypod_Foo_b(fr_Env env, fr_Int x) {}
fr_Obj mypod_Foo_f(fr_Env env, fr_Obj self) {...}
void mypod_Foo_f__(fr_Env env, fr_Obj self, fr_Obj v) {...}

```
All non-static methods and fields will pass the Fantom instance as an implicit first argument. This lets you use a singleton peer for all instances. Typically you will only allocate a peer instance if you wish to manage state on the peer.

### FNI ###
FNI just like JNI, Fanx supports write native code by C/C++.

Generate the C/C++ Header File:
```
vmgen -pD:/workspace/fanx-dev/fanx/env/ -gD:/workspace/fanx-dev/fanx/fanrun/fni/mypod/ mypod
```
