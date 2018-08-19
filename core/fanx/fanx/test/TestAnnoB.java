//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Sep 10  Brian Frank  Creation
//
package fanx.test;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
public @interface TestAnnoB
{
  String value();
}