//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 07  Brian Frank  Creation
//
package fan.std;

import java.util.regex.*;
import fan.sys.*;
import fanx.main.Sys;
import fanx.main.Type;

/**
 * RegexMatcher
 */
public final class RegexMatcher
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

  RegexMatcher(Matcher matcher)
  {
    this.matcher = matcher;
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////
  private static Type type;
  public Type typeof() { 
	  if (type == null) Sys.findType("std::RegexMatcher");
	  return type;
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  public final boolean matches()
  {
    return matcher.matches();
  }

  public final boolean find()
  {
    return matcher.find();
  }

  public final String replaceFirst(String replacement)
  {
    return matcher.replaceFirst(replacement);
  }

  public final String replaceAll(String replacement)
  {
    return matcher.replaceAll(replacement);
  }

  public final long groupCount()
  {
    return matcher.groupCount();
  }

  public final String group() { return group(0L); }
  public final String group(long group)
  {
    try
    {
      return matcher.group((int)group);
    }
    catch (IllegalStateException e)
    {
      throw Err.make(e.getMessage());
    }
    catch (IndexOutOfBoundsException e)
    {
      throw IndexErr.make(""+group);
    }
  }

  public final long start() { return start(0L); }
  public final long start(long group)
  {
    try
    {
      return matcher.start((int)group);
    }
    catch (IllegalStateException e)
    {
      throw Err.make(e.getMessage());
    }
    catch (IndexOutOfBoundsException e)
    {
      throw IndexErr.make(""+group);
    }
  }

  public final long end() { return end(0L); }
  public final long end(long group)
  {
    try
    {
      return (matcher.end((int)group));
    }
    catch (IllegalStateException e)
    {
      throw Err.make(e.getMessage());
    }
    catch (IndexOutOfBoundsException e)
    {
      throw IndexErr.make(""+group);
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Matcher matcher;
}