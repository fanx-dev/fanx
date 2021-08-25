//
// Copyright (c) 2018, chunquedong
// Licensed under the LGPL
// History:
//   2017-08-12  Jed Young  Creation
//
@NoDoc
class Act {
  Str say(Str str) {
    return str+"2"
  }
}

class ActorProxyTest : Test
{
  static const ActorLocal<Str> local := ActorLocal<Str>(|->Str|{ "Hi" })

  Void testProxy() {
    a := ActorProxy(|->Obj|{ Act() })
    r := a->say("x")->get
    verifyEq(r, "x2")
  }

  Void testLocal() {
    verifyEq(local.get, "Hi")
  }
}


