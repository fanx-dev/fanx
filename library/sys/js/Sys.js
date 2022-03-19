//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 May 09  Andy Frank  Creation
//

fan.sys.Sys = function(){}

fan.sys.Sys.findType = function(sig, checked) {
  if (checked === undefined) checked = true;
  var len = sig.length;
  var last = len > 1 ? sig.charAt(len-1) : 0;

  if (len < 1) {
    throw fan.sys.ArgErr(signature);
  }
  if (last == '?') {
    var t = fan.sys.Sys.findType(sig.substring(0, len-1), checked);
    if (t == null && !checked) return null;
    return t.toNullable();
  }

  var podName;
  var typeName;
  try
  {
    var colon = sig.indexOf("::");
    podName  = sig.substring(0, colon);
    typeName = sig.substring(colon+2);

    var pos = typeName.indexOf("<");
    if (pos >= 0) {
      typeName = typeName.substring(0, pos);
    }
    if (podName.length == 0 || typeName.length == 0) throw fan.sys.Err.make("");
  }
  catch (err)
  {
    throw fan.sys.ArgErr.make("Invalid type signature '" + sig + "', use <pod>::<type>");
  }
  return fan.sys.Sys.find(podName, typeName, checked);
}


fan.sys.Sys.find = function(podName, typeName, checked)
{
  if (typeName.indexOf('^') != -1) {
    return fan.sys.Sys.find("sys", "Obj", checked);
  }
  if (podName == "sys") {
    if (typeName == "Int8" || typeName == "Int16" ||
        typeName == "Int32"  || typeName == "Int64" ) {
      return fan.sys.Sys.find("sys", "Int", checked);
    }
    else if (typeName == "Float32"  || typeName == "Float64" ) {
      return fan.sys.Sys.find("sys", "Float", checked);
    }
  }
  var pod = fan.std.Pod.find(podName, checked);
  if (pod == null) return null;
  return pod.type(typeName, checked);
}

