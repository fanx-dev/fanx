#! /usr/bin/env fansubstitute
//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

using build

**
** Build: compiler
**
class Build : BuildPod
{
  new make()
  {
    podName    = "compiler"
    summary    = "Fantom compiler"
    meta       = ["org.name":     "Fantom",
                  "org.uri":      "http://fantom.org/",
                  "proj.name":    "Fantom Core",
                  "proj.uri":     "http://fantom.org/",
                  "license.name": "Academic Free License 3.0",
                  "vcs.name":     "Mercurial",
                  "vcs.uri":      "https://bitbucket.org/fantom/fan-1.0/"]
    depends    = ["sys 1.0"]
    srcDirs    = [`fan/`,
                  `fan/assembler/`,
                  `fan/ast/`,
                  `fan/dsl/`,
                  `fan/fcode/`,
                  `fan/namespace/`,
                  `fan/parser/`,
                  `fan/steps/`,
                  `fan/util/`]
    docSrc     = true
    dependsDir = devHomeDir.uri + `lib/fan/`
    outPodDir  = devHomeDir.uri + `lib/fan/`
    index =
    [
      // DSL plugins
      "compiler.dsl.std::Regex": "compiler::RegexDslPlugin",
      "compiler.dsl.sys::Str": "compiler::StrDslPlugin"
    ]
  }
}