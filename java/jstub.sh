mkdir libs
jstub='java -cp fan_gen/bin fanx.main.Jstub -d libs'
$jstub sys
$jstub std
$jstub reflect
$jstub baseTest
$jstub testSys

#javap -c -s -v -constants -l -p -sysinfo -cp libs/basetTest.jar fan.baseTest.Main

