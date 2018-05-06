//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//

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

//////////////////////////////////////////////////////////////////////////
// Registry
//////////////////////////////////////////////////////////////////////////

  **
  ** List all the installed services.
  **
  static Service[] list()

  **
  ** Find an installed service by type.  If not found and checked
  ** is false return null, otherwise throw UnknownServiceErr.  If
  ** multiple services are registered for the given type then return
  ** the first one registered.
  **
  static Service? find(Type t, Bool checked := true)

  **
  ** Find all services installed for the given type.  If no
  ** services are found then return an empty list.
  **
  static Service[] findAll(Type t)

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Services are required to implement equality by reference.
  **
  final override Bool equals(Obj? that)

  **
  ** Services are required to implement equality by reference.
  **
  final override Int hash()

  **
  ** Is the service in the installed state.
  ** Note this method requires accessing a global hash table, so
  ** it should not be heavily polled in a concurrent environment.
  **
  Bool isInstalled()

  **
  ** Is the service in the running state.
  ** Note this method requires accessing a global hash table, so
  ** it should not be heavily polled in a concurrent environment.
  **
  Bool isRunning()

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  **
  ** Install this service into the VM's service registry.
  ** If already installed, do nothing.  Return this.
  **
  This install()

  **
  ** Start this service.  If not installed, this method
  ** autoamatically calls `install`.  If already running,
  ** do nothing.  Return this.
  **
  This start()

  **
  ** Stop this service.  If not running, do nothing.
  ** Return this.
  **
  This stop()

  **
  ** Uninstall this service from the VM's service registry.
  ** If the service is running, this method automatically
  ** calls `stop`.  If not installed, do nothing.  Return this.
  **
  This uninstall()

  **
  ** Callback when service transitions into running state.
  ** If this callback raises an exception, then the service fails
  ** to transition to the running state.
  **
  protected virtual Void onStart()

  **
  ** Callback when service transitions out of the running state.
  ** If this callback raises an exception, then the service is still
  ** transitioned to the non-running state.
  **
  protected virtual Void onStop()

}