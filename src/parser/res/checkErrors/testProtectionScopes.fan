class Public
{
  virtual public    Void mPublic()    {}
  virtual protected Void mProtected() {}
  virtual internal  Void mInternal()  {}
          private   Void mPrivate()   {} // can't mix virtual+private

  static public    Void msPublic()    {}
  static protected Void msProtected() {}
  static internal  Void msInternal()  {}
  static private   Void msPrivate()   {}

  virtual public    Int fPublic
  virtual protected Int fProtected
  virtual internal  Int fInternal
          private   Int fPrivate   // can't mix virtual+private

  public            Int fPublicProtected { protected set }
  public            Int fPublicReadonly { private set }
  protected         Int fProtectedInternal { internal set }
}

virtual internal class InternalClass
{
  Void m() {}
}

internal mixin InternalMixin
{
  static Void x() { Public.msPublic; Public.msProtected; Public.msInternal }
}