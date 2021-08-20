abstract class Foo : Bar
{
// new Str f00 - parser actually catches this
final Int f01
native Int f02 // ok
once Int f03

public protected Int f04
public private Int f05
public internal Int f06
protected private Int f07
protected internal Int f08
internal private Int f09

Int f10 { public protected set {} }
Int f11 { public private  set {} }
Int f12 { public internal  set {} }
Int f13 { protected private  set {} }
Int f14 { protected internal  set {} }
Int f15 { internal private  set {} }

private Int f20 { public set {} }
private Int f21 { protected set {} }
private Int f22 { internal set {} }
internal Int f23 { public set {} }
internal Int f24 { protected set {} }
protected Int f25 { public set {} }
protected Int f26 { internal set {} } // ok

const abstract Int f30
//
const virtual  Int f32

virtual private Int f33

native abstract Int f35
const native Int f36
native static Int f37
}

virtual class Bar
{
virtual Int f31
}