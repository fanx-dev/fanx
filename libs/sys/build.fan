#! /usr/bin/env fan
//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2011-4-3  Jed Young  Creation
//

using build

class Build : BuildPod
{
  new make()
  {
    podName = "sys"
    summary = "system core lib"
    depends = [,]
    outPodDir = devHomeDir.uri + `lib/fan/`
    srcDirs = [`fan/native/`, `fan/lang/`]
  }
}