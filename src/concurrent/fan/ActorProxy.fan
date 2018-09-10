//
// Copyright (c) 2018, chunquedong
// Licensed under the LGPL
// History:
//   2017-08-12  Jed Young  Creation
//

internal class ActorProxyObj {
  Obj? val
}

const class ActorProxy : Actor {
  private const Unsafe<ActorProxyObj> base
  private const |->Obj| builder

  new make(|->Obj| builder, ActorPool pool := ActorPool.defVal) : super(pool) {
    this.builder = builder
    this.base = Unsafe(ActorProxyObj())
  }

  private Obj get() {
    obj := base.val
    if (obj.val == null) {
      obj.val = builder()
    }
    return obj.val
  }

  protected override Obj? receive(Obj? msg) {
    try {
      Obj?[]? arg := msg
      Str name := arg[0]
      Obj?[]? args := arg[1]

      //log.debug("receive $msg")

      return get.trap(name, args)
    } catch (Err e) {
      e.trace
      throw e
    }
  }

  override Obj? trap(Str name, Obj?[]? args := null) {
    method := name
    return this.send([method, args].toImmutable)
  }
}