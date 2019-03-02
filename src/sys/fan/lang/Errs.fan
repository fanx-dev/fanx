//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Jun 06  Brian Frank  Creation
//

**
** ArgErr indicates an invalid argument was passed.
**
const class ArgErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}

**
** CancelledErr indicates that an operation was cancelled
** before it complete normally.
**
const class CancelledErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** CastErr is a runtime exception raised when invalid cast is performed.
**
const class CastErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** ConstErr indicates an attempt to set a const field after
** the object has been constructed.
**
const class ConstErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** FieldNotSetErr indicates a non-nullable field was not
** set by the constructor it-block.
**
const class FieldNotSetErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** IndexErr indicates an attempt to access an invalid index in a List.
**
const class IndexErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** InterruptedErr indicates that a thread is interrupted from
** its normal execution.
**
const class InterruptedErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** IOErr indicates an input/output error typically associated
** with a file system or socket.
**
const virtual class IOErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** NameErr indicates an attempt use an invalid name.
** See `Uri.isName` and `Uri.checkName`.
**
const class NameErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** NotImmutableErr indicates using a mutable Obj where an immutable Obj is
** required.  See Obj.isImmutable for the definition of immutability.
**
const class NotImmutableErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** NullErr is a runtime exception raised when using a null reference
** or when null is passed for a method argument which must be non-null.
**
const class NullErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

  @NoDoc
  static NullErr makeCoerce() { make("Coerce to non-null") }
}


**
** ParseErr indicates an invalid string format which cannot be parsed.
** It is often used with 'fromStr' and 'fromLocale' methods.
**
virtual const class ParseErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** ReadonlyErr indicates an attempt to modify a readonly instance;
** it is commonly used with List and Map.
**
const class ReadonlyErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnknownFacetErr indicates an attempt to access a undefined facet.
**
const class UnknownFacetErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnknownKeyErr indicates an attempt lookup non-existent key.
**
const class UnknownKeyErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnknownPodErr indicates an attempt to access a non-existent pod.
**
const class UnknownPodErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnknownServiceErr indicates an attempt to lookup an service
** not installed.  See `Service.find`.
**
const class UnknownServiceErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnknownSlotErr indicates an attempt to access a non-existent slot.
**
const class UnknownSlotErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnknownTypeErr indicates an attempt to access a non-existent type.
**
const class UnknownTypeErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnresolvedErr indicates the failure to resolve a Uri to a resource.
**
const class UnresolvedErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}


**
** UnsupportedErr indicates a feature which isn't supported.
**
const class UnsupportedErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null) : super(msg, cause) {
  }

}

**
** TimeoutErr indicates that a blocking operation
** timed out before normal completion.
**
const class TimeoutErr : Err
{

  **
  ** Construct with specified error message and optional root cause.
  **
  new make(Str msg := "", Err? cause := null): super(msg, cause) {
  }

}

const class AssertErr : Err
{
  new make(Str msg := "", Err? cause := null): super(msg, cause) {
  }
}

