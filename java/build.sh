mkdir libs
jstub='java -cp fan_gen/bin fanx.main.Jstub -d libs'
$jstub sys
$jstub std
$jstub reflect
$jstub testlib


#javap -c -s -v -constants -l -public -sysinfo -cp sys.jar  fan.sys.List
