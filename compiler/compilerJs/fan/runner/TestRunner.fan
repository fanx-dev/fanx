//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Dec 08  Andy Frank  Creation
//
/*
using [java] java.lang
using [java] javax.script

**
** TestRunner is the command line tool to run Fantom unit tests
** against their JavaScript implementations.
**
class TestRunner
{

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  Void main(Str[] args := Env.cur.args)
  {
    if (args.size != 1)
    {
      help
      return
    }

    // get args
    arg    := args.first
    pod    := arg
    type   := "*"
    method := "*"

    // check for type
    if (pod.contains("::"))
    {
      i := pod.index("::")
      type = pod[i+2..-1]
      pod  = pod[0..i-1]
    }

    // check for method
    if (type.contains("."))
    {
      i := type.index(".")
      method = type[i+1..-1]
      type   = type[0..i-1]
    }

    // create engine and eval pods
    p := Pod.find(pod)
    evalPod(p)

    // run tests
    t1 := Duration.now
    if (type != "*")
    {
      runTests(Type.find("$pod::$type"), method)
    }
    else if (pod != null)
    {
      p.types.each |t| { if (t.fits(Test#) && t.hasFacet(Js#)) runTests(t, "*") }
    }
    else throw Err("Pattern not supported: $arg")
    t2 := Duration.now

    echo("")
    echo("Time: ${(t2-t1).toMillis}ms")
    echo("")
    results
  }

  Void evalPod(Pod p)
  {
    if (engine == null) engine = ScriptEngineManager().getEngineByName("js");
    Runner.evalPodScript(engine, p)
    if (p.name == "testSys") evalTestSys(p)
  }

  private Void evalTestSys(Pod p)
  {
    try
    {
      if (p.name != "testSys") return
      buf := StrBuf()
      out := buf.out

      // index
      JsIndexedProps().write(out, [Pod.find("testSys")])

      // locales
      JsProps.writeProps(out, Pod.find("sys"), `locale/fi.props`, 1sec)
      JsProps.writeProps(out, Pod.find("sys"), `locale/fr.props`, 1sec)
      JsProps.writeProps(out, p, `locale/en-US.props`, 1sec)
      JsProps.writeProps(out, p, `locale/es.props`, 1sec)
      JsProps.writeProps(out, p, `locale/es-MX.props`, 1sec)

      // timezones
      out.printLine((Env.cur.homeDir + `etc/sys/tz.js`).readAllStr)

      // unit db
      JsUnitDatabase().write(out)

      engine.eval(buf.toStr)
    }
    catch (Err e) throw Err("Locale eval failed: $p.name", e)
  }

  Void results()
  {
    if (failureNames.size > 0)
    {
      echo("Failed:")
      failureNames.each |Str s| { echo("  $s") }
      echo("")
    }

    echo("***")
    echo("*** " +
      (failures == 0 ? "All tests passed!" : "$failures  FAILURES") +
      " [$testCount tests, $methodCount methods, $totalVerifyCount verifies]")
    echo("***")
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  Void runTests(Type type, Str methodName := "*")
  {
    //if (skip(type, methodName)) return

    echo("")
    methods := methods(type, methodName)
    methods.each |Method m|
    {
      echo("-- Run: ${m}...")
      verifyCount := runTest(m)
      if (verifyCount < 0)
      {
        failures++
        failureNames.add(m.qname)
      }
      else
      {
        echo("   Pass: $m  [$verifyCount]");
        methodCount++
        totalVerifyCount += verifyCount;
      }
    }
    testCount++
  }

  Method[] methods(Type type, Str methodName)
  {
    return type.methods.findAll |Method m->Bool|
    {
      if (m.isAbstract) return false
      if (m.name.startsWith("test"))
      {
        if (methodName == "*") return true
        return methodName == m.name
      }
      return false
    }
  }

  Int runTest(Method m)
  {
    try
    {
      // env dirs
      homeDir := Env.cur.homeDir
      workDir := Env.cur.workDir
      tempDir := Env.cur.tempDir

      js  := "fan.${m.parent.pod}.${m.parent.name}"
      ret := engine.eval(
       "var testRunner = function()
        {
          var test;
          var doCatchErr = function(err)
          {
            if (err == undefined) print('Undefined error\\n');
            else if (err.trace) err.trace();
            else
            {
              var file = err.fileName;   if (file == null) file = 'Unknown';
              var line = err.lineNumber; if (line == null) line = 'Unknown';
              print(err + ' (' + file + ':' + line + ')\\n');
            }
          }

          try
          {
            fan.sys.Env.cur().m_homeDir = fan.sys.File.os($homeDir.osPath.toCode);
            fan.sys.Env.cur().m_workDir = fan.sys.File.os($workDir.osPath.toCode);
            fan.sys.Env.cur().m_tempDir = fan.sys.File.os($tempDir.osPath.toCode);

            test = ${js}.make();
            test.setup();
            test.${m.name}();
            return test.verifyCount;
          }
          catch (err)
          {
            doCatchErr(err);
            return -1;
          }
          finally
          {
            try { test.teardown(); }
            catch (err) { doCatchErr(err); }
          }
        }
        testRunner();")
      return ret->toInt
    }
    catch (Err e)
    {
      echo("")
      echo("TEST FAILED")
      e.trace
      return -1
    }
  }

  Void help()
  {
    echo("Fantom Test");
    echo("Usage:");
    //echo("  fant [options] -all");
    //echo("  fant [options] <pod> [pod]*");
    echo("  fant [options] <pod>");
    echo("  fant [options] <pod>::<test>");
    echo("  fant [options] <pod>::<test>.<method>");
    //echo("Note:");
    //echo("  You can use * to indicate wildcard for all pods");
    //echo("Options:");
    //echo("  -help, -h, -?  print usage help");
    //echo("  -version       print version");
    //echo("  -v             verbose mode");
    //echo("  -all           test all pods");
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ScriptEngine? engine
  Int testCount        := 0
  Int methodCount      := 0
  Int totalVerifyCount := 0
  Int failures         := 0
  Str[] failureNames   := [,]

}
*/