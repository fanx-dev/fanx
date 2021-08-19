//{{require}}

//{{tests}}

var methodCount      = 0;
var totalVerifyCount = 0;
var failures         = 0;
var failureNames     = [];

var testRunner = function(type, method)
{
  var test;
  var doCatchErr = function(err)
  {
    if (err == undefined) print('Undefined error\n');
    else if (err.trace) err.trace();
    else
    {
      var file = err.fileName;   if (file == null) file = 'Unknown';
      var line = err.lineNumber; if (line == null) line = 'Unknown';
      fan.std.Env.cur().out().printLine(err + ' (' + file + ':' + line + ')\n');
    }
  }

  try
  {
//{{envDirs}}
    test = type.make();
    test.setup();
    test[method]();
    return test.verifyCount();
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

tests.forEach(function (test) {
  console.log('');
  test.methods.forEach(function (method) {
    var qname = test.qname + '.' + method;
    var verifyCount = -1;
    console.log('-- Run: ' + qname + '...');
    verifyCount = testRunner(test.type, method);
    if (verifyCount < 0) {
      failures++;
      failureNames.push(qname);
    } else {
      console.log('   Pass: ' + qname + ' [' + verifyCount + ']');
      methodCount++;
      totalVerifyCount += verifyCount;
    }
  });
});

if (failureNames.length > 0) {
  console.log('');
  console.log("Failed:");
  failureNames.forEach(function (qname) {
    console.log('  ' + qname);
  });
  console.log('');
}

console.log('');
console.log('***');
console.log('*** ' +
            (failures == 0 ? 'All tests passed!' : '' + failures + ' FAILURES') +
            ' [' + tests.length + ' tests , ' + methodCount + ' methods, ' + totalVerifyCount + ' verifies]');
console.log('***');
