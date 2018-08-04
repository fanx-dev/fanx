//{{require}}

try {
//{{envDirs}}
  fan.{{tempPod}}.Main.make().main();
} catch (err) {
  console.log('ERROR: ' + err + '\n');
  if (err == undefined) print('Undefined error\n');
  else if (err.trace) err.trace();
  else
  {
    var file = err.fileName;   if (file == null) file = 'Unknown';
    var line = err.lineNumber; if (line == null) line = 'Unknown';
    fan.sys.Env.cur().out().printLine(err + ' (' + file + ':' + line + ')\n');
  }
}