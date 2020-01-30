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
    podName    = "parser"
    summary    = "Fantom code parser for compiler and IDE"
    depends    = ["sys 1.0"]
    srcDirs    = [`fan/`,
                  `fan/lexer/`,
                  `fan/ast/`,
                  `fan/parser/`,
                  `fan/util/`,
                  `fan/semantic/`,
                  `test/`]
    docSrc     = true
  }
}