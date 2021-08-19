//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//

internal class ServiceMgr {
  private Service[] services := [,]
  private [Service:Int] stateMap := [:]
  private [Str:Service[]] byName := [:]
  private Lock lock := Lock()

  Service[] list() {
    res := Service[,]
    lock.sync|->Obj?|{
      services.each |v| {
        res.add(v)
      }
      return null
    }
    return res
  }

  Service? find(Type t, Bool checked := true) {
    qname := t.qname
    res := lock.sync|->Obj?|{
      return byName[qname]?.first
    }
    if (res == null && checked) throw UnknownServiceErr(qname)
    return res
  }

  Service[] findAll(Type t) {
    qname := t.qname
    Service[]? res := lock.sync|->Obj?|{
      return byName.get(qname)
    }
    if (res == null) return List.defVal
    return res.ro
  }

  Int getState(Service s) {
    lock.sync|->Obj?|{
      return stateMap.get(s, -1)
    }
  }

  Void setState(Service s, Int state) {
    lock.sync|->Obj?|{
      if (!stateMap.containsKey(s)) return null
      stateMap[s] = state
      return null
    }
  }

  Void add(Service s) {
    lock.sync|->Obj?|{
      if (stateMap.containsKey(s)) return null

      lst := byName[s.typeof.qname]
      if (lst == null) {
        lst = [s]
        byName[s.typeof.qname] = lst
      } else {
        lst.add(s)
      }

      services.add(s)
      stateMap[s] = 0
      return null
    }
  }

  Void remove(Service s) {
    lock.sync|->Obj?| {
      services.remove(s)
      stateMap.remove(s)
      lst := byName[s.typeof.qname]
      if (lst != null) lst.remove(s)
      return null
    }
  }
}

**
** Services are used to publish functionality in a VM for use by
** other software components.  The service registry for the VM is
** keyed by public types each service implements.
**
** The following table illustrates the service lifecycle:
**
**   Method        isInstalled  isRunning
**   -----------   -----------  ----------
**   constructed   false        false
**   install       true         false
**   start         true         true
**   stop          true         false
**   uninstall     false        false
**
** While the service is installed, it may be looked up in the
** registry via `find` and `findAll`.  The running state is used
** to invoke the `onStart` and `onStop` callbacks which gives
** the service a chance to setup/shutdown its actors and associated
** resources.
**
const mixin Service
{
  private static const Unsafe<ServiceMgr> serviceMgr := Unsafe(ServiceMgr())

//////////////////////////////////////////////////////////////////////////
// Registry
//////////////////////////////////////////////////////////////////////////

  **
  ** List all the installed services.
  **
  static Service[] list() { serviceMgr.val.list }

  **
  ** Find an installed service by type.  If not found and checked
  ** is false return null, otherwise throw UnknownServiceErr.  If
  ** multiple services are registered for the given type then return
  ** the first one registered.
  **
  static Service? find(Type t, Bool checked := true) { serviceMgr.val.find(t, checked) }

  **
  ** Find all services installed for the given type.  If no
  ** services are found then return an empty list.
  **
  static Service[] findAll(Type t) { serviceMgr.val.findAll(t) }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Services are required to implement equality by reference.
  **
  final override Bool equals(Obj? that) { this === that }

  **
  ** Services are required to implement equality by reference.
  **
  final override Int hash() { Env.cur.idHash(this) }

  **
  ** Is the service in the installed state.
  ** Note this method requires accessing a global hash table, so
  ** it should not be heavily polled in a concurrent environment.
  **
  Bool isInstalled() { serviceMgr.val.getState(this) != -1 }

  **
  ** Is the service in the running state.
  ** Note this method requires accessing a global hash table, so
  ** it should not be heavily polled in a concurrent environment.
  **
  Bool isRunning() { serviceMgr.val.getState(this) == 1 }

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  **
  ** Install this service into the VM's service registry.
  ** If already installed, do nothing.  Return this.
  **
  This install() { serviceMgr.val.add(this); return this }

  **
  ** Start this service.  If not installed, this method
  ** autoamatically calls `install`.  If already running,
  ** do nothing.  Return this.
  **
  This start() {
    install
    serviceMgr.val.setState(this, 1)
    onStart
    return this
  }

  **
  ** Stop this service.  If not running, do nothing.
  ** Return this.
  **
  This stop() { serviceMgr.val.setState(this, 0); onStop; return this }

  **
  ** Uninstall this service from the VM's service registry.
  ** If the service is running, this method automatically
  ** calls `stop`.  If not installed, do nothing.  Return this.
  **
  This uninstall() { serviceMgr.val.remove(this); return this }

  **
  ** Callback when service transitions into running state.
  ** If this callback raises an exception, then the service fails
  ** to transition to the running state.
  **
  protected virtual Void onStart() {}

  **
  ** Callback when service transitions out of the running state.
  ** If this callback raises an exception, then the service is still
  ** transitioned to the non-running state.
  **
  protected virtual Void onStop() {}

}