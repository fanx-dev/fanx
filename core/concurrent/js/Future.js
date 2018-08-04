//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Mar 10  Andy Frank  Creation
//   13 May 10  Andy Frank  Move from sys to concurrent
//

/**
 * Future.
 */
fan.concurrent.Future = fan.sys.Obj.$extend(fan.sys.Obj);

fan.concurrent.Future.prototype.$ctor = function() {}
fan.concurrent.Future.prototype.$typeof = function() { return fan.concurrent.Future.$type; }

