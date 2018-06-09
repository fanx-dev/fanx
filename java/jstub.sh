mkdir libs
jstub='java -cp fan_gen/bin fanx.main.Jstub -d libs'
$jstub sys
$jstub std
$jstub reflect
$jstub baseTest

#javap -c -s -v -constants -l -public -sysinfo -cp libs/testlib.jar fan.testlib.Main