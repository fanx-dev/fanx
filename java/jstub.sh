export FAN_HOME=../env/
mkdir libs

set -e
jstub='java -cp fan_gen/bin fanx.tools.Jstub -d libs'
$jstub sys
$jstub std
$jstub baseTest
$jstub testSys
$jstub compiler

#javap -c -s -v -constants -l -p -sysinfo -cp libs/basetTest.jar fan.baseTest.Main

