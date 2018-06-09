//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   03 Nov 07  Brian Frank  Creation
//

//using concurrent

**
** LocaleTest
**
@Js
class LocaleTest : Test
{
  Locale? orig

  override Void setup()
  {
    orig = Locale.cur
  }

  override Void teardown()
  {
    Locale.setCur(orig)
  }

  Void testEnStaticField()
  {
    verifyEq(Locale.en, Locale.fromStr("en"))
  }

  Void testIdentity()
  {
    verifyLocale("en",    "en", null)
    verifyLocale("en-US", "en", "US")
    verifyLocale("fr",    "fr", null)
    verifyLocale("fr-CA", "fr", "CA")

    verifyEq(Locale.fromStr("", false), null)
    verifyErr(ParseErr#) { x := Locale.fromStr("x") }
    verifyErr(ParseErr#) { x := Locale.fromStr("x", true) }
    verifyErr(ParseErr#) { x := Locale.fromStr("e2") }
    verifyErr(ParseErr#) { x := Locale.fromStr("en_US") }
    verifyErr(ParseErr#) { x := Locale.fromStr("en-x") }
    verifyErr(ParseErr#) { x := Locale.fromStr("en-x2") }
    verifyErr(ParseErr#) { x := Locale.fromStr("en-xxx") }
    verifyErr(ParseErr#) { x := Locale.fromStr("EN") }
    verifyErr(ParseErr#) { x := Locale.fromStr("EN-US") }
    verifyErr(ParseErr#) { x := Locale.fromStr("en-us") }
  }

  Void verifyLocale(Str str, Str lang, Str? country)
  {
    locale := Locale.fromStr(str)
    verifyEq(locale.lang,    lang)
    verifyEq(locale.country, country)
    verifyEq(locale.toStr,   str)
    verifyEq(locale.hash,    str.hash)
    verifyEq(locale,         Locale.fromStr(str))
  }

  Void testCurrent()
  {
    // change to France
    fr := Locale.fromStr("fr-FR")
    Locale.setCur(fr)
    verifyEq(Locale.cur.toStr, "fr-FR")

    // change to Taiwan
    zh := Locale.fromStr("zh-TW")
    Locale.setCur(zh)
    verifyEq(Locale.cur.toStr, "zh-TW")

    // can't set to null
    //verifyErr(NullErr#) { Locale.setCurrent(null) }

    // check with closure which throws exception
    try
    {
      fr.use
      {
        verifyEq(Locale.cur.toStr, "fr-FR")
        throw Err.make
      }
    }
    catch
    {
    }
    verifyEq(Locale.cur.toStr, "zh-TW")

    /*
    // actors not supported in javascript
    if (Env.cur.runtime == "js") return

    // create actor that accepts
    // messages to change its own locale
    actor := Actor(ActorPool()) |Obj msg->Obj|
    {
      if (msg == ".")  return Locale.cur
      loc := Locale.fromStr(msg)
      Locale.setCur(loc)
      return Locale.cur
    }

    // check that changes on other thread don't effect my thread
    verifyEq(actor.send(".").get, Locale("zh-TW"))
    verifyEq(actor.send("fr-FR").get, fr)
    verifyEq(Locale.cur.toStr, "zh-TW")
    verifyEq(actor.send("de").get, Locale("de"))
    verifyEq(Locale.cur.toStr, "zh-TW")
    */
  }

}