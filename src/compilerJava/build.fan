#! /usr/bin/env fan
//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Nov 08  Brian Frank  Creation
//

using build

**
** Build: compilerJava
**
class Build : BuildPod
{
  new make()
  {
    podName    = "compilerJava"
    summary    = "Compiler FFI Plugin for Java"
    meta       = ["org.name":     "Fantom",
                  "org.uri":      "http://fantom.org/",
                  "proj.name":    "Fantom Core",
                  "proj.uri":     "http://fantom.org/",
                  "license.name": "Academic Free License 3.0",
                  "vcs.name":     "Mercurial",
                  "vcs.uri":      "https://bitbucket.org/fantom/fan-1.0/"]
    depends    = ["sys 1.0", "compiler 1.0"]
    srcDirs    = [`fan/`, `fan/dasm/`, `fan/cp/`]
    docSrc     = true
    dependsDir = devHomeDir.uri + `lib/fan/`
    outPodDir  = devHomeDir.uri + `lib/fan/`
    index      = ["compiler.bridge.java": "compilerJava::JavaBridge"]
  }
}