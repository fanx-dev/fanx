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
    podName = "std"
    summary = "system std lib"
    depends = ["sys 1.0"]
    outPodDir = devHomeDir.uri + `lib/fan/`
    srcDirs = [
          `fan/collection/`,
          `fan/io/`,
          `fan/time/`,
          `fan/util/`
           ]
  }
}