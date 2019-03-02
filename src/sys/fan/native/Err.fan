//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Jan 06  Brian Frank  Creation
//

**
** Err is the base class of all exceptions.
**
native virtual const class Err
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null)

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the string message passed to the contructor or empty
  ** string if a message is not available.
  **
  Str msg()

  **
  ** Get the underyling cause exception or null.
  **
  Err? cause()

  **
  ** Dump the stack trace of this exception to the specified
  ** output stream (or 'Env.cur.out' by default).  Return this.
  **
  ** The options may be used to specify the format of the output:
  **   - "maxDepth": Int specifies how many methods in each
  **        exception of chain to include.  If unspecified the
  **        default is configured from the "errTraceMaxDepth" prop
  **        in etc/sys/config.props.
  **
  //This trace(OutStream out := Env.cur.out, [Str:Obj]? options := null)
  This trace()

  **
  ** Dump the stack trace of this exception to a Str.
  **
  Str traceToStr()

  **
  ** Return the qualified type name and optional message.
  **
  override Str toStr()

}