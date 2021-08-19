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
public @interface TestAnnoC
{
  boolean bool()    default false;
  int i()           default 0;
  long l()          default 0L;
  float f()         default 0f;
  double d()        default 0d;
  byte b()          default 0;
  short s()         default 0;

  String str1()     default "";
  String str2()     default "";
  String str3()     default "";

  ElementType enum1()  default ElementType.TYPE;
  Thread.State enum2() default Thread.State.NEW;

  Class cls1()      default Object.class;
  Class cls2()      default Object.class;

  boolean[] bools()     default {};
  int[] ints()          default {};
  long[] longs()        default {};
  float[] floats()      default {};
  double[] doubles()    default {};
  byte[] bytes()        default {};
  short[] shorts()      default {};
  String[] strs()       default {};
  ElementType[] enums() default {};
  Class[] classes()     default {};
}